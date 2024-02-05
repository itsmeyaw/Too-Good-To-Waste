import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import './user_item_amount_model.dart';
import './user_item_expiry_model.dart';

// part 'user_item_model.g.dart';

@immutable
@JsonSerializable()
class UserItem {
  //int id;
  String name;
  String category;
  int boughttime;
  int expiretime;
  String quantitytype;
  double quantitynum;
  String state;
  double consumestate;

UserItem(
  {
    //required this.id,
    required this.name,
    required this.category,
    required this.boughttime,
    required this.expiretime,
    required this.quantitytype,
    required this.quantitynum,
    required this.consumestate,
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
      'boughttime': boughttime,
      'expiretime': expiretime,
      'quantitytype': quantitytype,
      'quantitynum': quantitynum,
      'state': state,
      'consumestate': consumestate,
    };
  }

  //Implement toString tomake it easier to see information about
  //each food when using the print statement
  @override
  String toString() {
    return 'UserItem{name: $name, category: $category, boughttime: $boughttime, expiretime: $expiretime, quantitytype: $quantitytype, quantitynum: $quantitynum, state: $state, consumestate: $consumestate}';
  }

  // factory UserItem.fromJson(Map<String, dynamic> json) =>
  //     _$UserItemFromJson(json);

  // Map<String, dynamic> toJson() => _$UserItemToJson(this);
}


// @immutable
// @JsonSerializable()
// class UserItem {
//   final DateTime buyDate;
//   final String name;
//   final String category;
//   final UserItemAmount amount;
//   final UserItemExpiry expiry;
//   // TODO: Add state here

//   const UserItem(
//       {required this.name,
//       required this.buyDate,
//       required this.category,
//       required this.amount,
//       required this.expiry});

//   factory UserItem.fromJson(Map<String, dynamic> json) =>
//       _$UserItemFromJson(json);

//   Map<String, dynamic> toJson() => _$UserItemToJson(this);
// }
