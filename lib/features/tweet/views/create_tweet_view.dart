import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/commons/common.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controllers/auth_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/theme/pallete.dart';

class CreateTweetView extends ConsumerStatefulWidget {
  static rounte() => MaterialPageRoute(
        builder: (context) => const CreateTweetView(),
      );
  const CreateTweetView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTweetViewState();
}

class _CreateTweetViewState extends ConsumerState<CreateTweetView> {
  List<File> images = [];
  TextEditingController tweetTextController = TextEditingController();

  @override
  void dispose() {
    tweetTextController.dispose();
    super.dispose();
  }

  void onPickImages() async {
    images = await pickImages();
    setState(() {});
  }

  void createTweet() {
    ref.read(tweetControllerProvider.notifier).shareTweet(
          images: images,
          text: tweetTextController.text,
          context: context,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(tweetControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, size: 30),
        ),
        actions: [
          RoundedSmallButton(
            onTap: createTweet,
            label: 'Tweet',
            backgroundColor: Pallete.blueColor,
            textColor: Pallete.whiteColor,
          ),
        ],
      ),
      body: currentUser == null || isLoading
          ? const Loader()
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(currentUser.profilePic),
                          radius: 30,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: tweetTextController,
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                            decoration: const InputDecoration(
                              hintText: "What's happening?",
                              hintStyle: TextStyle(
                                color: Pallete.greyColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                    if (images.isNotEmpty)
                      CarouselSlider(
                        items: images.map((file) {
                          return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: Image.file(file));
                        }).toList(),
                        options: CarouselOptions(
                          height: 400,
                          enableInfiniteScroll: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Pallete.greyColor,
              width: 0.3,
            ),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(
                left: 15,
                right: 15,
              ),
              child: GestureDetector(
                  onTap: onPickImages,
                  child: SvgPicture.asset(AssetsConstants.galleryIcon)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(
                left: 15,
                right: 15,
              ),
              child: SvgPicture.asset(AssetsConstants.gifIcon),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(
                left: 15,
                right: 15,
              ),
              child: SvgPicture.asset(AssetsConstants.emojiIcon),
            ),
          ],
        ),
      ),
    );
  }
}
