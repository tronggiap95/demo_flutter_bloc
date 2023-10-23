import 'package:json_annotation/json_annotation.dart';

part 'contact_input.g.dart';

@JsonSerializable()
class ContactInput {
  final String? address;
  final String? city;
  final String? country;
  final String? state;
  final int? timezone;
  final String? phone1;
  final String? zip;

  ContactInput({
    this.address,
    this.city,
    this.country,
    this.state,
    this.timezone,
    this.phone1,
    this.zip,
  });

  factory ContactInput.fromJson(Map<String, dynamic> json) =>
      _$ContactInputFromJson(json);

  Map<String, dynamic> toJson() => _$ContactInputToJson(this);
}
