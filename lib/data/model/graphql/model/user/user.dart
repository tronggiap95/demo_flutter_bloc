import 'package:json_annotation/json_annotation.dart';

import 'package:octo360/data/model/graphql/model/contact/contact.dart';
import 'package:octo360/domain/model/profile/user/user_domain.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String? id;
  final bool? isProfileCompleted;
  final Contact? contact;
  final String? firstName;
  final String? lastName;

  User({
    this.id,
    this.isProfileCompleted,
    this.contact,
    this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  UserDomain toUserDomain() {
    return UserDomain(
        id: id, basicInfo: _toBasicInfo(), contactInfo: _toContactInfo());
  }

  ContactInfo _toContactInfo() {
    return ContactInfo(
      phoneNumber: contact?.phone1,
    );
  }

  BasicInfo _toBasicInfo() {
    return BasicInfo(
      firstname: firstName,
      lastname: lastName,
    );
  }
}
