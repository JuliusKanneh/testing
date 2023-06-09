import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String uid;
  final String email;
  final String name;
  final List<String> followers;
  final List<String> followings;
  final String profilePic;
  final String bannerPic;
  final String bio;
  final bool isTwitterBlue;
  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.followers,
    required this.followings,
    required this.profilePic,
    required this.bannerPic,
    required this.bio,
    required this.isTwitterBlue,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    List<String>? followers,
    List<String>? followings,
    String? profilePic,
    String? bannerPic,
    String? bio,
    bool? isTwitterBlue,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      followers: followers ?? this.followers,
      followings: followings ?? this.followings,
      profilePic: profilePic ?? this.profilePic,
      bannerPic: bannerPic ?? this.bannerPic,
      bio: bio ?? this.bio,
      isTwitterBlue: isTwitterBlue ?? this.isTwitterBlue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'followers': followers,
      'followings': followings,
      'profilePic': profilePic,
      'bannerPic': bannerPic,
      'bio': bio,
      'isTwitterBlue': isTwitterBlue,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['\$id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      followers: List<String>.from(map['followers']),
      followings: List<String>.from(map['followings']),
      profilePic: map['profilePic'] ?? '',
      bannerPic: map['bannerPic'] ?? '',
      bio: map['bio'] ?? '',
      isTwitterBlue: map['isTwitterBlue'] ?? false,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, followers: $followers, followings: $followings, profilePic: $profilePic, bannerPic: $bannerPic, bio: $bio, isTwitterBlue: $isTwitterBlue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        listEquals(other.followers, followers) &&
        listEquals(other.followings, followings) &&
        other.profilePic == profilePic &&
        other.bannerPic == bannerPic &&
        other.bio == bio &&
        other.isTwitterBlue == isTwitterBlue;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        followers.hashCode ^
        followings.hashCode ^
        profilePic.hashCode ^
        bannerPic.hashCode ^
        bio.hashCode ^
        isTwitterBlue.hashCode;
  }
}
