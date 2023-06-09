import 'dart:developer';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/commons/common.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controllers/auth_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/carousel_image.dart';
import 'package:twitter_clone/features/tweet/widgets/hashtag_text.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_icons_button.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  final Tweet tweet;
  const TweetCard({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userDetailsProvider(tweet.uid)).when(
          data: (user) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePic),
                        radius: 30,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //retreated
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                              Text(
                                '@${user.name} . ${timeago.format(tweet.tweetedAt, locale: 'en_short')}',
                                style: const TextStyle(
                                  color: Pallete.greyColor,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          //Replied to
                          HashTagText(text: tweet.text),
                          if (tweet.tweetTypes == TweetType.image)
                            CarouselImage(imageLinks: tweet.imageLinks),

                          if (tweet.link.isNotEmpty) ...[
                            const SizedBox(
                              height: 4,
                            ),
                            AnyLinkPreview(
                              displayDirection:
                                  UIDirection.uiDirectionHorizontal,
                              // link: 'https://${tweet.link}',
                              link: tweet.link,
                            ),
                          ],

                          Container(
                            margin: const EdgeInsets.only(
                              right: 10,
                              top: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TweetIconButton(
                                  pathName: AssetsConstants.viewsIcon,
                                  text: (tweet.commentIds.length +
                                          tweet.likes.length +
                                          tweet.reshareCount)
                                      .toString(),
                                  onTap: () {},
                                ),
                                TweetIconButton(
                                  pathName: AssetsConstants.commentIcon,
                                  text: tweet.commentIds.length.toString(),
                                  onTap: () {},
                                ),
                                TweetIconButton(
                                  pathName: AssetsConstants.retweetIcon,
                                  text: tweet.reshareCount.bitLength.toString(),
                                  onTap: () {},
                                ),
                                TweetIconButton(
                                  pathName: AssetsConstants.likeOutlinedIcon,
                                  text: tweet.likes.length.toString(),
                                  onTap: () {},
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.share_outlined,
                                    size: 25,
                                    color: Pallete.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Pallete.greyColor),
              ],
            );
          },
          error: (error, stackTrace) {
            log('Error $error');
            return ErrorPage(error: error.toString());
          },
          loading: () => const LoadingPage(),
        );
  }
}
