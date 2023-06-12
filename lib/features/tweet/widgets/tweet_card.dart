import 'dart:developer';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:twitter_clone/commons/common.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controllers/auth_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/views/reply_tweet_view.dart';
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
    var currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const SizedBox()
        : ref.watch(userDetailsProvider(tweet.uid)).when(
              data: (user) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      ReplyTweetView.route(tweet),
                    );
                  },
                  child: Column(
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
                                if (tweet.retweetedBy.isNotEmpty)
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsConstants.retweetIcon,
                                        height: 20,
                                        color: Pallete.greyColor,
                                      ),
                                      Text(
                                        '${tweet.retweetedBy} retweeted',
                                        style: const TextStyle(
                                          color: Pallete.greyColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                if (tweet.repliedTo.isNotEmpty)
                                  ref
                                      .watch(getTweetByIdProvider(tweet.id))
                                      .when(
                                          data: (repliedToTweet) {
                                            final replyingToUser = ref
                                                .watch(userDetailsProvider(
                                                    repliedToTweet.uid))
                                                .value;
                                            return RichText(
                                              text: TextSpan(
                                                  text: 'Replying to ',
                                                  style: const TextStyle(
                                                    color: Pallete.greyColor,
                                                    fontSize: 16,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '@${replyingToUser?.name}',
                                                      style: const TextStyle(
                                                        color:
                                                            Pallete.blueColor,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ]),
                                            );
                                          },
                                          error: (error, st) => ErrorPage(
                                              error: error.toString()),
                                          loading: () => SizedBox()),

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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        text:
                                            tweet.commentIds.length.toString(),
                                        onTap: () {},
                                      ),
                                      TweetIconButton(
                                        pathName: AssetsConstants.retweetIcon,
                                        text: tweet.reshareCount.toString(),
                                        onTap: () {
                                          ref
                                              .read(tweetControllerProvider
                                                  .notifier)
                                              .reshareTweet(
                                                tweet,
                                                currentUser,
                                                context,
                                              );
                                        },
                                      ),
                                      LikeButton(
                                        size: 25,
                                        likeBuilder: (isLiked) {
                                          return isLiked
                                              ? SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeFilledIcon,
                                                  color: Pallete.redColor,
                                                )
                                              : SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeFilledIcon,
                                                  color: Pallete.greyColor,
                                                );
                                        },
                                        likeCount: tweet.likes.length,
                                        isLiked: tweet.likes
                                            .contains(currentUser.uid),
                                        countBuilder:
                                            (likeCount, isLiked, text) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2.0),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color: isLiked
                                                    ? Pallete.redColor
                                                    : Pallete.whiteColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        },
                                        onTap: (isLiked) async {
                                          ref
                                              .read(tweetControllerProvider
                                                  .notifier)
                                              .likeTweet(tweet, currentUser);
                                          return !isLiked;
                                        },
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
                  ),
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
