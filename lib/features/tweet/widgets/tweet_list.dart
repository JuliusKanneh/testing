import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/commons/common.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
          data: (tweets) {
            log(tweets.length.toString());
            return ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    log('Event: ${data.events}');
                    if (data.events.contains(
                        'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetCollectionId}.documents.*.create')) {
                      // log('Realtime: ${data.payload}');
                      tweets.insert(0, Tweet.fromMap(data.payload));
                    } else if (data.events.contains(
                        'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetCollectionId}.documents.*.update')) {
                      // log('Event: ${data.events[0]}');
                      final startingPoint =
                          data.events[0].lastIndexOf('documents.');
                      final endingPoint = data.events[0].lastIndexOf('.update');

                      final tweetId = data.events[0]
                          .substring(startingPoint + 10, endingPoint);

                      var tweet = tweets
                          .where((element) => element.id == tweetId)
                          .first;

                      int tweetIndex = tweets.indexOf(tweet);
                      tweets.removeWhere((element) => element.id == tweet.id);

                      tweet = Tweet.fromMap(data.payload);
                      tweets.insert(tweetIndex, tweet);
                    }
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (context, index) {
                        final tweet = tweets[index];
                        log(tweet.text);
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                  error: (error, st) => ErrorPage(error: error.toString()),
                  loading: () {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (context, index) {
                        final tweet = tweets[index];
                        log(tweet.text);
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const LoadingPage(),
        );
  }
}
