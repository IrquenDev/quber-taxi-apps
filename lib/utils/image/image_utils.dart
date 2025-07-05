import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Converts an image from YUV420 format to NV21 format.
///
/// This conversion is needed for certain face detection libraries that expect
/// input in NV21 format rather than YUV420. It assumes the image is in
/// YUV_420_888 format and accesses each plane accordingly.
///
/// - Y plane is copied directly.
/// - U and V planes are interleaved as VU for NV21 compatibility.
///
/// Example use:
/// ```dart
/// final nv21Data = convertYUV420toNV21(cameraImage);
/// ```
///
/// Warning: Make sure this is only used with images that have three planes (Y, U, V).
Uint8List convertYUV420toNV21(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

  final ySize = width * height;
  final uvSize = width * height ~/ 2;
  final nv21 = Uint8List(ySize + uvSize);

  // Copy Y (luminance) data into the first part of the output
  var pos = 0;
  for (int i = 0; i < height; i++) {
    nv21.setRange(
      pos,
      pos + width,
      image.planes[0].bytes,
      i * image.planes[0].bytesPerRow,
    );
    pos += width;
  }

  // Interleave V and U data to form NV21's chroma layout
  final uvPlaneU = image.planes[1].bytes;
  final uvPlaneV = image.planes[2].bytes;

  for (int i = 0; i < height ~/ 2; i++) {
    int uvPos = i * uvRowStride;
    for (int j = 0; j < width ~/ 2; j++) {
      nv21[pos++] = uvPlaneV[uvPos]; // V component
      nv21[pos++] = uvPlaneU[uvPos]; // U component
      uvPos += uvPixelStride;
    }
  }

  return nv21;
}

/// Maps an Android raw image format (e.g., NV21 or YUV_420_888)
/// to the corresponding `InputImageFormat` enum.
///
/// Returns `null` for unsupported formats. This mapping is required for
/// MLKit’s image input to recognize the correct format.
///
/// Example:
/// ```dart
/// final format = mapRawFormatToInputImageFormat(cameraImage.format.raw);
/// if (format != null) {
///   // Proceed with InputImage creation
/// }
/// ```
InputImageFormat? mapRawFormatToInputImageFormat(int rawFormat) {
  switch (rawFormat) {
    case 17: // NV21
      return InputImageFormat.nv21;
    case 35: // YUV_420_888
      return InputImageFormat.yuv420;
    default:
      return null; // Format not supported
  }
}

/// Fixes the orientation of a given JPEG image based on EXIF metadata.
///
/// Useful when receiving image bytes from camera plugins or gallery
/// where rotation is incorrectly handled or ignored.
///
/// Example:
/// ```dart
/// final correctedBytes = fixImageOrientation(imageBytes);
/// ```
///
/// If no orientation metadata is found or decoding fails,
/// returns the original image data as-is.
Uint8List fixImageOrientation(Uint8List imageData) {
  // Decode the image using the `image` package
  final originalImage = img.decodeImage(imageData);
  if (originalImage == null) return imageData;

  // Apply baked orientation based on EXIF metadata
  final fixedImage = img.bakeOrientation(originalImage);

  return Uint8List.fromList(img.encodeJpg(fixedImage));
}