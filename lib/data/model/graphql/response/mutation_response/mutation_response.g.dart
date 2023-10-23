// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mutation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MutationResponse _$MutationResponseFromJson(Map<String, dynamic> json) =>
    MutationResponse(
      isSuccess: json['isSuccess'] as bool,
      message: json['message'] as String?,
      code: json['code'] as int?,
    );

Map<String, dynamic> _$MutationResponseToJson(MutationResponse instance) {
  final val = <String, dynamic>{
    'isSuccess': instance.isSuccess,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('message', instance.message);
  writeNotNull('code', instance.code);
  return val;
}
