import 'package:octo360/data/model/graphql/response/mutation_response.dart';
import 'package:octo360/data/remote/graphql/exceptions/graphql_exception_handler.dart';
import 'package:octo360/data/remote/graphql/graphql_client.dart';
import 'package:octo360/data/remote/graphql/mutations/user/delete_profile.dart';

class DeleteProfileFunction {
  static Future<void> delete(GraphQLClientApp _client,
      {bool isPrintLog = false}) async {
    try {
      final res = await _client.mutation(
          queries: deleteProfileMutation, isPrintLog: isPrintLog);
      if (res.hasException) {
        throw GraphQLExceptionHandler.handleException(res.exception);
      }
      final Map<String, dynamic>? data = res.data;
      Map<String, dynamic> json = data!['deleteProfile'];
      final result = MutationResponse.fromJson(json);
      if (!result.isSuccess) {
        throw GraphQLExceptionHandler.handleException(result.message);
      }
      return;
    } catch (error) {
      throw GraphQLExceptionHandler.handleException(error);
    }
  }
}
