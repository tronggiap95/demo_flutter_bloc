class UserDomain {
  String? id;
  BasicInfo? basicInfo;
  ContactInfo? contactInfo;

  UserDomain({
    this.id,
    this.basicInfo,
    this.contactInfo,
  });

  String? getUserFirstName() {
    return basicInfo?.firstname;
  }

  String? getUserLastName() {
    return basicInfo?.lastname;
  }

  UserDomain copyWith({
    String? id,
    BasicInfo? basicInfo,
    ContactInfo? contactInfo,
  }) {
    return UserDomain(
      id: id ?? this.id,
      basicInfo: basicInfo ?? this.basicInfo,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}

class BasicInfo {
  String? firstname;
  String? lastname;
  String? email;
  DateTime? dateOfBirth;
  double? height;
  double? weight;
  DateTime? octo360ActivationTime;

  BasicInfo({
    this.firstname,
    this.lastname,
    this.email,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.octo360ActivationTime,
  });

  BasicInfo copyWith({
    String? firstname,
    String? lastname,
    String? email,
    DateTime? dateOfBirth,
    double? height,
    double? weight,
    DateTime? octo360ActivationTime,
  }) {
    return BasicInfo(
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      octo360ActivationTime: octo360ActivationTime ?? octo360ActivationTime,
    );
  }
}

class ContactInfo {
  String? country;
  String? address;
  String? city;
  String? addressState;
  String? zipcode;
  String? phoneNumber;
  bool? isPhoneNumberVerified;
  ContactInfo({
    this.country,
    this.address,
    this.city,
    this.addressState,
    this.zipcode,
    this.phoneNumber,
    this.isPhoneNumberVerified,
  });

  ContactInfo copyWith({
    String? country,
    String? address,
    String? city,
    String? addressState,
    String? zipcode,
    String? phoneNumber,
    bool? isPhoneNumberVerified,
  }) {
    return ContactInfo(
      country: country ?? this.country,
      address: address ?? this.address,
      city: city ?? this.city,
      addressState: addressState ?? this.addressState,
      zipcode: zipcode ?? this.zipcode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneNumberVerified:
          isPhoneNumberVerified ?? this.isPhoneNumberVerified,
    );
  }
}
