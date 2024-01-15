import 'package:flutter/material.dart';

@immutable
class User {
  final UserName name;
  final UserAddress address;
  final List<String> allergies;
  final List<String> chatroomIds;
  final int rating;

  const User({
    required this.name,
    required this.address,
    required this.allergies,
    required this.chatroomIds,
    required this.rating,
  });

  User.fromJson(Map<String, Object?> json)
      : this(
            name: UserName.fromJson(json['name']! as Map<String, String>),
            address: UserAddress.fromJson(json['address']! as Map<String, String>),
            allergies: (json['allergies']! as List).cast<String>(),
            chatroomIds: (json['chatrooms']! as List).cast<String>(),
            rating: json['rating']! as int);

  Map<String, Object?> toJson() {
    return {
      'name': name.toJson(),
      'address': address.toJson(),
      'allergies': allergies,
      'chatrooms': chatroomIds,
      'rating': rating,
    };
  }
}

@immutable
class UserName {
  final String first;
  final String last;

  const UserName({required this.first, required this.last});

  UserName.fromJson(Map<String, Object?> json)
      : this(
          first: json['first']! as String,
          last: json['last']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'first': first,
      'last': last
    };
  }
}

@immutable
class UserAddress {
  final String city;
  final String country;
  final String line1;
  final String line2;
  final String zipCode;

  const UserAddress({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.zipCode,
  });

  UserAddress.fromJson(Map<String, Object?> json)
      : this(
          city: json['city']! as String,
          country: json['country']! as String,
          line1: json['line_1']! as String,
          line2: json['line_2']! as String,
          zipCode: json['zipCode']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'city': city,
      'country': country,
      'line_1': line1,
      'line_2': line2,
      'zip_code': zipCode
    };
  }
}
