// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatroom_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chatroom _$ChatroomFromJson(Map<String, dynamic> json) => Chatroom(
      roomId: json['room_id'] as String,
      participants:
          Participants.fromJson(json['participants'] as Map<String, dynamic>),
      messages: Messages.fromJson(json['messages'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatroomToJson(Chatroom instance) => <String, dynamic>{
      'room_id': instance.roomId,
      'participants': instance.participants.toJson(),
      'messages': instance.messages.toJson(),
    };

Participants _$ParticipantsFromJson(Map<String, dynamic> json) => Participants(
      one: json['one'] as String,
      two: json['two'] as String,
    );

Map<String, dynamic> _$ParticipantsToJson(Participants instance) =>
    <String, dynamic>{
      'one': instance.one,
      'two': instance.two,
    };

Messages _$MessagesFromJson(Map<String, dynamic> json) => Messages(
      one: (json['one'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      two: (json['two'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessagesToJson(Messages instance) => <String, dynamic>{
      'one': instance.one.map((e) => e.toJson()).toList(),
      'two': instance.two.map((e) => e.toJson()).toList(),
    };
