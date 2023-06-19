import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/core/providers.dart';

abstract class IStorageAPI {
  Future<List<String>> uploadImages(List<File> files);
  // Future<String> uploadImage(File file);
}

final storageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageprovider));
});

class StorageAPI implements IStorageAPI {
  final Storage _storage;

  StorageAPI({required Storage storage}) : _storage = storage;

  @override
  Future<List<String>> uploadImages(List<File> files) async {
    List<String> imageLinks = [];
    for (final file in files) {
      final uploadedImage = await _storage.createFile(
        bucketId: AppwriteConstants.imageBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );
      imageLinks.add(AppwriteConstants.imageUrl(uploadedImage.$id));
    }
    return imageLinks;
  }

  // @override
  // Future<String> uploadImage({
  //   required File file,
  //   required UserModel userModel,
  // }) async {
  //   var uploadedFile = await _storage.createFile(
  //     bucketId: AppwriteConstants.imageBucketId,
  //     fileId: '\$id',
  //     file: InputFile.fromPath(path: file.path),
  //   );

  //   return uploadedFile.name;
  // }
}
