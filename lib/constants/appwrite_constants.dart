class AppwriteConstants {
  static const String databaseId = '646f147985828a1d1a3d';
  static const String projectId = '646f0b7f1abb303dbb10';
  // static const String endpoint = 'http://192.168.1.70/v1';
  static const String endpoint = 'http://10.0.2.2/v1';

  static const String userCollectionId = '64745253c814345c8071';
  static const String tweetCollectionId = '64804d924157c95507c7';
  static const String imageBucketId = '6480553a507101132621';

  static imageUrl(String imageId) =>
      '$endpoint/storage/buckets/$imageBucketId/files/$imageId/view?project=$projectId&mode=admin';
}
