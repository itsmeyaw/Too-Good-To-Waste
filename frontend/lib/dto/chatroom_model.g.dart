// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatroom_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chatroom _$ChatroomFromJson(Map<String, dynamic> json) => Chatroom(
      initiator: json['initiator'] as String,
      receiver: json['receiver'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatroomToJson(Chatroom instance) => <String, dynamic>{
      'initiator': instance.initiator,
      'receiver': instance.receiver,
      'messages': instance.messages,
    };
