import 'package:octo360/data/model/graphql/model/user/user.dart';
import 'package:octo360/data/model/graphql/request/update_profile_input/update_profile_input.dart';
import 'package:octo360/data/remote/graphql/functions/user/sub/delete/delete_profile_function.dart';
import 'package:octo360/data/remote/graphql/functions/user/sub/get/get_profile_function.dart';
import 'package:octo360/data/remote/graphql/functions/user/sub/update/update_profile_function.dart';
import 'package:octo360/data/remote/graphql/graphql_client.dart';
import 'package:octo360/data/repository/graphql/graphql_user_repo.dart';

class GraphQlUserRepoImpl extends GraphQlUserRepo {
  final GraphQLClientApp _client;
  GraphQlUserRepoImpl(this._client);

  @override
  Future<User> getProfile({bool isPrintLog = false}) {
    return GetProfileFunction.get(_client, isPrintLog: isPrintLog);
  }

  @override
  Future<void> updateProfile(UpdateProfileInput input,
      {NullableParam? nullableParam, bool isPrintLog = false}) {
    return UpdateProfileFunction.update(_client, input);
  }

  @override
  Future<void> deleteProfile({bool isPrintLog = false}) {
    return DeleteProfileFunction.delete(_client, isPrintLog: isPrintLog);
  }
}
