import 'dart:developer';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controllers/auth_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetProvider),
    storageAPI: ref.watch(StorageAPIProvider),
  );
});

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

class TweetController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final Ref _ref;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final tweets = await _tweetAPI.getTweets();
    return tweets.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
  }) {
    if (text.isEmpty) {
      showSnackbar(context, 'Please enter text');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(images: images, text: text, context: context);
    } else {
      _shareTextTweet(text: text, context: context);
    }
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHashTagFromText(text);
    final link = _getLinkFromText(text);
    final user = _ref.watch(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImages(images);

    log('UserID: ${user.uid}');
    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      tweetTypes: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: ID.unique(),
      uid: user.uid,
      reshareCount: 0,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;
    res.fold((l) => Failure(l.message, l.stackTrace), (r) => null);
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHashTagFromText(text);
    final link = _getLinkFromText(text);
    final user = _ref.watch(currentUserDetailsProvider).value!;

    // log('User ID: ${user.uid}');
    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      tweetTypes: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      uid: user.uid,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) => null);
  }

  String _getLinkFromText(String text) {
    List<String> wordsInSentence = text.split(' ');
    String link = "";

    for (String word in wordsInSentence) {
      if (word.startsWith('https://') || word.startsWith('www.')) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHashTagFromText(String text) {
    List<String> hashtags = [];
    List<String> wordsInSentence = text.split(' ');

    for (String word in wordsInSentence) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }

    return hashtags;
  }
}
