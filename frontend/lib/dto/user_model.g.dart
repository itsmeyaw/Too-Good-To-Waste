// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TGTWUser _$TGTWUserFromJson(Map<String, dynamic> json) => TGTWUser(
      name: UserName.fromJson(json['name'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      phoneNumber: json['phone_number'] as String,
      address: UserAddress.fromJson(json['address'] as Map<String, dynamic>),
      allergies:
          (json['allergies'] as List<dynamic>).map((e) => e as String).toList(),
      goodPoints: json['good_points'] as int,
      reducedCarbonKg: (json['reduced_carbon_kg'] as num).toDouble(),
      userPreference: json['user_preference'] == null
          ? const UserPreference()
          : UserPreference.fromJson(
              json['user_preference'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TGTWUserToJson(TGTWUser instance) => <String, dynamic>{
      'name': instance.name.toJson(),
      'rating': instance.rating,
      'address': instance.address.toJson(),
      'phone_number': instance.phoneNumber,
      'allergies': instance.allergies,
      'good_points': instance.goodPoints,
      'reduced_carbon_kg': instance.reducedCarbonKg,
      'user_preference': instance.userPreference.toJson(),
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
