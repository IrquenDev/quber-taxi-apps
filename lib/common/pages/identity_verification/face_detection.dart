import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:quber_taxi/enums/face_detector_state.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/util/image_utils.dart';


class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  FaceDetectionPageState createState() => FaceDetectionPageState();
}

class FaceDetectionPageState extends State<FaceDetectionPage> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  FaceDetectorState status = FaceDetectorState.waitingFace;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

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
      ),
    );

    _cameraController.startImageStream((image) => _processImage(image));

    setState(() {
      _cameraInitialized = true;
    });
  }

  void _processImage(CameraImage image) async {
    if (_isDetecting) return;
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
          format: InputImageFormat.nv21, // Always nv21 because we converted it
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final left = face.leftEyeOpenProbability ?? 1.0;
        final right = face.rightEyeOpenProbability ?? 1.0;

        if (left < 0.4 && right < 0.4) {
          setState(() => status = FaceDetectorState.blinkDetected);

          Future.microtask(() async {
            if (!mounted) return;
            await _cameraController.stopImageStream();
            if (!mounted) return;
            context.go(CommonRoutes.faceIdConfirmed);
          });

        } else {
          setState(() => status = FaceDetectorState.faceDetected);
        }
      } else {
        setState(() => status = FaceDetectorState.waitingFace);
      }
    } catch (e) {
      setState(() => status = FaceDetectorState.notSupportedCamera);
    }

    _isDetecting = false;
  }

  @override
  void dispose() {
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
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}