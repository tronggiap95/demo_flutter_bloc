import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/data/model/graphql/request/update_profile_input/update_profile_input.dart';
import 'package:octo360/data/model/graphql/response/mutation_response.dart';
import 'package:octo360/data/remote/graphql/exceptions/graphql_exception_handler.dart';
import 'package:octo360/data/remote/graphql/graphql_client.dart';
import 'package:octo360/data/remote/graphql/mutations/user/update_profile.dart';
import 'package:octo360/domain/model/profile/user/user_domain.dart';

enum NullableType { avartar }

///Due to the json generation doesn't include nullable fields
///need to include nullable fields manually
class NullableParam {
  final Map<String, String?> nullableJson;
  final NullableType type;

  NullableParam({
    required this.nullableJson,
    required this.type,
  });
}

class UpdateProfileFunction {
  static Future<void> update(GraphQLClientApp _client, UpdateProfileInput input,
      {NullableParam? nullableParam, bool isPrintLog = false}) async {
    try {
      final inputJson = input.toJson();

      //Add nullable fields -> due to json don't include nullable fields
      //using additional json passes from outside
      final additionalJson = nullableParam?.nullableJson;
      if (additionalJson != null) {
        inputJson.addAll(additionalJson);
      }

      final params = {"input": inputJson};
      final res = await _client.mutation(
          queries: updateProfileMutation,
          variables: params,
          isPrintLog: isPrintLog);
      if (res.hasException) {
        throw GraphQLExceptionHandler.handleException(res.exception);
      }
      final Map<String, dynamic>? data = res.data;
      Map<String, dynamic> json = data!['updateProfile'];
      final result = MutationResponse.fromJson(json);
      if (!result.isSuccess) {
        throw GraphQLExceptionHandler.handleException(result.message);
      }
      //Update global data
      final globalRepo = FactoryManager.provideGlobalRepo();
      globalRepo.userDomain =
          await toDomainData(param: nullableParam, input: input);
      return;
    } catch (error) {
      Log.e("updateProfile $error");
      throw GraphQLExceptionHandler.handleException(error);
    }
  }

  static Future<UserDomain> toDomainData(
      {NullableParam? param, required UpdateProfileInput input}) async {
    final userDomain = await input.toUserDomain();
    if (param == null) {
      return userDomain;
    }
    switch (param.type) {
      case NullableType.avartar:
        break;
      default:
    }

    return userDomain;
  }
}
