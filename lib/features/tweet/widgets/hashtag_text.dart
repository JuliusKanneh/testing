import 'package:flutter/material.dart';
import 'package:twitter_clone/theme/theme.dart';

class HashTagText extends StatelessWidget {
  final String text;
  const HashTagText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = [];
    text.split(' ').forEach((element) {
      if (element.startsWith('#')) {
        textSpans.add(
          TextSpan(
            text: '$element ',
            style: const TextStyle(
              color: Pallete.blueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (element.startsWith('https://') || element.startsWith('www.')) {
        textSpans.add(
          TextSpan(
            text: '$element ',
            style: const TextStyle(
              color: Pallete.blueColor,
              fontSize: 18,
            ),
          ),
        );
      } else {
        textSpans.add(
          TextSpan(
            text: '$element ',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        );
      }
    });
    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}
