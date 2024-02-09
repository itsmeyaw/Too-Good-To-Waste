import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import './message_model.dart';

part 'chatroom_model.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class Chatroom {
  final String roomId;
  final Participants participants;
  final Messages messages;

  const Chatroom(
      {required this.roomId,
      required this.participants,
      required this.messages});

  factory Chatroom.fromJson(Map<String, dynamic> json) =>
      _$ChatroomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatroomToJson(this);
}

@JsonSerializable()
class Participants {
  final String one;
  final String two;

  Participants({required this.one, required this.two});

  factory Participants.fromJson(Map<String, dynamic> json) =>
      _$ParticipantsFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Messages {
  final List<Message> one;
  final List<Message> two;

  Messages({required this.one, required this.two});

  factory Messages.fromJson(Map<String, dynamic> json) =>
      _$MessagesFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesToJson(this);
}
