// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      name: UserName.fromJson(json['name'] as Map<String, dynamic>),
      rating: (json['rating'] as num).toDouble(),
      address: UserAddress.fromJson(json['address'] as Map<String, dynamic>),
      allergies:
          (json['allergies'] as List<dynamic>).map((e) => e as String).toList(),
      chatroomIds: (json['chatroom_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'rating': instance.rating,
      'address': instance.address,
      'allergies': instance.allergies,
      'chatroom_ids': instance.chatroomIds,
    };

UserAddress _$UserAddressFromJson(Map<String, dynamic> json) => UserAddress(
      city: json['city'] as String,
      country: json['country'] as String,
      line1: json['line1'] as String,
      line2: json['line2'] as String,
      zipCode: json['zip_code'] as String,
    );

Map<String, dynamic> _$UserAddressToJson(UserAddress instance) =>
    <String, dynamic>{
      'city': instance.city,
      'country': instance.country,
      'line1': instance.line1,
      'line2': instance.line2,
      'zip_code': instance.zipCode,
    };
