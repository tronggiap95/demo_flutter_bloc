import 'package:get_it/get_it.dart';
import 'package:octo360/data/remote/socketio/octobeat/socket_octobeat_device_handler.dart';
import 'package:octo360/data/remote/socketio/octobeat/socketio_octobeat_client.dart';
import 'package:octo360/data/remote/socketio/socketio_client.dart';
import 'package:octo360/data/repository/auth/authen_repo.dart';
import 'package:octo360/data/repository/graphql/graphql_octo_beat_repo.dart';
import 'package:octo360/data/repository/graphql/graphql_user_repo.dart';
import 'package:octo360/domain/model/global/global_repo.dart';

class FactoryManager {
  //********************** AUTHEN ******************************
  static AuthenRepo provideAuthenRepo() => GetIt.I.get<AuthenRepo>();

  //********************** SOCKET ******************************
  static SocketIOClient provideSocketIO() => GetIt.I.get<SocketIOClient>();
  static SocketIOOctoBeatClient provideSocketIOOctoBeatClient() =>
      GetIt.I.get<SocketIOOctoBeatClient>();
  static SocketOctoBeatDevice provideSocketOctoBeatDevice() =>
      GetIt.I.get<SocketOctoBeatDevice>();

  static GlobalRepo provideGlobalRepo() => GetIt.I.get<GlobalRepo>();

  //********************** GRAPQL REPO ******************************
  static GraphQlUserRepo provideGraphQlUserRepo() =>
      GetIt.I.get<GraphQlUserRepo>();
  static GraphQlOctoBeatRepo provideGraphQlOctoBeatRepo() =>
      GetIt.I.get<GraphQlOctoBeatRepo>();
}
