import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_item_amount_model.g.dart';

@immutable
@JsonSerializable()
class UserItemAmount {
  final double nominal;
  final String unit;

  const UserItemAmount({required this.nominal, required this.unit});

  UserItemAmount.fromJson(Map<String, Object?> json)
      : this(
          nominal: json['nominal']! as double,
          unit: json['unit']! as String,
        );

  // factory UserItemAmount.fromJson(Map<String, dynamic> json) =>
  //     _$UserItemAmountFromJson(json);

  // Map<String, dynamic> toJson() => _$UserItemAmountToJson(this);
  Map<String, Object?> toJson() {
    return {'nominal': nominal, 'unit': unit};
  }
}
