import 'dart:async';
import 'dart:io'; // Para detectar si es Android o iOS
import 'package:camera/camera.dart';
import 'package:fishbyte/domain/usecases/photo_storage_service.dart';
import 'package:fishbyte/presentation/screens/camera_por_dentro/photo_session_provider.dart';
import 'package:fishbyte/presentation/widgets/camera_inside/camera_preview_widget.dart';
import 'package:fishbyte/presentation/widgets/camera_inside/flash_control_widget.dart';
import 'package:fishbyte/presentation/widgets/camera_inside/right_panel_widget.dart';
import 'package:fishbyte/presentation/widgets/camera_inside/summary_screen_widget.dart';
import 'package:fishbyte/presentation/widgets/camera_inside/template_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';


//////////////////////////////////////////////////////////////
// PANTALLA
//////////////////////////////////////////////////////////////
class FishPhotoSessionFullScreen extends ConsumerStatefulWidget {
  const FishPhotoSessionFullScreen({Key? key}) : super(key: key);

  @override
  _FishPhotoSessionFullScreenState createState() =>
      _FishPhotoSessionFullScreenState();
}

class _FishPhotoSessionFullScreenState extends ConsumerState<FishPhotoSessionFullScreen> {
  final _photoStorage = PhotoStorageService();
  
  List<CameraDescription>? _cameras;
  late CameraController _controller;
  late Future<void> _initFuture;
  bool _isInitialized = false;
  bool _isCapturing = false;

  // Flag local para mostrar la cámara o el resumen
  bool _showSummary = false;

  bool _isRetaking = false;
  bool _retakeIsMandatory = false;
  int? _retakeIndex;

  // Texto para los 4 pasos
  final stepInstructions = {
    1: "Imagen General",
    2: "Exponer Branquias",
    3: "Órganos Visibles",
    4: "Órganos Poco Visibles",
  };

  // Imágenes de ejemplo (para las 4 fotos que se toman obligatorios)
  final stepExamples = {
    1: "assets/images/ejemplo1.webp",
    2: "assets/images/ejemplo2.webp",
    3: "assets/images/ejemplo3.webp",
    4: "assets/images/ejemplo4.webp",
  };

  @override
  void initState() {
    super.initState();
    _forceLandscape();
    _initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /////////////////////////////////////////////////////////////
  // ORIENTACIÓN
  /////////////////////////////////////////////////////////////
  Future<void> _forceLandscape() async {
    // Bloquea la app en landscapeRight
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight]);
  }

  /////////////////////////////////////////////////////////////
  // INICIALIZAR CÁMARA
  /////////////////////////////////////////////////////////////
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    final backCam = _cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(
      backCam,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _initFuture = _controller.initialize();
    await _initFuture;

    // Bloquear la orientación de la captura dependiendo de la plataforma
    if (Platform.isIOS) {
      await _controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
    } else {
      await _controller.lockCaptureOrientation(DeviceOrientation.landscapeRight);
      print("Orientación en Android landscapeRight");
    }

    if (!mounted) return;

    setState(() => _isInitialized = true);
  }

  /////////////////////////////////////////////////////////////
  // CAPTURAR FOTO
  /////////////////////////////////////////////////////////////
  Future<void> _takePicture() async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      final draft = ref.read(draftReportProvider);
      if (draft == null) {
        throw Exception("No hay draftReport para este caso!");
      }

      await _initFuture;
      final xfile = await _controller.takePicture();

      if (_isRetaking && _retakeIndex != null) {
        if (_retakeIsMandatory) {
          final path = await _photoStorage.saveMandatory(
            xfile, 
            _retakeIndex! + 1,
            draft.idGlobal,
          );
          ref.read(photoSessionProvider.notifier).replaceMandatory(_retakeIndex!, File(path));
        } else {
          final path = await _photoStorage.saveExtra(
            xfile,
            _retakeIndex!,
            draft.idGlobal,
          );
          ref.read(photoSessionProvider.notifier).replaceExtra(_retakeIndex!, File(path));
        }

        // Salimos de modo retake
        setState(() {
          _isRetaking = false;
          _retakeIsMandatory = false;
          _retakeIndex = null;
          // Volvemos al resumen
          _showSummary = true;
        });
        return;
      }

      // --- Caso “foto nueva” (sin retake) ---
      final s = ref.read(photoSessionProvider);

      if (s.currentStep <= 4) {
        // Foto obligatoria
        final savedPath = await _photoStorage.saveMandatory(
          xfile,
          s.currentStep,
          draft.idGlobal,
        );
        ref.read(photoSessionProvider.notifier).addMandatory(File(savedPath));

        // Si era la 4°, mostramos resumen
        if (s.currentStep == 4) {
          setState(() => _showSummary = true);
        }
      } else {
        // Foto adicional
        final extrasCount = s.extras.length;
        final savedPath = await _photoStorage.saveExtra(
          xfile,
          extrasCount,
          draft.idGlobal,
        );
        ref.read(photoSessionProvider.notifier).addExtra(File(savedPath));
        setState(() => _showSummary = true);
      }
    } catch (e) {
      debugPrint("Error al tomar foto => $e");
    } finally {
      _isCapturing = false;
    }
  }


  /////////////////////////////////////////////////////////////
  // PANTALLA CÁMARA
  /////////////////////////////////////////////////////////////
  Widget _buildCameraScreen() {
    final s = ref.watch(photoSessionProvider);

    // Determinar el step a mostrar en la UI
    int displayStep;
    if (_isRetaking) {
      if (_retakeIsMandatory) {
        // Retomando foto obligatoria => step = index+1
        displayStep = _retakeIndex! + 1;
      } else {
        // Retomando foto extra => forzamos step > 4, p.ej 20, para NO mostrar plantilla
        displayStep = 20;
      }
    } else {
      // Modo normal => s.currentStep
      displayStep = s.currentStep;
    }

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            // Vista de la cámara
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 10,
                    child: FlashToggleButton(controller: _controller),
                  ),
                  BuildCameraPreviewWidget(controller: _controller),
                  // Mostrar overlay sólo si displayStep está entre 1..4
                  if (displayStep >= 1 && displayStep <= 4)
                    Positioned.fill(child: BuildTemplateOverlay(step: displayStep)),
                ],
              ),
            ),
            // Panel lateral
            Expanded(
              flex: 1,
              child: RightPanelWidget(
                displayStep: displayStep,
                isRetaking: _isRetaking,
                retakeIsMandatory: _retakeIsMandatory,
                retakeIndex: _retakeIndex,
                isCapturing: _isCapturing,
                stepInstructions: stepInstructions,
                stepExamples: stepExamples,
                onTakePicture: _takePicture,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  /////////////////////////////////////////////////////////////
  // BUILD
  /////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    // Mostramos resumen solo si _showSummary = truInvisaligne
     if (_showSummary) {
      final s = ref.watch(photoSessionProvider);
      return SummaryScreenWidget(
        mandatory: s.mandatory,
        extras: s.extras,
        stepInstructions: stepInstructions,
        onShowSummaryChanged: (value) => setState(() => _showSummary = value),
        onRetakePhoto: (isRetaking, isMandatory, index) {
          setState(() {
            _isRetaking = isRetaking;
            _retakeIsMandatory = isMandatory;
            _retakeIndex = index;
            _showSummary = false;
          });
        },
      );
    } else {
      return _buildCameraScreen();
    }
  }
}
