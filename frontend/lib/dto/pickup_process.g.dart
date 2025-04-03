// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_process.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupProcess _$PickupProcessFromJson(Map<String, dynamic> json) =>
    PickupProcess(
      receiver: json['receiver'] as String,
      giver: json['giver'] as String,
      sharedItemId: json['shared_item_id'] as String,
      isActive: json['is_active'] as bool,
      state: $enumDecodeNullable(_$PickupStateEnumMap, json['state']) ??
          PickupState.INITIALIZED,
    )..id = json['id'] as String?;

Map<String, dynamic> _$PickupProcessToJson(PickupProcess instance) =>
    <String, dynamic>{
      'receiver': instance.receiver,
      'giver': instance.giver,
      'shared_item_id': instance.sharedItemId,
      'is_active': instance.isActive,
      'state': _$PickupStateEnumMap[instance.state],
    };

const _$PickupStateEnumMap = {
  PickupState.INITIALIZED: 'Initialized',
  PickupState.RECEIVER_RECEVICES: 'ReceiverReceives',
  PickupState.DONE: 'Done',
  PickupState.CANCELLED: 'Cancelled',
};
