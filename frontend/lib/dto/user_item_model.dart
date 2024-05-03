import 'package:json_annotation/json_annotation.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';

part 'user_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserItem {
  String? id;
  String name;
  ItemCategory category;
  int buyDate;
  int expiryDate;
  String quantityType;
  double quantityNum;
  String state;
  double consumeState;

  UserItem(
      {required this.id,
      required this.name,
      required this.category,
      required this.buyDate,
      required this.expiryDate,
      required this.quantityType,
      required this.quantityNum,
      required this.consumeState,
      required this.state});

  //Convert a Food into a Map. The keys must correspond to the names
  //of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'buy_date': buyDate,
      'expiry_date': expiryDate,
      'quantity_type': quantityType,
      'quantity_num': quantityNum,
      'state': state,
      'consume_state': consumeState,
    };
  }

  //Implement toString to make it easier to see information about
  //each food when using the print statement
  @override
  String toString() {
    return 'UserItem{id: $id, name: $name, category: ${category.name}, buy_date: $buyDate, expiry_date: $expiryDate, quantity_type: $quantityType, quantity_num: $quantityNum, state: $state, consume_state: $consumeState}';
  }

  factory UserItem.fromJson(Map<String, dynamic> json) =>
      _$UserItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserItemToJson(this);
}
