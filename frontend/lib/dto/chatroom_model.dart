import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import './message_model.dart';

part 'chatroom_model.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class Chatroom {
  final String partnerId;

  const Chatroom({required this.partnerId});

  factory Chatroom.fromJson(Map<String, dynamic> json) =>
      _$ChatroomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatroomToJson(this);
}
