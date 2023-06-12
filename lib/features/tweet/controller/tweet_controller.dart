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
import 'package:twitter_clone/models/user_model.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(StorageAPIProvider),
  );
});

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getRepliesToTweetProvider = FutureProvider.family((
  ref,
  Tweet tweet,
) async {
  return ref.watch(tweetControllerProvider.notifier).getRepliesToTweet(tweet);
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

final getTweetByIdProvider = FutureProvider.family((ref, String id) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetById(id);
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

  void likeTweet(Tweet tweet, UserModel user) async {
    List<String> likes = tweet.likes;
    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }

    tweet.copyWith(likes: likes);
    final res = await _tweetAPI.likeTweet(tweet);
    res.fold((l) => null, (r) => null);
  }

  void reshareTweet(
    Tweet tweet,
    UserModel currentUser,
    BuildContext context,
  ) async {
    tweet = tweet.copyWith(
      retweetedBy: currentUser.name,
      likes: [],
      commentIds: [],
      tweetedAt: DateTime.now(),
      reshareCount: tweet.reshareCount + 1,
    );

    final res = await _tweetAPI.updateReshareCount(tweet);

    res.fold((l) => showSnackbar(context, l.message), (r) async {
      tweet = tweet.copyWith(
        id: ID.unique(),
        reshareCount: 0,
      );

      final res2 = await _tweetAPI.shareTweet(tweet);

      res2.fold(
        (l) => showSnackbar(context, l.message),
        (r) => showSnackbar(
          context,
          'Retweeted',
        ),
      );
    });
  }

  Future<List<Tweet>> getRepliesToTweet(Tweet tweet) async {
    final documents = await _tweetAPI.getRepliesToTweet(tweet);
    return documents.map((e) => Tweet.fromMap(e.data)).toList();
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
  }) {
    if (text.isEmpty) {
      showSnackbar(context, 'Please enter text');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
      );
    } else {
      _shareTextTweet(
        text: text,
        context: context,
        repliedTo: repliedTo,
      );
    }
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
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
      retweetedBy: '',
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;
    res.fold((l) => Failure(l.message, l.stackTrace), (r) => null);
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
    required String repliedTo,
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
      retweetedBy: '',
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) => null);
  }

  Future<Tweet> getTweetById(String id) async {
    final tweet = await _tweetAPI.getTweetById(id);
    return Tweet.fromMap(tweet.data);
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
