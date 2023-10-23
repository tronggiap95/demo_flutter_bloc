import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/data/model/graphql/model/user/user.dart';
import 'package:octo360/data/remote/graphql/exceptions/graphql_exception_handler.dart';
import 'package:octo360/data/remote/graphql/graphql_client.dart';
import 'package:octo360/data/remote/graphql/queries/user/me.dart';

class GetProfileFunction {
  static Future<User> get(GraphQLClientApp _client,
      {bool isPrintLog = false}) async {
    try {
      final res = await _client.query(isPrintLog: isPrintLog, queries: meQuery);
      if (res.hasException) {
        throw GraphQLExceptionHandler.handleException(res.exception);
      }
      final Map<String, dynamic>? data = res.data;
      Map<String, dynamic> json = data!['me'];
      final globalRepo = FactoryManager.provideGlobalRepo();
      final globalUser = User.fromJson(json);
      globalRepo.userDomain = globalUser.toUserDomain();
      return globalUser;
    } catch (error) {
      Log.e("getProfile $error");
      throw GraphQLExceptionHandler.handleException(error);
    }
  }
}
