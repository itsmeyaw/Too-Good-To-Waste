// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedItem _$SharedItemFromJson(Map<String, dynamic> json) => SharedItem(
      amount: UserItemAmount.fromJson(json['amount'] as Map<String, dynamic>),
      buyDate: json['buy_date'] as int,
      expireDate: json['expire_date'] as int,
      imageUrl: json['image_url'] as String?,
      name: json['name'] as String,
      category: $enumDecode(_$ItemCategoryEnumMap, json['category']),
      user: json['user'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      likedBy: (json['liked_by'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sharedItemReservation: json['shared_item_reservation'] == null
          ? null
          : SharedItemReservation.fromJson(
              json['shared_item_reservation'] as Map<String, dynamic>),
    )..location = const GeoFirePointConverter()
        .fromJson(json['location'] as Map<String, dynamic>);

Map<String, dynamic> _$SharedItemToJson(SharedItem instance) =>
    <String, dynamic>{
      'amount': instance.amount.toJson(),
      'buy_date': instance.buyDate,
      'expire_date': instance.expireDate,
      'name': instance.name,
      'image_url': instance.imageUrl,
      'category': _$ItemCategoryEnumMap[instance.category]!,
      'user': instance.user,
      'shared_item_reservation': instance.sharedItemReservation?.toJson(),
      'is_available': instance.isAvailable,
      'liked_by': instance.likedBy,
      'location': const GeoFirePointConverter().toJson(instance.location),
    };

const _$ItemCategoryEnumMap = {
  ItemCategory.Vegetable: 'Vegetable',
  ItemCategory.Meat: 'Meat',
  ItemCategory.Fruit: 'Fruit',
  ItemCategory.Diaries: 'Diaries',
  ItemCategory.Seafood: 'Seafood',
  ItemCategory.Egg: 'Egg',
  ItemCategory.Others: 'Others',
};
