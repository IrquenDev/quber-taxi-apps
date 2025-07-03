import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Converts an image from YUV420 format to NV21 format.
/// This is required for compatibility in the face detection processing
Uint8List convertYUV420toNV21(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

  final ySize = width * height;
  final uvSize = width * height ~/ 2;
  final nv21 = Uint8List(ySize + uvSize);

  // Copy Y plane
  var pos = 0;
  for (int i = 0; i < height; i++) {
    nv21.setRange(pos, pos + width, image.planes[0].bytes, i * image.planes[0].bytesPerRow);
    pos += width;
  }

  // Copy UV planes interleaved as VU
  final uvPlaneU = image.planes[1].bytes;
  final uvPlaneV = image.planes[2].bytes;

  for (int i = 0; i < height ~/ 2; i++) {
    int uvPos = i * uvRowStride;
    for (int j = 0; j < width ~/ 2; j++) {
      nv21[pos++] = uvPlaneV[uvPos];   // V
      nv21[pos++] = uvPlaneU[uvPos];   // U
      uvPos += uvPixelStride;
    }
  }
  return nv21;
}

/// Maps a raw image format integer (e.g., from Android camera APIs)
/// to a supported `InputImageFormat` enum value.
/// Returns `null` if the format is not supported by the image processing pipeline.
/// This is required for compatibility in the face detection processing
InputImageFormat? mapRawFormatToInputImageFormat(int rawFormat) {
  switch (rawFormat) {
    case 17: // NV21
      return InputImageFormat.nv21;
    case 35: // YUV_420_888
      return InputImageFormat.yuv420;
    default:
      return null; // Not Supported
  }
}