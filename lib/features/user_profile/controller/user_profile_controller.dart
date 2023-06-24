import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/commons/common.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/core/utils.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  final storageAPI = ref.watch(storageAPIProvider);
  final userAPI = ref.watch(userAPIProvider);
  return UserProfileController(
    tweetAPI: tweetAPI,
    storageAPI: storageAPI,
    userAPI: userAPI,
  );
});

final getUserTweetsProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  UserProfileController({
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required UserAPI userAPI,
  })  : _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        super(false);

  Future<List<Tweet>> getUserTweets(String uid) async {
    final tweets = await _tweetAPI.getUserTweets(uid);
    return tweets.map((e) => Tweet.fromMap(e.data)).toList();
  }

  void updateUserProfile({
    required UserModel user,
    required BuildContext context,
    required File? bannerFile,
    required File? profilePicFile,
  }) async {
    state = true;
    // UserModel userModelData;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImages([bannerFile]);
      user = user.copyWith(bannerPic: bannerUrl[0]);
    }

    if (profilePicFile != null) {
      final profilePicUrl = await _storageAPI.uploadImages([profilePicFile]);
      user = user.copyWith(profilePic: profilePicUrl[0]);
    }

    final res = await _userAPI.updateUserData(user);
    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => Navigator.pop(context),
    );
  }

  void followUser({
    required UserModel user,
    required UserModel currentUser,
    required BuildContext context,
  }) async {
    if (currentUser.followers.contains(user.uid)) {
      //already following
      user.followers.remove(currentUser.uid);
      currentUser.followings.remove(user.uid);
    } else {
      //not following
      user.followers.add(currentUser.uid);
      currentUser.followings.add(user.uid);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(followings: currentUser.followings);

    final res = await _userAPI.followUser(user);
    res.fold(
      (l) => ErrorText(error: l.message),
      (r) async {
        final res2 = await _userAPI.addToFollowing(currentUser);
        res2.fold((l) => ErrorText(error: l.message), (r) => null);
      },
    );
  }
}
