// lib/infrastructure/models/report_upload.dart

import 'dart:convert';
import 'dart:io';

import 'package:fishbyte/presentation/providers/recentlysent_provider.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';
import 'package:fishbyte/presentation/providers/senttotal_counter_provider.dart';
import 'package:fishbyte/presentation/providers/upload_queue_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Tus modelos locales
import 'package:fishbyte/infrastructure/models/local_report.dart';
import 'package:fishbyte/infrastructure/models/local_report_storage.dart';

// Provider para Supabase
import 'package:fishbyte/presentation/providers/login/auth_provider.dart';

/// Sube un [localReport] al backend usando Supabase:
/// - Sube imágenes al storage de Supabase.
/// - Construye `reportData` con campos para la tabla 'reports'.
/// - Inserta el informe en la tabla 'reports'.
/// - Marca localmente el [LocalReport] (status='uploaded') si todo sale bien.
/// - Guarda en 'recentlySentReports' de SharedPreferences la info "reciente".
///
/// [ref] es un `Ref` de Riverpod (puede ser un `WidgetRef` o `Ref` de StateNotifier).
/// [onProgress] recibe un valor de 0..100 que representa el % global de progreso.
Future<bool> uploadReport(
  Ref ref,
  LocalReport localReport, {
  required void Function(double) onProgress,
}) async {
  double totalProgress = 0;
  
  debugPrint("🚀 Iniciando proceso de subida de reporte: ${localReport.name}");
  debugPrint("🔍 Datos del reporte: idGlobal=${localReport.idGlobal}, centro=${localReport.center.name}, jaula=${localReport.cage.name}, imágenes=${localReport.imagenes.length}");

  // Función auxiliar para acumular progreso
  void increment(double inc) {
    totalProgress += inc;
    if (totalProgress > 100) totalProgress = 100;
    onProgress(totalProgress);
    debugPrint("📊 Progreso de subida: $totalProgress%");
  }

  try {
    // (1) Obtener el cliente de Supabase
    final supabase = ref.read(supabaseClientProvider);
    debugPrint("✓ Cliente Supabase obtenido");

    // (2) Verificar sesión activa
    final session = supabase.auth.currentSession;
    if (session == null || session.accessToken.isEmpty) {
      debugPrint("❌ Error: No hay sesión activa en Supabase");
      throw Exception("No hay sesión activa en Supabase");
    }
    
    final userId = session.user.id;
    debugPrint("✓ Sesión de usuario activa: ${session.user.email} (ID: $userId)");

    // (3) Distribución de progreso
    const imagesWeight = 70.0;
    const dbInsertWeight = 30.0;

    final images = localReport.imagenes;
    final numImages = images.length;
    final perImage = (numImages == 0) ? 0 : (imagesWeight / numImages);

    final imagePaths = <String>[];
    final failedImages = <String>[];

    // (4) Subir cada imagen secuencialmente al storage de Supabase
    for (int i = 0; i < numImages; i++) {
      final imgItem = images[i];
      final incPerImg = perImage;
      
      debugPrint("🖼️ Subiendo imagen ${i+1}/$numImages: ${imgItem.name}");

      try {
        // Verificar si la imagen existe antes de intentar subirla
        final imageFile = File(imgItem.img);
        if (!imageFile.existsSync()) {
          debugPrint("⚠️ Imagen no encontrada: ${imgItem.img}");
          failedImages.add(imgItem.name);
          
          // Si es la primera imagen obligatoria (id=1), debemos fallar
          if (imgItem.id == 1) {
            // Eliminar el reporte local ya que la imagen principal obligatoria no existe
            debugPrint("🧹 Eliminando reporte local debido a error en imagen principal: ${localReport.name}");
            await LocalReportStorage.deleteLocalReport(localReport.name);
            
            // Invalidar la lista de reportes para actualizar la UI
            ref.invalidate(allReportsProvider);
            
            // Si el reporte está en la cola de subida, eliminarlo
            final queueNotifier = ref.read(uploadQueueProvider.notifier);
            if (queueNotifier.isReportInQueue(localReport)) {
              debugPrint("🧹 Eliminando reporte de la cola de subida: ${localReport.name}");
              queueNotifier.removeReportByName(localReport.name);
            }
            
            throw Exception("No se encontró la imagen principal obligatoria: ${imgItem.name}");
          }
          
          // Para otras imágenes, continuamos con las siguientes
          increment(incPerImg.toDouble());
          continue;
        }
        
        final imagePath = await _uploadImageToSupabase(
          supabase: supabase,
          filePath: imgItem.img,
          localReport: localReport,
          onProgress: (percent) {
            // 'percent' es 0..100 para UNA imagen
            final inc = incPerImg * (percent / 100.0);
            increment(inc.toDouble());
          },
        );
        
        debugPrint("✓ Imagen ${i+1} subida exitosamente: $imagePath");
        imagePaths.add(imagePath);
      } catch (imageError) {
        debugPrint("❌ Error subiendo imagen ${i+1}: $imageError");
        failedImages.add(imgItem.name);
        
        // Si es la primera imagen obligatoria (id=1), debemos fallar
        if (imgItem.id == 1) {
          // Eliminar el reporte local ya que la imagen principal obligatoria no existe
          debugPrint("🧹 Eliminando reporte local debido a error en imagen principal: ${localReport.name}");
          await LocalReportStorage.deleteLocalReport(localReport.name);
          
          // Invalidar la lista de reportes para actualizar la UI
          ref.invalidate(allReportsProvider);
          
          // Si el reporte está en la cola de subida, eliminarlo
          final queueNotifier = ref.read(uploadQueueProvider.notifier);
          if (queueNotifier.isReportInQueue(localReport)) {
            debugPrint("🧹 Eliminando reporte de la cola de subida: ${localReport.name}");
            queueNotifier.removeReportByName(localReport.name);
          }
          
          throw Exception("Error en la imagen principal obligatoria: $imageError");
        }
        
        // Para otras imágenes, continuamos con las siguientes
        increment(incPerImg.toDouble());
      }
    }

    // Mostrar resumen de imágenes fallidas
    if (failedImages.isNotEmpty) {
      debugPrint("⚠️ ${failedImages.length} imagen(es) no pudieron ser subidas: ${failedImages.join(', ')}");
    }
    
    // Verificamos que al menos tengamos una imagen para continuar
    if (imagePaths.isEmpty) {
      throw Exception("No se pudo subir ninguna imagen. Revise los archivos y permisos.");
    }

    // Aseguramos llegar a 70%
    if (totalProgress < imagesWeight) {
      increment(imagesWeight - totalProgress);
    }

    // (5) Generar un uuid para el reporte
    final uuidReport = const Uuid().v4();
    debugPrint("🔑 UUID generado para el reporte: $uuidReport");

    // (6) Armar los metadatos para el reporte
    final metadata = {
      "acs": localReport.center.ACS,
      "siep": localReport.center.SIEP,
      "shoot": localReport.date,
      "water": localReport.center.water,
      "labels": null,
      "weight": localReport.weight,
      "cage_id": localReport.cage.id,
      "comment": null,
      "disease": null,
      "species": localReport.center.species,
      "user_id": userId,
      "cageName": localReport.cage.name,
      "category": localReport.center.category,
      "idglobal": "$uuidReport-$userId-${DateTime.now().toIso8601String()}Z",
      "revisado": false,
      "userName": localReport.user,
      "center_id": localReport.center.id,
      "centerName": localReport.center.name,
      "disease_ai": null, 
      "ai_approved": null,
      "enterprise_id": localReport.enterprise,
      "enterpriseName": "Lythium",
    };
    
    debugPrint("📋 Metadatos del reporte preparados");

    // (7) Insertar reporte en la tabla 'reports'
    debugPrint("💾 Insertando datos del reporte en la tabla 'reports'");
    
    final reportData = {
      'idglobal': localReport.idGlobal,
      'weight': localReport.weight,
      'shoot': localReport.date,
      'metadata': metadata,
      'center_id': localReport.center.id,
      'enterprise_id': localReport.enterprise,
      'user_id': userId, // Usamos el ID de Supabase, no el de GraphQL
      'cage_id': localReport.cage.id,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    debugPrint("📊 Datos a insertar: $reportData");
    
    try {
      final reportInsert = await supabase
          .from('reports')
          .insert(reportData)
          .select('id')
          .single();
      
      final reportId = reportInsert['id'];
      debugPrint("✓ Reporte insertado con ID: $reportId");
      
      // (8) Insertar referencias a las imágenes en la tabla 'images'
      debugPrint("🔗 Insertando referencias a ${imagePaths.length} imágenes");
      
      for (int i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
        
        try {
          await supabase.from('images').insert({
            'storage_path': imagePath,
            'report_id': reportId,
            'created_at': DateTime.now().toIso8601String(),
          });
          
          debugPrint("✓ Referencia a imagen ${i+1} insertada: $imagePath");
        } catch (imageRefError) {
          debugPrint("❌ Error al insertar referencia a imagen ${i+1}: $imageRefError");
          // Continuamos con las siguientes imágenes
        }
      }
    } catch (dbError) {
      debugPrint("❌ Error al insertar datos en la base de datos: $dbError");
      
      // Si hay un error al insertar el reporte, intentamos eliminar las imágenes ya subidas
      debugPrint("🧹 Intentando limpiar imágenes ya subidas");
      for (final path in imagePaths) {
        try {
          final fileName = path.split('/').last;
          await supabase.storage.from('report-images').remove([fileName]);
          debugPrint("✓ Imagen limpiada correctamente: $fileName");
        } catch (cleanupError) {
          debugPrint("⚠️ No se pudo limpiar la imagen: $cleanupError");
        }
      }
      
      rethrow;
    }

    // (9) Subir 30% => 100%
    increment(dbInsertWeight);

    // (10) Marcar localmente como 'uploaded'
    final updated = localReport.copyWith(status: 'uploaded');
    await LocalReportStorage.saveToLocalFile(updated, updated.name);
    debugPrint("✓ Reporte marcado localmente como 'uploaded'");

    // (10.1) Invalida el provider de la lista de reportes para que se recargue
    ref.invalidate(allReportsProvider);

    // (11) Agregar a la lista de "recentlySentReports"
    final newSent = {
      "centerName": localReport.center.name,
      "cageName":   localReport.cage.name,
      "sentAt":     DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('recentlySentReports') ?? '[]';
    final List<dynamic> recents = json.decode(raw);

    recents.add(newSent);
    // Limitar a 20 items recientes:
    if (recents.length > 21) {
      recents.removeAt(0); // elimina el más antiguo
    }

    await prefs.setString('recentlySentReports', json.encode(recents));
    debugPrint("✓ Reporte añadido a la lista de 'recentlySentReports'");

    // (12) Invalidar o refrescar para que se actualice de inmediato la lista recents
    ref.invalidate(recentlySentProvider);

    // (13) Incrementar contador de envíos en SharedPreferences
    await incrementSentCounter();
    debugPrint("✓ Contador de envíos incrementado");

    // (14) Invalida el provider que lee ese contador para que cambie en la UI
    ref.invalidate(sentCounterProvider);

    // Éxito total
    debugPrint("✅ Subida del reporte completada exitosamente");
    return true;
  } catch (e) {
    debugPrint("❌❌❌ ERROR SUBIENDO REPORTE: $e");
    
    // Mostrar más detalles si es un error de Supabase
    if (e is PostgrestException) {
      debugPrint("❌ Error de Postgrest: Código ${e.code}, mensaje: ${e.message}, hint: ${e.hint}");
    } else if (e is StorageException) {
      debugPrint("❌ Error de Storage: ${e.message}, statusCode: ${e.statusCode}");
    }
    
    return false;
  }
}

/// Función para subir 1 imagen al storage de Supabase
/// Devuelve la ruta de almacenamiento en Supabase Storage
Future<String> _uploadImageToSupabase({
  required SupabaseClient supabase,
  required String filePath,
  required void Function(double) onProgress,
  required LocalReport localReport,
}) async {
  final file = File(filePath);
  
  // Comprobar existencia del archivo
  if (!file.existsSync()) {
    debugPrint("❌ Error: No existe el archivo: $filePath");
    throw Exception("No existe el archivo: $filePath");
  }

  try {
    // Verificar la sesión de autenticación
    final session = supabase.auth.currentSession;
    if (session == null || session.accessToken.isEmpty) {
      debugPrint("❌ Error: No hay sesión activa para subir archivos");
      throw Exception("No hay sesión activa para subir archivos. Inicia sesión nuevamente.");
    }
    
    debugPrint("🔑 INFORMACIÓN DETALLADA DE LA SESIÓN:");
    debugPrint("=======================================");
    debugPrint("User ID: ${session.user.id}");
    debugPrint("Email: ${session.user.email}");
    debugPrint("Provider: ${session.user.appMetadata['provider']}");
    debugPrint("Roles: ${session.user.appMetadata['role']}");
    
    // Imprimir información del token
    debugPrint("Token expira en: ${session.expiresAt}");
    debugPrint("Token expira en (DateTime): ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)}");
    debugPrint("Token válido: ${DateTime.now().millisecondsSinceEpoch / 1000 < session.expiresAt!}");
    
    // Intentar obtener la política real del bucket desde la consola de Supabase
    try {
      debugPrint("📜 Intentando obtener política del bucket report-images...");
      final rls = await supabase.rpc('debug_bucket_policy', params: {'bucket_name': 'report-images'});
      debugPrint("Política: $rls");
    } catch (e) {
      debugPrint("No se pudo obtener la política: $e");
    }
    
    final userId = session.user.id;
    final originalFileName = filePath.split('/').last;
    final reportId = localReport.idGlobal; 
    // IMPORTANTE: Usemos '0' como enterpriseId si es null o vacío
    final enterpriseId = localReport.enterprise.isEmpty ? "0" : localReport.enterprise;
    
    // Logs detallados para depuración
    debugPrint("🔑 Detalles de sesión:");
    debugPrint("- ID usuario: $userId");
    debugPrint("- Email: ${session.user.email}");
    debugPrint("- Token: ${session.accessToken.substring(0, session.accessToken.length > 20 ? 20 : session.accessToken.length)}...");
    debugPrint("- Enterprise ID: $enterpriseId");
    debugPrint("- Report ID: $reportId");
    
    // Imprimir políticas de storage disponibles
    debugPrint("📁 Intentando listar políticas de bucket 'report-images'...");
    try {
      final result = await supabase.rpc('get_storage_policy_info', params: {'bucket_name': 'report-images'});
      debugPrint("📁 Políticas disponibles: $result");
    } catch (policyError) {
      debugPrint("❌ No se pudieron obtener políticas: $policyError");
    }
    
    // NOTA: Para coincidir exactamente con la web, vamos a omitir 'public/' al inicio
    final uniqueId = '${DateTime.now().millisecondsSinceEpoch}';
    // Comprobar si el ID de empresa es numérico o UUID
    final storageFilePath = '$enterpriseId/$userId/$reportId/$uniqueId-$originalFileName';
    
    debugPrint("✓ Sesión verificada para subida: ${session.user.email}");
    debugPrint("✓ Archivo encontrado: $filePath (${file.lengthSync()} bytes)");
    debugPrint("📂 Subiendo archivo a ruta: $storageFilePath");
    
    // Usar el método upload exactamente como lo hace la web
    final result = await supabase
      .storage
      .from('report-images')
      .upload(
        storageFilePath,
        file,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: false, // Exactamente como la web
        ),
      );
    
    debugPrint("✅ Subida exitosa");
    
    // Obtener URL pública para verificar
    final publicUrlResponse = supabase.storage.from('report-images').getPublicUrl(storageFilePath);
    debugPrint("🔗 URL pública: $publicUrlResponse");
      
    // No hay progreso en tiempo real, simulamos
    onProgress(100);
    
    // Devolver la ruta exacta como se guardó en Supabase (sin añadir 'report-images/')
    return storageFilePath;
  } catch (e) {
    debugPrint("❌ Error subiendo imagen a Supabase Storage: $e");
    if (e is StorageException) {
      debugPrint("❌ Detalles del error: ${e.message}, statusCode: ${e.statusCode}");
      
      // Información detallada sobre el error
      if (e.statusCode == 403) {
        debugPrint("🔒 Error RLS detallado:");
        debugPrint("- Mensaje: ${e.message}");
        debugPrint("- Error: ${e.error}");
        
        // Verificar políticas RLS en tiempo real si es posible
        try {
          debugPrint("📑 Consultando detalles de políticas aplicables...");
          final policyCheckResult = await supabase.rpc('debug_rls_policy', 
            params: {
              'bucket_name': 'report-images',
              'file_path': filePath.split('/').last,
              'action_type': 'INSERT'
            }
          );
          debugPrint("📑 Resultado: $policyCheckResult");
        } catch (policyError) {
          debugPrint("❌ No se pudo depurar política: $policyError");
        }
        
        // Intenta obtener información sobre buckets
        debugPrint("🗂️ Listando buckets disponibles...");
        try {
          final buckets = await supabase.storage.listBuckets();
          for (final bucket in buckets) {
            debugPrint("- Bucket: ${bucket.name}, public: ${bucket.public}");
          }
        } catch (bucketError) {
          debugPrint("❌ No se pudieron listar buckets: $bucketError");
        }
      }
    }
    rethrow;
  }
}

/// Determina el tipo de contenido (MIME type) del archivo basado en su extensión
String _getContentType(String fileName) {
  final mimeType = lookupMimeType(fileName);
  
  if (mimeType != null) {
    return mimeType;
  }
  
  // Fallback para tipos comunes de imágenes si mime package no lo detecta
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'heic':
      return 'image/heic';
    default:
      return 'application/octet-stream'; // tipo genérico
  }
}

// La siguiente función es para mantener compatibilidad con el código existente
// Función obsoleta, usar _uploadImageToSupabase en su lugar
@Deprecated('Obsoleto: Usar _uploadImageToSupabase')
Future<int> _uploadImage({
  required String filePath,
  required String jwt,
  required String enterpriseUrl,
  required void Function(double) onProgress,
}) async {
  debugPrint("⚠️ ADVERTENCIA: _uploadImage está obsoleto. Usar _uploadImageToSupabase.");
  throw Exception("Método obsoleto. Usar Supabase para subir imágenes.");
}

/// Sube un [localReport] al backend usando Supabase implementando
/// el mismo método que usa la versión web:
/// - Sube las imágenes primero.
/// - Luego llama a la función RPC "create_report_and_images".
///
/// [ref] es un `Ref` de Riverpod (puede ser un `WidgetRef` o `Ref` de StateNotifier).
/// [onProgress] recibe un valor de 0..100 que representa el % global de progreso.
Future<bool> uploadReportWebMethod(
  Ref ref,
  LocalReport localReport, {
  required void Function(double) onProgress,
}) async {
  double totalProgress = 0;
  
  debugPrint("🚀 Iniciando proceso de subida de reporte (método web): ${localReport.name}");
  debugPrint("🔍 Datos del reporte: idGlobal=${localReport.idGlobal}, centro=${localReport.center.name}, jaula=${localReport.cage.name}, imágenes=${localReport.imagenes.length}");

  // Función auxiliar para acumular progreso
  void increment(double inc) {
    totalProgress += inc;
    if (totalProgress > 100) totalProgress = 100;
    onProgress(totalProgress);
    debugPrint("📊 Progreso de subida: $totalProgress%");
  }

  try {
    // (1) Obtener el cliente de Supabase
    final supabase = ref.read(supabaseClientProvider);
    debugPrint("✓ Cliente Supabase obtenido");

    // (2) Verificar sesión activa
    final session = supabase.auth.currentSession;
    if (session == null || session.accessToken.isEmpty) {
      debugPrint("❌ Error: No hay sesión activa en Supabase");
      throw Exception("No hay sesión activa en Supabase");
    }
    
    final userId = session.user.id;
    debugPrint("✓ Sesión de usuario activa: ${session.user.email} (ID: $userId)");
    
    // (2.5) IMPORTANTE: Obtener el enterprise_id correcto del usuario
    String? correctEnterpriseId = await getUserEnterpriseId(supabase, userId);
    
    // Si no se pudo obtener el enterprise_id correcto, usamos el valor almacenado
    final enterpriseId = correctEnterpriseId ?? 
                        (localReport.enterprise.isEmpty ? "0" : localReport.enterprise);
    
    debugPrint("🏢 Enterprise ID a usar: $enterpriseId (original: ${localReport.enterprise})");

    // (3) Distribución de progreso
    const imagesWeight = 70.0;
    const dbInsertWeight = 30.0;

    final images = localReport.imagenes;
    final numImages = images.length;
    final perImage = (numImages == 0) ? 0 : (imagesWeight / numImages);

    // Esta variable almacenará las rutas de las imágenes después de subirlas
    final List<Map<String, String>> uploadedImagePaths = [];
    final failedImages = <String>[];
    // Generar un UUID para el reporte (igual que la web)
    final reportId = const Uuid().v4();

    // (4) Crear las rutas y subir cada imagen como lo hace la web
    for (int i = 0; i < numImages; i++) {
      final imgItem = images[i];
      final incPerImg = perImage;

      debugPrint("🖼️ Subiendo imagen ${i+1}/$numImages: ${imgItem.name}");

      try {
        final imageFile = File(imgItem.img);
        if (!imageFile.existsSync()) {
          debugPrint("⚠️ Imagen no encontrada: ${imgItem.img}");
          failedImages.add(imgItem.name);
          
          if (imgItem.id == 1) {
            // Eliminar reporte si falla la imagen principal
            debugPrint("🧹 Eliminando reporte local debido a imagen faltante: ${localReport.name}");
            await LocalReportStorage.deleteLocalReport(localReport.name);
            ref.invalidate(allReportsProvider);
            
            // Limpiar cola
            final queueNotifier = ref.read(uploadQueueProvider.notifier);
            if (queueNotifier.isReportInQueue(localReport)) {
              debugPrint("🧹 Eliminando reporte de la cola: ${localReport.name}");
              queueNotifier.removeReportByName(localReport.name);
            }
            
            throw Exception("No se encontró la imagen principal obligatoria: ${imgItem.name}");
          }
          
          increment(incPerImg.toDouble());
          continue;
        }
        
        // Construir la ruta exactamente como exige la política RLS
        final fileName = imageFile.path.split('/').last;
        final uniqueId = '${DateTime.now().millisecondsSinceEpoch}';
        
        // IMPORTANTE: La política RLS espera esta estructura exacta:
        // public/[enterprise_id]/[user_id]/[resto_de_la_ruta]
        // Los índices 2 y 3 son críticos para la política RLS
        final filePath = 'public/$enterpriseId/$userId/$reportId/${uniqueId}-$fileName';
        
        debugPrint("📂 Subiendo a ruta adaptada para RLS: $filePath");
        
        // IMPORTANTE: Probamos con ambos métodos de carga para diagnosticar el problema
        String uploadedFilePath = "";
        try {
          debugPrint("🔄 Intentando método directo primero...");
          final result = await supabase
            .storage
            .from('report-images')
            .upload(
              filePath,
              imageFile,
              fileOptions: FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
          uploadedFilePath = filePath;
          debugPrint("✅ Subida exitosa con método directo");
        } catch (directUploadError) {
          debugPrint("⚠️ Fallo en método directo: $directUploadError. Probando con URL firmada...");
          // Si falla el método directo, intentamos URL firmada
          uploadedFilePath = await _uploadImageWithSignedUrl(
            supabase: supabase,
            filePath: imageFile.path,
            storagePath: filePath,
            onProgress: (_) {},
          );
          debugPrint("✅ Subida exitosa con URL firmada");
        }
        
        // Almacenar la ruta para usarla después en la función RPC
        uploadedImagePaths.add({
          'storage_path': uploadedFilePath,
          'description': imgItem.name
        });
        
        debugPrint("✓ Imagen ${i+1} subida correctamente: $uploadedFilePath");
        increment(incPerImg.toDouble());
      } catch (imageError) {
        debugPrint("❌ Error subiendo imagen ${i+1}: $imageError");
        failedImages.add(imgItem.name);
        
        if (imgItem.id == 1) {
          // Eliminar reporte si falla la imagen principal
          debugPrint("🧹 Eliminando reporte local debido a error en imagen: ${localReport.name}");
          await LocalReportStorage.deleteLocalReport(localReport.name);
          ref.invalidate(allReportsProvider);
          
          // Limpiar cola
          final queueNotifier = ref.read(uploadQueueProvider.notifier);
          if (queueNotifier.isReportInQueue(localReport)) {
            queueNotifier.removeReportByName(localReport.name);
          }
          
          throw Exception("Error en imagen principal: $imageError");
        }
        
        increment(incPerImg.toDouble());
      }
    }

    // Verificar si tenemos al menos una imagen para continuar
    if (uploadedImagePaths.isEmpty) {
      throw Exception("No se pudo subir ninguna imagen. Revise los archivos.");
    }

    // Asegurar que llegamos al 70% después de las imágenes
    if (totalProgress < imagesWeight) {
      increment(imagesWeight - totalProgress);
    }

    // (5) Preparar los datos para la función RPC
    debugPrint("📋 Preparando datos para función RPC create_report_and_images");

    // Metadatos como lo hace la web - NOMBRES DE CLAVES EN MINÚSCULAS para coincidencia exacta
    final metadata = {
      "acs": localReport.center.ACS,
      "siep": localReport.center.SIEP,
      "shoot": localReport.date,
      "water": localReport.center.water,
      "labels": null,
      "weight": localReport.weight,
      "cage_id": localReport.cage.id,
      "comment": null,
      "disease": null,
      "species": localReport.center.species,
      "user_id": userId,
      "cageName": localReport.cage.name,
      "category": localReport.center.category,
      "idglobal": "$enterpriseId-$userId-${DateTime.now().toIso8601String()}Z",
      "revisado": false,
      "userName": localReport.user,
      "center_id": localReport.center.id,
      "centerName": localReport.center.name,
      "disease_ai": null, 
      "ai_approved": null,
      "enterprise_id": enterpriseId,
      "enterpriseName": "Lythium",
    };
    
    // Estructura exactamente como la web
    final reportDataForFunction = {
      "id": reportId,
      "enterprise_id": enterpriseId,
      "user_id": userId,
      "center_id": localReport.center.id,
      "cage_id": localReport.cage.id,
      "weight": localReport.weight,
      "shoot": localReport.date,
      "idglobal": metadata["idglobal"], // Usar el mismo que en metadata
      "metadata": metadata,
      "comment": null,
      "disease": null,
      "disease_ai": null,
      "labels": null,
      "revisado": false,
      "ai_approved": null,
    };
    
    debugPrint("📤 Enviando datos a función RPC create_report_and_images");
    debugPrint("🖼️ Imágenes a registrar: ${uploadedImagePaths.length}");
    
    // (6) Intentamos dos métodos: primero la función RPC, luego inserción directa
    bool success = false;
    
    // Método 1: Llamar a la función RPC create_report_and_images como lo hace la web
    try {
      increment(dbInsertWeight / 2); // 85%
      
      debugPrint("🔄 Intentando método 1: Función RPC create_report_and_images...");
      final result = await supabase.rpc(
        "create_report_and_images",
        params: {
          "report_data": reportDataForFunction,
          "images_json": uploadedImagePaths,
        },
      );
      
      debugPrint("✓ Resultado de función RPC: $result");
      success = true;
    } catch (rpcError) {
      debugPrint("❌ Error en función RPC: $rpcError");
      debugPrint("🔄 Intentando método 2: Inserción directa en tablas...");
      
      // Método 2: Inserción directa en tablas
      success = await _insertReportAndImagesDirect(
        supabase: supabase,
        reportId: reportId,
        userId: userId,
        enterpriseId: enterpriseId,
        localReport: localReport,
        uploadedImagePaths: uploadedImagePaths,
      );
    }
    
    if (!success) {
      debugPrint("❌ Todos los métodos de inserción de reporte fallaron");
      
      // Intentar limpiar imágenes ya subidas
      debugPrint("🧹 Limpiando imágenes subidas");
      for (final imgPath in uploadedImagePaths) {
        try {
          await supabase.storage.from('report-images').remove([imgPath['storage_path']!]);
          debugPrint("✓ Imagen limpiada: ${imgPath['storage_path']}");
        } catch (cleanupError) {
          debugPrint("⚠️ No se pudo limpiar imagen: $cleanupError");
        }
      }
      
      throw Exception("Error al guardar reporte en base de datos");
    }
    
    // (7) Terminando y actualizando estado local
    increment(dbInsertWeight / 2); // 100%
    
    // Marcar localmente como subido
    final updated = localReport.copyWith(status: 'uploaded');
    await LocalReportStorage.saveToLocalFile(updated, updated.name);
    debugPrint("✓ Reporte marcado localmente como 'uploaded'");
    
    // Invalidar providers
    ref.invalidate(allReportsProvider);

    // Agregar a recientes
    final newSent = {
      "centerName": localReport.center.name,
      "cageName": localReport.cage.name,
      "sentAt": DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('recentlySentReports') ?? '[]';
    final List<dynamic> recents = json.decode(raw);

    recents.add(newSent);
    if (recents.length > 21) {
      recents.removeAt(0);
    }

    await prefs.setString('recentlySentReports', json.encode(recents));
    debugPrint("✓ Reporte añadido a 'recentlySentReports'");

    // Invalidar otros providers
    ref.invalidate(recentlySentProvider);
    await incrementSentCounter();
    ref.invalidate(sentCounterProvider);
    
    debugPrint("✅ Subida completada exitosamente (método web)");
    return true;
  } catch (e) {
    debugPrint("❌❌❌ ERROR EN PROCESO DE SUBIDA (método web): $e");
    
    if (e is PostgrestException) {
      debugPrint("❌ Error de Postgrest: Código ${e.code}, mensaje: ${e.message}, hint: ${e.hint}");
    } else if (e is StorageException) {
      debugPrint("❌ Error de Storage: ${e.message}, statusCode: ${e.statusCode}, error: ${e.error}");
    }
    
    return false;
  }
}

/// Sube una imagen usando firmado de URL para evitar problemas de RLS
Future<String> _uploadImageWithSignedUrl({
  required SupabaseClient supabase,
  required String filePath,
  required String storagePath,
  required void Function(double) onProgress,
}) async {
  final file = File(filePath);
  
  if (!file.existsSync()) {
    throw Exception("No existe el archivo: $filePath");
  }
  
  try {
    debugPrint("🔄 Intentando subir con URL firmada: $storagePath");
    
    // 1. Obtener una URL firmada para subir el archivo
    final signedUrlResult = await supabase.storage.from('report-images')
      .createSignedUploadUrl(storagePath);
    
    final signedUrl = signedUrlResult.signedUrl;
    debugPrint("✓ URL firmada obtenida: ${signedUrl.substring(0, signedUrl.length > 50 ? 50 : signedUrl.length)}...");
    
    // 2. Leer el archivo como bytes
    final bytes = await file.readAsBytes();
    
    // 3. Crear una solicitud HTTP para subir los bytes a la URL firmada
    final response = await http.put(
      Uri.parse(signedUrl),
      headers: {
        'Content-Type': 'application/octet-stream',
        'Content-Length': bytes.length.toString(),
      },
      body: bytes,
    );
    
    // 4. Verificar el resultado
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint("✅ Archivo subido con éxito usando URL firmada");
      onProgress(100);
      return storagePath;
    } else {
      debugPrint("❌ Error al subir con URL firmada: ${response.statusCode}, ${response.body}");
      throw Exception("Error al subir archivo con URL firmada: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("❌ Excepción al subir con URL firmada: $e");
    throw e;
  }
}

/// Sube un reporte usando un servicio externo como proxy
/// Para evitar problemas de RLS en mobile, usamos un backend intermedio
Future<bool> uploadReportUsingProxy(
  Ref ref,
  LocalReport localReport, {
  required void Function(double) onProgress,
}) async {
  double totalProgress = 0;
  
  debugPrint("🚀 Iniciando proceso de subida de reporte (método proxy): ${localReport.name}");
  debugPrint("🔍 Datos del reporte: idGlobal=${localReport.idGlobal}, centro=${localReport.center.name}, jaula=${localReport.cage.name}, imágenes=${localReport.imagenes.length}");

  // Función auxiliar para acumular progreso
  void increment(double inc) {
    totalProgress += inc;
    if (totalProgress > 100) totalProgress = 100;
    onProgress(totalProgress);
    debugPrint("📊 Progreso de subida: $totalProgress%");
  }

  try {
    // (1) Verificar credenciales Supabase para su uso posterior
    final supabase = ref.read(supabaseClientProvider);
    final session = supabase.auth.currentSession;
    if (session == null) {
      throw Exception("No hay sesión activa en Supabase");
    }
    
    // (2) Este método utiliza un enfoque diferente donde:
    // - Primero convertimos todas las imágenes a base64
    // - Enviamos todo al backend en una sola petición
    // - El backend se encarga de la subida a Supabase
    
    final images = localReport.imagenes;
    final encodedImages = <Map<String, dynamic>>[];
    
    // (3) Procesar cada imagen
    debugPrint("📁 Preparando ${images.length} imágenes para subida via proxy...");
    
    for (int i = 0; i < images.length; i++) {
      final imgItem = images[i];
      
      try {
        final imageFile = File(imgItem.img);
        if (!imageFile.existsSync()) {
          debugPrint("⚠️ Imagen ${i+1} no encontrada: ${imgItem.img}");
          
          if (imgItem.id == 1) {
            // Si es la imagen principal, fallamos completamente
            debugPrint("🧹 Eliminando reporte local debido a imagen obligatoria faltante");
            await LocalReportStorage.deleteLocalReport(localReport.name);
            ref.invalidate(allReportsProvider);
            
            final queueNotifier = ref.read(uploadQueueProvider.notifier);
            if (queueNotifier.isReportInQueue(localReport)) {
              queueNotifier.removeReportByName(localReport.name);
            }
            
            throw Exception("No se encontró la imagen principal obligatoria");
          }
          
          // Para otras imágenes, solo las omitimos
          continue;
        }
        
        // Codificar la imagen a base64
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        encodedImages.add({
          'name': imgItem.name,
          'id': imgItem.id,
          'base64': base64Image,
          'type': imageFile.path.endsWith('.jpg') || imageFile.path.endsWith('.jpeg') 
              ? 'image/jpeg' : 'image/png',
        });
        
        increment((60.0 / images.length).toDouble());
        debugPrint("✓ Imagen ${i+1} codificada (${bytes.length} bytes)");
      } catch (e) {
        debugPrint("❌ Error procesando imagen ${i+1}: $e");
        
        if (imgItem.id == 1) {
          // Si es la imagen principal, fallamos completamente
          debugPrint("🧹 Eliminando reporte local debido a error en imagen obligatoria");
          await LocalReportStorage.deleteLocalReport(localReport.name);
          ref.invalidate(allReportsProvider);
          
          final queueNotifier = ref.read(uploadQueueProvider.notifier);
          if (queueNotifier.isReportInQueue(localReport)) {
            queueNotifier.removeReportByName(localReport.name);
          }
          
          throw Exception("Error procesando imagen principal: $e");
        }
      }
    }
    
    // Verificar que tenemos al menos una imagen
    if (encodedImages.isEmpty) {
      throw Exception("No se pudo procesar ninguna imagen válida");
    }
    
    // (4) Crear el payload para el backend
    debugPrint("📦 Preparando datos para enviar al backend proxy...");
    
    final reportData = {
      'token': session.accessToken,
      'userId': session.user.id,
      'enterpriseId': localReport.enterprise,
      'report': {
        'idGlobal': localReport.idGlobal,
        'weight': localReport.weight,
        'shoot': localReport.date,
        'centerId': localReport.center.id,
        'centerName': localReport.center.name,
        'cageName': localReport.cage.name,
        'cageId': localReport.cage.id,
        'userName': localReport.user,
      },
      'images': encodedImages,
    };
    
    // (5) Enviar al backend proxy
    debugPrint("📤 Enviando datos al backend proxy...");
    increment(15); // 75%
    
    // URL del servicio proxy (REEMPLAZAR CON LA URL REAL)
    const proxyUrl = 'https://api.fishbyte.site/upload-report';
    
    // Llamada HTTP al proxy
    final response = await http.post(
      Uri.parse(proxyUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: json.encode(reportData),
    );
    
    increment(15); // 90%
    
    // (6) Procesar respuesta
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint("✅ Reporte subido exitosamente via proxy");
      
      // Actualizar estado local
      final updated = localReport.copyWith(status: 'uploaded');
      await LocalReportStorage.saveToLocalFile(updated, updated.name);
      
      // Actualizar providers
      ref.invalidate(allReportsProvider);
      
      // Agregar a lista de recientes
      final newSent = {
        "centerName": localReport.center.name,
        "cageName": localReport.cage.name,
        "sentAt": DateTime.now().toIso8601String(),
      };
      
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('recentlySentReports') ?? '[]';
      final List<dynamic> recents = json.decode(raw);
      
      recents.add(newSent);
      if (recents.length > 21) {
        recents.removeAt(0);
      }
      
      await prefs.setString('recentlySentReports', json.encode(recents));
      
      // Actualizar otros providers
      ref.invalidate(recentlySentProvider);
      await incrementSentCounter();
      ref.invalidate(sentCounterProvider);
      
      increment(10); // 100%
      return true;
    } else {
      final errorBody = response.body;
      debugPrint("❌ Error en respuesta del proxy: ${response.statusCode}, $errorBody");
      throw Exception("Error en respuesta del proxy: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("❌❌❌ ERROR EN PROCESO DE SUBIDA VIA PROXY: $e");
    return false;
  }
}

/// Obtiene el enterprise_id correcto del usuario desde Supabase
Future<String?> getUserEnterpriseId(SupabaseClient supabase, String userId) async {
  try {
    debugPrint("🔍 Consultando enterprise_id correcto para el usuario $userId...");
    
    // Llamar a la función RPC sugerida por Supabase
    final result = await supabase.rpc('get_user_enterprise_id');
    
    if (result != null) {
      debugPrint("✓ Enterprise ID obtenido: $result");
      return result.toString();
    } else {
      debugPrint("⚠️ No se pudo obtener enterprise_id, response vacía");
      return null;
    }
  } catch (e) {
    debugPrint("❌ Error obteniendo enterprise_id: $e");
    
    // Intentar consulta directa a la tabla users_enterprises si la RPC falla
    try {
      debugPrint("🔄 Intentando consulta directa a tabla users_enterprises...");
      
      final userEnterprise = await supabase
        .from('users_enterprises')
        .select('enterprise_id')
        .eq('user_id', userId)
        .single();
      
      if (userEnterprise != null && userEnterprise['enterprise_id'] != null) {
        final id = userEnterprise['enterprise_id'].toString();
        debugPrint("✓ Enterprise ID obtenido por consulta directa: $id");
        return id;
      }
    } catch (queryError) {
      debugPrint("❌ Error en consulta directa: $queryError");
    }
    
    return null;
  }
}

/// Función alternativa para insertar el reporte y sus imágenes directamente en las tablas
/// sin depender de la función RPC "create_report_and_images"
Future<bool> _insertReportAndImagesDirect({
  required SupabaseClient supabase,
  required String reportId,
  required String userId,
  required String enterpriseId,
  required LocalReport localReport,
  required List<Map<String, String>> uploadedImagePaths,
}) async {
  try {
    debugPrint("📋 Insertando reporte directamente en las tablas...");
    
    // Metadatos como lo hace la web - NOMBRES DE CLAVES EN MINÚSCULAS para coincidencia exacta
    final metadata = {
      "acs": localReport.center.ACS,
      "siep": localReport.center.SIEP,
      "shoot": localReport.date,
      "water": localReport.center.water,
      "labels": null,
      "weight": localReport.weight,
      "cage_id": localReport.cage.id,
      "comment": null,
      "disease": null,
      "species": localReport.center.species,
      "user_id": userId,
      "cageName": localReport.cage.name,
      "category": localReport.center.category,
      "idglobal": "$enterpriseId-$userId-${DateTime.now().toIso8601String()}Z",
      "revisado": false,
      "userName": localReport.user,
      "center_id": localReport.center.id,
      "centerName": localReport.center.name,
      "disease_ai": null, 
      "ai_approved": null,
      "enterprise_id": enterpriseId,
      "enterpriseName": "Lythium",
    };
    
    // 1. Insertar primero en la tabla reports
    final reportData = {
      'id': reportId,
      'enterprise_id': enterpriseId,
      'user_id': userId,
      'center_id': localReport.center.id,
      'cage_id': localReport.cage.id,
      'weight': localReport.weight,
      'shoot': localReport.date,
      'idglobal': metadata["idglobal"], // Usar el mismo que en metadata
      'metadata': metadata,
      'created_at': DateTime.now().toIso8601String(),
      'comment': null,
      'disease': null,
      'disease_ai': null,
      'revisado': false,
    };
    
    debugPrint("💾 Insertando reporte en tabla 'reports'...");
    
    final reportResult = await supabase
      .from('reports')
      .insert(reportData)
      .select();
    
    debugPrint("✓ Reporte insertado: $reportResult");
    
    // 2. Insertar cada imagen en la tabla images
    debugPrint("🖼️ Insertando ${uploadedImagePaths.length} imágenes en tabla 'images'...");
    
    for (final img in uploadedImagePaths) {
      final imageData = {
        'report_id': reportId,
        'storage_path': img['storage_path'],
        'description': img['description'],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final imageResult = await supabase
        .from('images')
        .insert(imageData);
      
      debugPrint("✓ Imagen insertada: ${img['storage_path']}");
    }
    
    debugPrint("✅ Reporte e imágenes insertados correctamente");
    return true;
  } catch (e) {
    debugPrint("❌ Error insertando reporte e imágenes: $e");
    
    if (e is PostgrestException) {
      debugPrint("❌ Postgrest error: ${e.code} - ${e.message}");
      if (e.details != null) debugPrint("❌ Detalles: ${e.details}");
      if (e.hint != null) debugPrint("❌ Sugerencia: ${e.hint}");
    }
    
    return false;
  }
}

