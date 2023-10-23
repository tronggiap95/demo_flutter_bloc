import 'package:get_it/get_it.dart';
import 'package:octo360/data/remote/amplify/auth_repo_impl.dart';
import 'package:octo360/data/remote/graphql/functions/octo_beat/graphql_octo_beat_repo_impl.dart';
import 'package:octo360/data/remote/graphql/functions/user/graphql_user_repo_impl.dart';
import 'package:octo360/data/remote/graphql/graphql_client.dart';
import 'package:octo360/data/remote/socketio/octobeat/socket_octobeat_device_handler.dart';
import 'package:octo360/data/remote/socketio/octobeat/socketio_octobeat_client.dart';
import 'package:octo360/data/remote/socketio/socketio_client.dart';
import 'package:octo360/data/repository/auth/authen_repo.dart';
import 'package:octo360/data/repository/graphql/graphql_octo_beat_repo.dart';
import 'package:octo360/data/repository/graphql/graphql_user_repo.dart';
import 'package:octo360/domain/model/global/global_repo.dart';

final instance = GetIt.instance;

bool isModuleRegistered() {
  try {
    return GetIt.instance.isRegistered<AuthenRepo>();
  } catch (error) {
    return false;
  }
}

void initModule() {
  //AUTHEN REPO
  instance.registerLazySingleton<AuthenRepo>(() {
    return AuthenRepoImpl();
  });

  //GRAPHQL REPO
  _initGraphQl();

  //SOCKET REPO
  _initSocketIO();

  //LOCAL DATABASE REPO
  _initLocalDB();

  //GLOBAL DATA REPO
  instance.registerLazySingleton<GlobalRepo>(() => GlobalRepo());
}

void _initGraphQl() {
  instance.registerLazySingleton<GraphQLClientApp>(() => GraphQLClientImpl());
  instance.registerLazySingleton<GraphQlUserRepo>(() {
    return GraphQlUserRepoImpl(instance());
  });
  instance.registerLazySingleton<GraphQlOctoBeatRepo>(() {
    return GraphQlOctoBeatRepoImpl(instance());
  });
}

void _initSocketIO() {
  instance
      .registerLazySingleton<SocketIOClient>(() => SocketIOOctoBeatClient());
  instance.registerLazySingleton<SocketOctoBeatDevice>(
      () => SocketOctoBeatDeviceHandler(socketClient: instance()));
}

void _initLocalDB() {}
