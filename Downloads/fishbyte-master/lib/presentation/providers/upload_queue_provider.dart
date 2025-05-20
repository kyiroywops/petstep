import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Tus imports de domain/models
import 'package:fishbyte/infrastructure/models/local_report.dart';
import 'package:fishbyte/infrastructure/models/local_report_storage.dart';
import 'package:fishbyte/infrastructure/models/report_upload.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';
import 'package:fishbyte/presentation/providers/local_notifications_provider.dart';
import 'package:fishbyte/presentation/providers/local_notifications_provider.dart'
    show showLocalNotification;
import 'package:fishbyte/presentation/providers/connectivity_provider.dart'
    show isConnectedProvider;

/// Representa la tarea individual de subida
class UploadTask {
  final LocalReport report;
  double progress; // 0..100
  String status;   // "pending" | "uploading" | "done" | "error"
  int retryCount;  // Reintentos realizados
  final int maxRetries;

  UploadTask({
    required this.report,
    this.progress = 0,
    this.status = "pending",
    this.retryCount = 0,
    this.maxRetries = 3,
  });

  UploadTask copyWith({
    double? progress,
    String? status,
    int? retryCount,
  }) {
    return UploadTask(
      report: report,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
    );
  }

  /// Serializar a JSON para guardar la cola en SharedPreferences.
  Map<String, dynamic> toJson() => {
        'reportName': report.name,
        'progress': progress,
        'status': status,
        'retryCount': retryCount,
        'maxRetries': maxRetries,
      };

  /// Deserializar desde JSON, leyendo el [LocalReport] usando `LocalReportStorage`.
  static Future<UploadTask?> fromJson(Map<String, dynamic> json) async {
    final folderName = json['reportName'] as String?;
    if (folderName == null) return null;

    // Lee el contenido local
    final localReport = await LocalReportStorage.readFromLocalFile(folderName);
    if (localReport == null) {
      // Si no existe, retornamos null => descartar
      return null;
    }

    return UploadTask(
      report: localReport,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? "pending",
      retryCount: json['retryCount'] as int? ?? 0,
      maxRetries: json['maxRetries'] as int? ?? 3,
    );
  }
}

/// Notifier que gestiona la cola de subidas
class UploadQueueNotifier extends StateNotifier<List<UploadTask>> {
  UploadQueueNotifier(this.ref) : super([]) {
    _initQueue();

    // 1) Escuchamos los cambios de conectividad.
    //    Cada vez que pase de sin conexión a conectado, reintentamos subir la cola.
    ref.listen<AsyncValue<bool>>(isConnectedProvider, (previous, next) {
      final wasConnected = previous?.maybeWhen(data: (v) => v, orElse: () => false) ?? false;
      final isConnectedNow = next.maybeWhen(data: (v) => v, orElse: () => false);

      // Si antes NO había conexión y AHORA sí:
      if (!wasConnected && isConnectedNow) {
        _processQueue();
      }
    });
  }

  final Ref ref;
  bool _isProcessing = false;

  /// Reintenta todas las tareas con estado "error"
  /// aun no tiene uso pero seria para los tasks que fallaron y que les sale el signo de error
void retryErroredTasks() {
  final updatedTasks = state.map((task) {
    if (task.status == "error") {
      return task.copyWith(status: "pending", progress: 0);
    }
    return task;
  }).toList();

  state = updatedTasks;

  // Inicia el procesamiento de la cola nuevamente
  _processQueue();
}


  /// Lee la cola desde SharedPreferences y reanuda subidas
Future<void> _initQueue() async {
  final sp = await SharedPreferences.getInstance();
  final raw = sp.getString('uploadQueue') ?? '[]';
  final List<dynamic> listJson = json.decode(raw);

  final tasks = <UploadTask>[];
  for (final item in listJson) {
    if (item is Map<String, dynamic>) {
      final t = await UploadTask.fromJson(item);
      if (t != null) {
        tasks.add(t);
      }
    }
  }

  // IMPORTANTE: Revertir cualquier reporte "uploading" a "pending" Este cambio es para que si la app se cierra, no quede en un estado inconsistente.
  final fixedTasks = tasks.map((task) {
    if (task.status == "uploading") {
      // Si quieres resetear el progreso a 0:
      return task.copyWith(status: "pending", progress: 0);
      // O, si prefieres no perder el porcentaje (solo cambiar estado):
      // return task.copyWith(status: "pending");
    }
    return task;
  }).toList();

  state = fixedTasks;

  // Por si ya hubiera conexión, inicia la subida:
  _processQueue();
}
  @override
  set state(List<UploadTask> newState) {
    super.state = newState;
    _saveQueueToDisk(newState);
  }

  /// Guarda la cola en disco
  Future<void> _saveQueueToDisk(List<UploadTask> tasks) async {
    final sp = await SharedPreferences.getInstance();
    final listMap = tasks.map((t) => t.toJson()).toList();
    final raw = json.encode(listMap);
    await sp.setString('uploadQueue', raw);
  }

  bool isReportInQueue(LocalReport report) {
    return state.any((t) => t.report.name == report.name);
  }

  /// Encola un reporte nuevo si no existe
  void enqueue(LocalReport report) {
    if (isReportInQueue(report)) return;
    final task = UploadTask(report: report);
    state = [...state, task];
    _processQueue(); // Intentar subir de inmediato
  }

  /// Encola múltiples reportes
  void enqueueMultiple(List<LocalReport> reports) {
    final newTasks = <UploadTask>[];
    for (final r in reports) {
      if (!isReportInQueue(r)) {
        newTasks.add(UploadTask(report: r));
      }
    }
    if (newTasks.isEmpty) return;
    state = [...state, ...newTasks];
    _processQueue();
  }

  /// Procesa la cola secuencialmente
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // 2) Verificamos si hay conexión antes de procesar
      final isConnected = ref.read(isConnectedProvider).maybeWhen(
        data: (v) => v,
        orElse: () => false,
      );
      if (!isConnected) {
        // Sin conexión => no hacemos nada
        _isProcessing = false;
        return;
      }

      while (true) {
        // Verificamos si hay elementos en la cola antes de buscar el índice
        if (state.isEmpty) {
          debugPrint("📋 Cola de subida vacía, terminando procesamiento");
          break;
        }
        
        final idx = state.indexWhere((t) => t.status == "pending" || t.status == "error");
        if (idx == -1) {
          debugPrint("📋 No hay más tareas pendientes o con error en la cola");
          break;
        }

        // Guardar una referencia a la tarea actual para evitar problemas si la lista cambia
        final currentTask = state[idx];
        
        // Actualizar estado a "uploading" si es posible
        _updateTask(idx, currentTask.copyWith(status: "uploading", progress: 0));
        
        // Obtener el estado actual para verificaciones de seguridad
        final currentState = state;
        
        // Verificar que la tarea aún existe en la cola actual
        if (idx >= currentState.length || currentState[idx].report.name != currentTask.report.name) {
          debugPrint("⚠️ La tarea ya no existe en la cola o cambió de posición, saltando");
          continue;
        }
        
        final success = await _uploadSingleTask(idx, currentTask);

        // Verificar de nuevo que la tarea aún existe después de la subida
        final newIdx = state.indexWhere((t) => t.report.name == currentTask.report.name);
        
        if (newIdx >= 0) {
          // La tarea aún existe, actualizar su estado
          final finalStatus = success ? "done" : "error";
          _updateTask(newIdx, state[newIdx].copyWith(status: finalStatus, progress: 100));
        } else {
          debugPrint("⚠️ La tarea fue eliminada durante la subida, no se puede actualizar su estado");
        }
      }
    } catch (e) {
      debugPrint("❌ Error en el procesamiento de la cola: $e");
    } finally {
      _isProcessing = false;
    }
  }

  /// Sube un solo elemento de la cola
  Future<bool> _uploadSingleTask(int index, UploadTask task) async {
    // Ya no usamos el índice para acceder al estado, usamos la tarea pasada directamente
    try {
      debugPrint("📤 Iniciando subida de reporte: ${task.report.name}");
      
      // Función para actualizar el progreso
      void updateProgress(double p) {
        // Buscar el índice actual de la tarea (puede haber cambiado)
        final currentIndex = state.indexWhere((t) => t.report.name == task.report.name);
        if (currentIndex >= 0) {
          // Actualiza el progreso en la cola solo si la tarea aún existe
          _updateTask(currentIndex, task.copyWith(progress: p));
        }
      }
      
      // Intentamos múltiples métodos de subida en orden de preferencia
      bool success = false;
      
      // 1. Método usando proxy
      try {
        debugPrint("🔄 Intentando método 1: Subida vía proxy...");
        success = await uploadReportUsingProxy(
          ref, 
          task.report,
          onProgress: updateProgress,
        );
        
        if (success) {
          debugPrint("✅ Éxito con método 1 (proxy)");
        }
      } catch (proxyError) {
        debugPrint("⚠️ Método 1 (proxy) falló: $proxyError");
      }
      
      // 2. Si falló el proxy, intentamos el método web
      if (!success) {
        try {
          debugPrint("🔄 Intentando método 2: Subida estilo web...");
          success = await uploadReportWebMethod(
            ref,
            task.report,
            onProgress: updateProgress,
          );
          
          if (success) {
            debugPrint("✅ Éxito con método 2 (web)");
          }
        } catch (webError) {
          debugPrint("⚠️ Método 2 (web) falló: $webError");
        }
      }
      
      // 3. Si los anteriores fallan, método original
      if (!success) {
        try {
          debugPrint("🔄 Intentando método 3: Subida original...");
          success = await uploadReport(
            ref,
            task.report,
            onProgress: updateProgress,
          );
          
          if (success) {
            debugPrint("✅ Éxito con método 3 (original)");
          }
        } catch (originalError) {
          debugPrint("⚠️ Método 3 (original) falló: $originalError");
        }
      }

      if (success) {
        debugPrint("✅ Subida exitosa para ${task.report.name}");
        // Borrar JSON local del reporte (si no se borró ya en el método de subida)
        await LocalReportStorage.deleteLocalReport(task.report.name);
        ref.invalidate(allReportsProvider);

        final notifPlugin = ref.read(localNotificationsProvider);
        await showLocalNotification(
          plugin: notifPlugin,
          title: "Reporte subido",
          body: "Se subió '${task.report.name}' con éxito.",
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
        return true;
      } else {
        debugPrint("❌ Todos los métodos de subida fallaron para ${task.report.name}");
        final notifPlugin = ref.read(localNotificationsProvider);
        await showLocalNotification(
          plugin: notifPlugin,
          title: "Error subiendo",
          body: "Hubo error subiendo '${task.report.name}'.",
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
        
        return false;
      }
    } catch (e) {
      debugPrint("❌❌ Excepción durante la subida de ${task.report.name}: $e");
      final notifPlugin = ref.read(localNotificationsProvider);
      await showLocalNotification(
        plugin: notifPlugin,
        title: "Excepción subiendo",
        body: "Error: $e => '${task.report.name}'",
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      
      return false;
    }
  }

  /// Actualiza un task en la posición [index]
  void _updateTask(int index, UploadTask newTask) {
    // Verificar que el índice sea válido
    if (index < 0 || index >= state.length) {
      debugPrint("⚠️ Intento de actualizar tarea en índice inválido: $index (tamaño de la cola: ${state.length})");
      return; // Salir si el índice no es válido
    }
    
    final list = [...state];
    list[index] = newTask;
    state = list; // disparará persistencia
  }

  /// Limpia tareas finalizadas (done/error)
  void clearFinished() {
    final filtered = state
        .where((t) => t.status == "pending" || t.status == "uploading")
        .toList();
    state = filtered;
  }

  /// Limpia toda la cola
  void clearAll() {
    state = [];
    _isProcessing = false;
  }

  /// Elimina un reporte específico de la cola por su nombre
  void removeReportByName(String reportName) {
    final filteredTasks = state.where((task) => task.report.name != reportName).toList();
    
    // Solo actualizamos si realmente se eliminó algún elemento
    if (filteredTasks.length < state.length) {
      state = filteredTasks;
    }
  }
}

/// Provider global de la cola
final uploadQueueProvider =
    StateNotifierProvider<UploadQueueNotifier, List<UploadTask>>((ref) {
  return UploadQueueNotifier(ref);
});
