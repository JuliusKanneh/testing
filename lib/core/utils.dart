import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackbar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

String getNameFromEmail(String email) {
  ///julius.k@gmail.com => julius.k
  return email.split('@')[0];
}

Future<List<File>> pickImages() async {
  List<File> images = [];
  ImagePicker imagePicker = ImagePicker();
  final imageFiles = await imagePicker.pickMultiImage();
  if (imageFiles.isNotEmpty) {
    for (final image in imageFiles) {
      images.add(File(image.path));
    }
  }
  return images;
}
