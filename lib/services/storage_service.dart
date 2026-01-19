import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      throw Exception('Failed to take photo: ${e.toString()}');
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      String fileName = 'product_$productId${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage
          .ref()
          .child(AppConstants.productImagesPath)
          .child(fileName);

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }

  // Save image locally
  Future<String> saveImageLocally(XFile imageFile, String productId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDir.path}/product_images';
      
      // Create directory if it doesn't exist
      final Directory imageDir = Directory(localPath);
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      String fileName = 'product_$productId${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '$localPath/$fileName';
      
      // Copy file to local storage
      await File(imageFile.path).copy(filePath);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to save image locally: ${e.toString()}');
    }
  }

  // Delete local image
  Future<void> deleteLocalImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete local image: ${e.toString()}');
    }
  }

  // Get local images directory
  Future<String> getLocalImagesDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/product_images';
  }
}
