import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_name_model.g.dart';

@immutable
@JsonSerializable()
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
    return {'first': first, 'last': last};
  }
}
