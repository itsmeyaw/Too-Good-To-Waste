import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserItem {
  String id;
  String name;
  String category;
  int boughtTime;
  int expireTime;
  String quantityType;
  double quantityNum;
  String state;
  double consumeState;

UserItem(
  {
    required this.id,
    required this.name,
    required this.category,
    required this.boughtTime,
    required this.expireTime,
    required this.quantityType,
    required this.quantityNum,
    required this.consumeState,
    required this.state
  }
);

  //Convert a Food into a Map. The keys must correspond to the names
  //of the columns in the databse.
  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'name': name,
      'category': category,
      'buy_date': boughtTime,
      'expiry_date': expireTime,
      'quantity_type': quantityType,
      'quantity_num': quantityNum,
      'state': state,
      'consume_state': consumeState,
    };
  }

  //Implement toString tomake it easier to see information about
  //each food when using the print statement
  @override
  String toString() {
    return 'UserItem{name: $name, category: $category, buy_date: $boughtTime, expiry_date: $expireTime, quantity_type: $quantityType, quantity_num: $quantityNum, state: $state, consume_state: $consumeState}';
  }

  factory UserItem.fromJson(Map<String, dynamic> json) =>
      _$UserItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserItemToJson(this);
}
