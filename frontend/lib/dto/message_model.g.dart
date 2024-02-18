// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      message: json['message'] as String,
      initiator: TGTWUser.fromJson(json['initiator'] as Map<String, dynamic>),
      receiver: TGTWUser.fromJson(json['receiver'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'message': instance.message,
      'initiator': instance.initiator,
      'receiver': instance.receiver,
      'timestamp': instance.timestamp.toIso8601String(),
    };
