import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';

import './user_model.dart';

part 'message_model.g.dart';

@immutable
@JsonSerializable()
class Message {
  final String message;
  final User initiator;
  final User receiver;
  final DateTime timestamp;

  const Message({
    required this.message,
    required this.initiator,
    required this.receiver,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}