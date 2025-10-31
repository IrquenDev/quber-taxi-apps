import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quber_taxi/enums/face_detector_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
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
  bool _hasValidImageForCurrentFace = false;

  int _faceDetectedCount = 0;
  int _noFaceCount = 0;
  static const int _requiredFrames = 5;

  Uint8List? _capturedImageBytes;

  void _showCameraPermissionPermanentlyDeniedDialog() {
    if (!mounted) return;

    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.cameraPermissionPermanentlyDeniedTitle),
          content: Text(localization.cameraPermissionPermanentlyDeniedMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(CommonRoutes.login);
              },
              child: Text(localization.cancelButton),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
                if (context.mounted) {
                  context.go(CommonRoutes.login);
                }
              },
              child: Text(localization.goToSettingsButton),
            ),
          ],
        );
      },
    );
  }

  void _showImageProcessingErrorDialog() {
    if (!mounted) return;

    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.imageProcessingErrorTitle),
          content: Text(localization.imageProcessingErrorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(CommonRoutes.login);
              },
              child: Text(localization.acceptButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkCameraPermission() async {
    final permission = await Permission.camera.status;

    if (permission.isPermanentlyDenied) {
      _showCameraPermissionPermanentlyDeniedDialog();
      return;
    }

    if (permission.isDenied) {
      final result = await Permission.camera.request();
      if (result.isPermanentlyDenied) {
        _showCameraPermissionPermanentlyDeniedDialog();
        return;
      } else if (result.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cameraPermissionDenied),
              duration: const Duration(seconds: 3),
            ),
          );
          context.go(CommonRoutes.login);
        }
        return;
      }
    }

    // Permission granted, proceed with camera initialization
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
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
        ),
      );

      _cameraController.startImageStream((image) => _processImage(image));

      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _showImageProcessingErrorDialog();
    }
  }

  Future<void> _init() async {
    await _checkCameraPermission();
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

        // SECURITY: Only proceed if face is detected AND valid blink
        // Verify that we have real eye probabilities (not default values)
        final hasValidEyeData = face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null;

        // Verify face has reasonable minimum size (not noise)
        final faceSize = face.boundingBox.width * face.boundingBox.height;
        final imageSize = inputImage.metadata!.size.width * inputImage.metadata!.size.height;
        final faceSizeRatio = faceSize / imageSize;
        final hasValidFaceSize = faceSizeRatio > 0.02; // At least 2% of image

        // Verify face is centered
        final imageWidth = inputImage.metadata!.size.width;
        final imageHeight = inputImage.metadata!.size.height;
        final faceCenterX = face.boundingBox.left + (face.boundingBox.width / 2);
        final faceCenterY = face.boundingBox.top + (face.boundingBox.height / 2);
        final imageCenterX = imageWidth / 2;
        // Adjust center Y to be lower in the image (70% down instead of 50%)
        final imageCenterY = imageHeight * 0.7;

        // Calculate distance from face center to adjusted image center
        final distanceFromCenter =
            ((faceCenterX - imageCenterX).abs() / imageWidth) + ((faceCenterY - imageCenterY).abs() / imageHeight);
        final isFaceCentered = distanceFromCenter < 0.3; // Allow up to 30% deviation from adjusted center

        // Debug: positioning information
        if (kDebugMode && !isFaceCentered) {
          debugPrint('Face not centered - Distance from center: ${(distanceFromCenter * 100).toStringAsFixed(1)}%');
        }

        // Take photo when valid face is detected (only if we don't have one already)
        if (status == FaceDetectorState.faceDetected &&
            hasValidEyeData &&
            hasValidFaceSize &&
            isFaceCentered &&
            !_hasValidImageForCurrentFace) {
          try {
            final XFile file = await _cameraController.takePicture();
            _capturedImageBytes = await file.readAsBytes();
            _hasValidImageForCurrentFace = true;
            debugPrint('Image captured for centered and detected face');
          } catch (e) {
            debugPrint('Error capturing image: $e');
            await _cameraController.stopImageStream();
            _showImageProcessingErrorDialog();
            return;
          }
        }

        // Verify blink only if we already have a valid image
        if (status == FaceDetectorState.faceDetected &&
            hasValidEyeData &&
            hasValidFaceSize &&
            isFaceCentered &&
            _hasValidImageForCurrentFace &&
            (left < 0.7 || right < 0.7)) {
          setState(() {
            status = FaceDetectorState.blinkDetected;
            _isProcessing = true;
          });
          _progressController.forward();
        } else if (_faceDetectedCount >= _requiredFrames &&
            status == FaceDetectorState.waitingFace &&
            hasValidEyeData &&
            hasValidFaceSize &&
            isFaceCentered) {
          setState(() => status = FaceDetectorState.faceDetected);
          // Reset image flag when entering detection mode
          _hasValidImageForCurrentFace = false;
          _capturedImageBytes = null;
        }
      } else {
        // If no face, discard captured image and reset state
        if (_hasValidImageForCurrentFace) {
          _capturedImageBytes = null;
          _hasValidImageForCurrentFace = false;
          debugPrint('Face lost - image discarded');
        }

        _faceDetectedCount = 0;
        _noFaceCount++;

        if (_noFaceCount >= _requiredFrames && status == FaceDetectorState.faceDetected) {
          setState(() => status = FaceDetectorState.waitingFace);
        }
      }
    } catch (e) {
      await _cameraController.stopImageStream();
      _showImageProcessingErrorDialog();
      return;
    }

    _isDetecting = false;
  }

  Widget _buildFaceDetectionSheet(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return SizedBox(
      height: status == FaceDetectorState.notSupportedCamera ? 220 : 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(dimensions.cardBorderRadiusMedium),
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(dimensions.cardBorderRadiusMedium),
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
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            if (status == FaceDetectorState.notSupportedCamera)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go(CommonRoutes.login);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(AppLocalizations.of(context)!.goBackButton),
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
    final localization = AppLocalizations.of(context)!;
    switch (status) {
      case FaceDetectorState.waitingFace:
        return localization.faceDetectionStep;
      case FaceDetectorState.faceDetected:
        return localization.livenessDetectionStep;
      case FaceDetectorState.blinkDetected:
        return localization.selfieCapturingStep;
      case FaceDetectorState.notSupportedCamera:
        return localization.compatibilityErrorTitle;
    }
  }

  String _getDescription() {
    final localization = AppLocalizations.of(context)!;
    switch (status) {
      case FaceDetectorState.waitingFace:
        return localization.faceDetectionInstruction;
      case FaceDetectorState.faceDetected:
        return localization.livenessDetectionInstruction;
      case FaceDetectorState.blinkDetected:
        return localization.selfieProcessingInstruction;
      case FaceDetectorState.notSupportedCamera:
        return localization.deviceNotCompatibleMessage;
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

          if (_capturedImageBytes == null) {
            _showImageProcessingErrorDialog();
            return;
          }

          try {
            await _cameraController.stopImageStream();
            if (!mounted) return;
            context.push(CommonRoutes.faceIdConfirmed, extra: _capturedImageBytes);
          } catch (e) {
            debugPrint('Error navigating to confirmation: $e');
            _showImageProcessingErrorDialog();
          }
        });
      }
    });

    _init();
  }

  @override
  void dispose() {
    try {
      _progressController.dispose();
      _cameraController.dispose();
      _faceDetector.close();
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }
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
                  child: Image.asset('assets/images/image_scan.png',
                      fit: BoxFit.contain, width: MediaQuery.of(context).size.width),
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
