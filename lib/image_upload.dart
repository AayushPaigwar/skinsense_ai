import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();

  // Capture image from camera
  static Future<Uint8List?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        // Verify the image file exists and is valid
        final file = File(image.path);
        if (await file.exists()) {
          final bytes = await image.readAsBytes();
          if (bytes.isNotEmpty) {
            return bytes;
          }
        }
      }
      return null;
    } catch (e) {
      log('Error capturing image: $e');
      return null;
    }
  }

  // Pick image from gallery
  static Future<Uint8List?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85, // Slightly higher quality
      );

      if (image != null) {
        // Verify the image file exists and is valid
        final file = File(image.path);
        if (await file.exists()) {
          final bytes = await image.readAsBytes();
          if (bytes.isNotEmpty) {
            return bytes;
          }
        }
      }
      return null;
    } catch (e) {
      log('Error picking image: $e');
      return null;
    }
  }

  // Validate if bytes represent a valid image
  static bool isValidImageBytes(Uint8List bytes) {
    if (bytes.isEmpty) return false;

    // Check for common image file signatures
    // JPEG: FF D8 FF
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return true;
    }

    // PNG: 89 50 4E 47
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }

    return false;
  }
}
