import 'dart:ffi';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart';
import 'package:uuid/v4.dart';

class StorageService {
  final String STORAGE_DIRECTORY = 'shared_item_images';
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadImage(String imagePath) async {
    String randomId = const UuidV4().generate();
    File sourceImage = File(imagePath);
    Reference imageRef = storage.ref().child(STORAGE_DIRECTORY).child('/$randomId.jpg');
    Image? sourceImageObj = decodeImage(sourceImage.readAsBytesSync());

    if (sourceImageObj == null) {
      throw Exception("Cannot decode image");
    }

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'path': imagePath
      }
    );

    // Resize image to be smaller
    Image destImageObj = copyResize(sourceImageObj, width: 120);

    imageRef.putData(encodeJpg(destImageObj), metadata);

    return imageRef.fullPath;
  }

  Future<String> getImageUrlOfSharedItem(String imagePath) {
    return storage.ref().child(imagePath).getDownloadURL();
  }
}