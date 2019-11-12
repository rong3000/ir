// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User()
    ..userName = json['userName'] as String
    ..firstname = json['firstname'] as String
    ..lastname = json['lastname'] as String
    ..email = json['email'] as String
    ..telephone = json['telephone'] as String
    ..mobile = json['mobile'] as String
    ..fax = json['fax'] as String
    ..dob = json['dob'] == null ? null : DateTime.parse(json['dob'] as String)
    ..genderId = json['genderId'] as int
    ..genderName = json['genderName'] as String;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userName': instance.userName,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'email': instance.email,
      'telephone': instance.telephone,
      'mobile': instance.mobile,
      'fax': instance.fax,
      'dob': instance.dob?.toIso8601String(),
      'genderId': instance.genderId,
      'genderName': instance.genderName
    };
