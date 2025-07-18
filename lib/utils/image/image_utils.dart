import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

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

/// Compresses an [XFile] image to ensure it does not exceed the specified [targetSizeInMB].
///
/// If the image is already below the target size, it returns the original image.
/// Otherwise, it compresses the image in a background isolate and returns a new [XFile].
///
/// This method prevents blocking the UI by offloading heavy processing via [compute].
Future<XFile?> compressXFileToTargetSize(XFile original, double targetSizeInMB) async {
  final originalFile = File(original.path);
  final maxBytes = (targetSizeInMB * 1024 * 1024).toInt(); // Convert MB to bytes
  // If already within size limits, no compression is needed
  if (await originalFile.length() <= maxBytes) {
    return original;
  }
  // Obtain the temporary directory once in the main isolate
  final tempDir = await getTemporaryDirectory();
  // Launch compression in a background isolate
  final path = await compute(_compressImageInIsolate, {
    'path': original.path,
    'maxBytes': maxBytes,
    'tempDirPath': tempDir.path,
  });
  // If compression fails or image is invalid
  if (path == null) return null;
  // Return a new XFile pointing to the compressed image path
  return XFile(path);
}

/// Runs in a background isolate to compress an image located at [path],
/// reducing its size until it's under [maxBytes]. Uses the provided [tempDirPath]
/// to store the compressed result.
///
/// This isolate must not call any platform channels like `getTemporaryDirectory()`.
Future<String?> _compressImageInIsolate(Map<String, dynamic> args) async {
  final String path = args['path'];
  final int maxBytes = args['maxBytes'];
  final String tempDirPath = args['tempDirPath'];
  final bytes = await File(path).readAsBytes();
  // Decode the image using the image package
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  // Generate the path for the compressed image
  final targetPath = join(tempDirPath, "compressed_${basename(path)}");
  int quality = 95;
  const int minQuality = 10;
  File? compressedFile;
  // Try progressively lower qualities until size condition is met
  while (quality >= minQuality) {
    final encoded = img.encodeJpg(image, quality: quality);
    final file = await File(targetPath).writeAsBytes(encoded);
    if (file.lengthSync() <= maxBytes) {
      compressedFile = file;
      break;
    }
    quality -= 5;
  }
  // If all quality reductions fail, resize the image by half and save with lowest quality
  if (compressedFile == null) {
    final resized = img.copyResize(image, width: image.width ~/ 2);
    final finalEncoded = img.encodeJpg(resized, quality: minQuality);
    compressedFile = await File(targetPath).writeAsBytes(finalEncoded);
  }
  return compressedFile.path;
}