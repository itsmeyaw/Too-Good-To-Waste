import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';


@immutable
@JsonSerializable()
class UserItemDetail {
  // String id;
  String name;
  String category;
  String quantitytype;
  double quantitynum;
  int remainDays;
  double consumestate;
  String state;

UserItemDetail(
  {
    // required this.id,
    required this.name,
    required this.category,
    required this.quantitytype,
    required this.quantitynum,
    required this.consumestate,
    required this.remainDays,
    required this.state
  }
);

  //Convert a Food into a Map. The keys must correspond to the names
  //of the columns in the databse.
  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'category': category,
      'quantitytype': quantitytype,
      'quantitynum': quantitynum,
      'remainDays': remainDays,
      'consumestate': consumestate,
      'state': state,
    };
  }

  //Implement toString tomake it easier to see information about
  //each food when using the print statement
  @override
  String toString() {
    return 'UserItemDetail{name: $name, category: $category, quantitytype: $quantitytype, quantitynum: $quantitynum, remainDays: $remainDays, consumestate: $consumestate}, state: $state';
  }
}
