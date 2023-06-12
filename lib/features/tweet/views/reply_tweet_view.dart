import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/commons/common.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class ReplyTweetView extends ConsumerWidget {
  static route(Tweet tweet) => MaterialPageRoute(
        builder: (context) => ReplyTweetView(
          tweet: tweet,
        ),
      );

  final Tweet tweet;
  const ReplyTweetView({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweet'),
      ),
      body: Column(
        children: [
          TweetCard(tweet: tweet),
          ref.watch(getRepliesToTweetProvider(tweet)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          log(data.toString());
                          final latestTweet = Tweet.fromMap(data.payload);

                          bool isTweetAlreadyPresent = false;
                          for (final tweetModel in tweets) {
                            if (tweetModel.id == latestTweet.id) {
                              isTweetAlreadyPresent = true;
                              break;
                            }
                          }

                          if (!isTweetAlreadyPresent &&
                              latestTweet.repliedTo == tweet.id) {
                            log('Event: ${data.events[0]}');
                            if (data.events[0].contains(
                                'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetCollectionId}.documents.*.create')) {
                              tweets.insert(0, Tweet.fromMap(data.payload));
                            } else if (data.events[0].contains(
                                'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetCollectionId}.documents.*.update')) {
                              final startingPoint =
                                  data.events[0].lastIndexOf('documents.');
                              final endingPoint =
                                  data.events[0].lastIndexOf('.update');

                              final tweetId = data.events[0]
                                  .substring(startingPoint + 10, endingPoint);

                              var tweet = tweets
                                  .where((element) => element.id == tweetId)
                                  .first;

                              int tweetIndex = tweets.indexOf(tweet);
                              tweets.removeWhere(
                                  (element) => element.id == tweet.id);

                              tweet = Tweet.fromMap(data.payload);
                              tweets.insert(tweetIndex, tweet);
                            }
                          }

                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (context, index) {
                                log(tweets[index].toString());
                                return TweetCard(tweet: tweets[index]);
                              },
                            ),
                          );
                        },
                        error: (error, st) =>
                            ErrorPage(error: error.toString()),
                        loading: () {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (context, index) {
                                log(tweets[index].toString());
                                return TweetCard(tweet: tweets[index]);
                              },
                            ),
                          );
                        },
                      );
                },
                error: (error, st) => ErrorPage(error: error.toString()),
                loading: () => const LoadingPage(),
              ),
        ],
      ),
      bottomNavigationBar: TextField(
        onSubmitted: (value) {
          ref.read(tweetControllerProvider.notifier).shareTweet(
            images: [],
            text: value,
            context: context,
            repliedTo: tweet.id,
          );
        },
        decoration: const InputDecoration(hintText: 'Type your reply'),
      ),
    );
  }
}
