import 'package:json_annotation/json_annotation.dart';

part 'mutation_response.g.dart';

@JsonSerializable()
class MutationResponse {
  final bool isSuccess;
  final String? message;
  final int? code;

  MutationResponse({
    required this.isSuccess,
    this.message,
    this.code,
  });

  factory MutationResponse.fromJson(Map<String, dynamic> json) =>
      _$MutationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MutationResponseToJson(this);
}
