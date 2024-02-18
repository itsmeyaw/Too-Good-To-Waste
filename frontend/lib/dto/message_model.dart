import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';

part 'message_model.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class Message {
  final String message;
  final String sender;
  final DateTime timestamp;

  @JsonKey(defaultValue: null)
  final String? sharedItemId;

  const Message({
    required this.message,
    required this.sender,
    required this.timestamp,
    this.sharedItemId
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
