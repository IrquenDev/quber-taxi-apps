import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:quber_taxi/enums/face_detector_state.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/utils/image/image_utils.dart';

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  FaceDetectionPageState createState() => FaceDetectionPageState();
}

class FaceDetectionPageState extends State<FaceDetectionPage> with TickerProviderStateMixin {

  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  bool _isDetecting = false;
  FaceDetectorState status = FaceDetectorState.waitingFace;
  bool _cameraInitialized = false;
  bool _isProcessing = false;

  int _faceDetectedCount = 0;
  int _noFaceCount = 0;
  static const int _requiredFrames = 5;

  Uint8List? _capturedImageBytes;

  Future<void> _init() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.1,
      ),
    );

    _cameraController.startImageStream((image) => _processImage(image));

    setState(() {
      _cameraInitialized = true;
    });
  }

  void _processImage(CameraImage image) async {
    if (_isDetecting || _isProcessing) return;
    _isDetecting = true;

    try {
      final format = mapRawFormatToInputImageFormat(image.format.raw);
      if (format == null) {
        setState(() => status = FaceDetectorState.notSupportedCamera);
        _isDetecting = false;
        return;
      }

      Uint8List bytes;
      if (format == InputImageFormat.yuv420) {
        bytes = convertYUV420toNV21(image);
      } else {
        final WriteBuffer allBytes = WriteBuffer();
        for (Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        bytes = allBytes.done().buffer.asUint8List();
      }

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotationValue.fromRawValue(
            _cameraController.description.sensorOrientation,
          ) ??
              InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        _noFaceCount = 0;
        _faceDetectedCount++;

        final face = faces.first;
        final left = face.leftEyeOpenProbability ?? 1.0;
        final right = face.rightEyeOpenProbability ?? 1.0;

        if (status == FaceDetectorState.faceDetected &&
            left < 0.3 && right < 0.3) {
          setState(() {
            status = FaceDetectorState.blinkDetected;
            _isProcessing = true;
          });
          try {
            final XFile file = await _cameraController.takePicture();
            _capturedImageBytes = await file.readAsBytes();
            _progressController.forward();
          } catch (e) {
            debugPrint('Error al capturar imagen: $e');
            setState(() => status = FaceDetectorState.notSupportedCamera);
          }
        } else if (_faceDetectedCount >= _requiredFrames &&
            status == FaceDetectorState.waitingFace) {
          setState(() => status = FaceDetectorState.faceDetected);
        }
      } else {
        _faceDetectedCount = 0;
        _noFaceCount++;

        if (_noFaceCount >= _requiredFrames &&
            status == FaceDetectorState.faceDetected) {
          setState(() => status = FaceDetectorState.waitingFace);
        }
      }
    } catch (e) {
      setState(() => status = FaceDetectorState.notSupportedCamera);
    }

    _isDetecting = false;
  }

  Widget _buildFaceDetectionSheet(BuildContext context) {
    return SizedBox(
      height: status == FaceDetectorState.notSupportedCamera ? 220 : 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    _getTitle(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getDescription(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            if (status == FaceDetectorState.notSupportedCamera)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text("Regresar"),
                                ),
                              ),
                            SizedBox(
                              height: MediaQuery.of(context).padding.bottom,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (status) {
      case FaceDetectorState.waitingFace:
        return "1. Detección de rostro";
      case FaceDetectorState.faceDetected:
        return "2. Detección de vida";
      case FaceDetectorState.blinkDetected:
        return "3. Captura de selfie";
      case FaceDetectorState.notSupportedCamera:
        return "Error de compatibilidad";
      }
  }

  String _getDescription() {
    switch (status) {
      case FaceDetectorState.waitingFace:
        return "Le aconsejamos que coloque su rostro en la zona indicada.";
      case FaceDetectorState.faceDetected:
        return "Le aconsejamos que no actúe de forma rígida, sin pestañear o respirar de manera natural, para asegurar una detección precisa del rostro.";
      case FaceDetectorState.blinkDetected:
        return "Nuestra inteligencia artificial está procesando la selfie. Por favor, manténgase conectado a internet y evite cerrar la aplicación.";
      case FaceDetectorState.notSupportedCamera:
        return "Su dispositivo no es compatible con la verificación facial. Por favor, contacte con soporte técnico o intente con otro dispositivo.";
    }
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.addListener(() {
      setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.microtask(() async {
          if (!mounted) return;
          await _cameraController.stopImageStream();
          if (!mounted) return;
          context.push(CommonRoutes.faceIdConfirmed, extra: _capturedImageBytes);
        });
      }
    });

    _init();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraInitialized
          ? Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController.value.previewSize!.height,
                height: _cameraController.value.previewSize!.width,
                child: CameraPreview(_cameraController),
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/image_scan.png',
              fit: BoxFit.contain,
            ),
          ),
          if (status == FaceDetectorState.blinkDetected)
            Positioned(
              left: 0,
              right: 0,
              bottom: status == FaceDetectorState.notSupportedCamera ? 240 : 180,
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(225),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFaceDetectionSheet(context),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}