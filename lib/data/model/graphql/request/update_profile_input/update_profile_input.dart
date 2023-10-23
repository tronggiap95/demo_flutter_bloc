import 'package:json_annotation/json_annotation.dart';

import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/data/model/graphql/request/contact_input/contact_input.dart';
import 'package:octo360/domain/model/profile/user/user_domain.dart';

part 'update_profile_input.g.dart';

@JsonSerializable()
class UpdateProfileInput {
  final String? firstName;
  final String? lastName;
  final ContactInput? contact;
  final int? utcOffset;
  final String? timezone;

  UpdateProfileInput({
    this.firstName,
    this.lastName,
    this.contact,
    this.utcOffset,
    this.timezone,
  });

  Future<UserDomain> toUserDomain() async {
    UserDomain? user =
        FactoryManager.provideGlobalRepo().userDomain ?? UserDomain();

    return user.copyWith(
      contactInfo: await toContactInfoDomain(user),
      basicInfo: toBasicInfoDomain(user),
    );
  }

  Future<ContactInfo> toContactInfoDomain(UserDomain user) async {
    final contactInfo = user.contactInfo ?? ContactInfo();

    return contactInfo.copyWith(
      phoneNumber: contact?.phone1,
    );
  }

  BasicInfo toBasicInfoDomain(UserDomain user) {
    final basicInfo = user.basicInfo ?? BasicInfo();
    return basicInfo.copyWith(
      firstname: firstName,
      lastname: lastName,
    );
  }

  factory UpdateProfileInput.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileInputFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileInputToJson(this);
}
