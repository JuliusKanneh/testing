import 'package:flutter/material.dart';
import 'package:twitter_clone/features/user_profile/view/view_profile_view.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

class SearchTile extends StatelessWidget {
  final UserModel userModel;
  const SearchTile({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    void onTap() {
      Navigator.push(context, UserProfileView.route(userModel));
    }

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userModel.profilePic),
        radius: 30,
      ),
      title: Text(
        userModel.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${userModel.name}',
            style: const TextStyle(
              fontSize: 16,
              color: Pallete.greyColor,
            ),
          ),
          Text(
            userModel.bio,
            style: const TextStyle(
              fontSize: 16,
              color: Pallete.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
