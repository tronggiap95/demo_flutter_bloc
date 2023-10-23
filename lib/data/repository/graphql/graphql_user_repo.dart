import 'package:octo360/data/model/graphql/model/user/user.dart';
import 'package:octo360/data/model/graphql/request/update_profile_input/update_profile_input.dart';
import 'package:octo360/data/remote/graphql/functions/user/sub/update/update_profile_function.dart';

abstract class GraphQlUserRepo {
  //******************* PROFILE APIs ************************************** */
  Future<User> getProfile({bool isPrintLog = false});
  Future<void> updateProfile(UpdateProfileInput input,
      {NullableParam? nullableParam, bool isPrintLog = false});
  Future<void> deleteProfile({bool isPrintLog = false});
}
