import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  final String? address;
  final String? city;
  final String? country;
  final String? state;
  final int? timezone;
  final String? zip;
  final String? phone1;

  Contact(
    this.address,
    this.city,
    this.country,
    this.state,
    this.timezone,
    this.zip,
    this.phone1,
  );

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  Map<String, dynamic> toJson() => _$ContactToJson(this);

  Contact copyWith({
    String? address,
    String? city,
    String? country,
    String? state,
    int? timezone,
    String? zip,
    String? phone1,
  }) {
    return Contact(
      address ?? this.address,
      city ?? this.city,
      country ?? this.country,
      state ?? this.state,
      timezone ?? this.timezone,
      zip ?? this.zip,
      phone1 ?? this.phone1,
    );
  }
}
