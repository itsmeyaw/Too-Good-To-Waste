import 'package:json_annotation/json_annotation.dart';

enum ItemCategory {
  @JsonValue("Vegetable")
  Vegetable,
  @JsonValue("Meat")
  Meat,
  @JsonValue("Fruit")
  Fruit,
  @JsonValue("Diaries")
  Diaries,
  @JsonValue("Seafood")
  Seafood,
  @JsonValue("Egg")
  Egg,
  @JsonValue("Others")
  Others;

  static ItemCategory parse(String value) {
    switch (value) {
      case "Vegetable":
        return ItemCategory.Vegetable;
      case "Meat":
        return ItemCategory.Meat;
      case "Fruit":
        return ItemCategory.Fruit;
      case "Diaries":
        return ItemCategory.Diaries;
      case "Seafood":
        return ItemCategory.Seafood;
      case "Egg":
        return ItemCategory.Egg;
      default:
        return ItemCategory.Others;
    }
  }
}
