import 'package:flutter/material.dart';
import 'package:twitter_clone/theme/pallete.dart';

class FollowCount extends StatelessWidget {
  final int count;
  final String text;
  const FollowCount({
    super.key,
    required this.count,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    const double fontSize = 18;
    return Row(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Pallete.whiteColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Pallete.greyColor,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
