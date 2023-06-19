import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/commons/common.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/widget/user_profile.dart';
import 'package:twitter_clone/models/user_model.dart';

class UserProfileView extends ConsumerWidget {
  static route(UserModel userModel) => MaterialPageRoute(
        builder: (context) => UserProfileView(userModel: userModel),
      );

  final UserModel userModel;
  const UserProfileView({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUserModel = userModel;

    return ref.watch(getLatestUserProfileDataProvider).when(
          data: (data) {
            log('Subscription Event: ${data.events.first}');
            if (data.events.contains(
                'databases.*.collections.${AppwriteConstants.userCollectionId}.documents.${copyOfUserModel.uid}.update')) {
              {
                copyOfUserModel = UserModel.fromMap(data.payload);
              }
            }
            return Scaffold(
              body: UserProfile(user: copyOfUserModel),
            );
          },
          error: (error, st) => Scaffold(
            body: ErrorText(error: error.toString()),
          ),
          loading: () {
            log('Loading here');
            return Scaffold(
              body: UserProfile(user: copyOfUserModel),
            );
          },
        );
    // Scaffold(
    //   body: ref.watch(getLatestUserProfileDataProvider).when(
    //         data: (data) {
    //           log('Subscription Event: ${data.events.first}');
    //           if (data.events.contains(
    //               'databases.*.collections.${AppwriteConstants.userCollectionId}.documents.${copyOfUserModel.uid}.update')) {
    //             {
    //               copyOfUserModel = UserModel.fromMap(data.payload);
    //             }
    //           }
    //           return UserProfile(user: copyOfUserModel);
    //         },
    //         error: (error, st) => ErrorText(error: error.toString()),
    //         loading: () {
    //           log('Loading here');
    //           return UserProfile(user: copyOfUserModel);
    //         },
    //       ),
    // );
  }
}
