import 'dart:isolate';

import 'package:gql/ast.dart';
import 'package:gql/language.dart';
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:octo360/application/env/env_config.dart';
import 'package:octo360/application/utils/internet/internet_connection.dart';
import 'package:octo360/data/remote/dio/dio_client.dart';
import 'package:octo360/data/remote/graphql/exceptions/graphql_exception_handler.dart';
import 'package:octo360/data/remote/graphql/graphql_header.dart';

abstract class GraphQLClientApp {
  String _defaultEndPoint = EnvConfigApp.getEnv().endpoint;
  GraphQLHeaderType _defaultHeaderType = GraphQLHeaderType.defaultHeader;

  void setDefaultEndPoint(String value) {
    _defaultEndPoint = value;
  }

  void setDefaultHeaderType(GraphQLHeaderType value) {
    _defaultHeaderType = value;
  }

  Future<QueryResult> query({
    String endPoint,
    required String queries,
    Map<String, dynamic>? variables,
    GraphQLHeaderType? type,
    bool isPrintLog = false,
  });

  Future<QueryResult> mutation({
    String endPoint,
    required String queries,
    Map<String, dynamic>? variables,
    GraphQLHeaderType? type,
    bool isPrintLog = false,
  });
}

class GraphQLClientImpl extends GraphQLClientApp {
  Future<Link> _link(String endPoint, Map<String, String> headers,
      {isPrintLog = false}) async {
    final client = await DioClient.getDio(headers, isPrintLog: isPrintLog);
    return DioLink(
      endPoint,
      client: client,
    );
  }

  Future<GraphQLClient> _client(String endPoint, Map<String, String> headers,
      {isPrintLog = false}) async {
    /// Policies
    final policies = Policies(
      fetch: FetchPolicy.networkOnly,
    );

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: await _link(endPoint, headers, isPrintLog: isPrintLog),
      defaultPolicies: DefaultPolicies(
        watchMutation: policies,
        query: policies,
        mutate: policies,
        subscribe: policies,
      ),
    );
  }

  /// Start query
  @override
  Future<QueryResult> query({
    String? endPoint,
    required String queries,
    Map<String, dynamic>? variables,
    FetchPolicy fetchPolicy = FetchPolicy.noCache,
    GraphQLHeaderType? type,
    bool isPrintLog = false,
  }) async {
    // Get headers
    final headers =
        await GraphQLHeader.getHeaders(type: type ?? _defaultHeaderType);

    //Check internet connection
    if (await InternetConnection.hasInternetConnection() == false) {
      throw DataSource.NO_INTERNET_CONNECTION.getFailure();
    }
    //Get base Url
    final url = endPoint ?? _defaultEndPoint;

    //Create watch query
    final WatchQueryOptions options = WatchQueryOptions(
      document: _shouldCustomGql(type: type ?? _defaultHeaderType)
          ? customGql(queries)
          : gql(queries),
      pollInterval: const Duration(seconds: 15),
      fetchPolicy: fetchPolicy,
      variables: variables ?? {},
      fetchResults: true,
    );

    //create and running isolate
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn<List<dynamic>>(_queryLongRunning,
        [url, headers, isPrintLog, options, receivePort.sendPort]);
    final result = await receivePort.first;
    isolate.kill(priority: Isolate.immediate);

    return result;
  }

  Future<void> _queryLongRunning(List<dynamic> param) async {
    final url = param[0] as String;
    final headers = param[1] as Map<String, String>;
    final isPrintLog = param[2] as bool;
    final options = param[3] as WatchQueryOptions;
    final sendPort = param[4] as SendPort;

    final client = await _client(url, headers, isPrintLog: isPrintLog);
    final result = await client.query(options);
    sendPort.send(result);
  }

  /// Start mutation
  @override
  Future<QueryResult> mutation(
      {String? endPoint,
      required String queries,
      Map<String, dynamic>? variables,
      FetchPolicy fetchPolicy = FetchPolicy.noCache,
      GraphQLHeaderType? type,
      bool isPrintLog = false}) async {
    //Check internet connection
    if (await InternetConnection.hasInternetConnection() == false) {
      throw DataSource.NO_INTERNET_CONNECTION.getFailure();
    }

    //Get base Url
    final url = endPoint ?? _defaultEndPoint;

    // Get headers
    final headers = await GraphQLHeader.getHeaders(
      type: type ?? _defaultHeaderType,
    );

    //Create mutation options
    final MutationOptions options = MutationOptions(
      fetchPolicy: fetchPolicy,
      document: _shouldCustomGql(type: type ?? _defaultHeaderType)
          ? customGql(queries)
          : gql(queries),
      variables: variables ?? {},
    );

    //Create and run isolate
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn<List<dynamic>>(_mutationLongRunning,
        [url, headers, isPrintLog, options, receivePort.sendPort]);
    final result = await receivePort.first;
    isolate.kill(priority: Isolate.immediate);

    return result;
  }

  bool _shouldCustomGql({required GraphQLHeaderType type}) {
    switch (type) {
      case GraphQLHeaderType.guest:
        return true;
      case GraphQLHeaderType.medication:
        return true;
      default:
        return false;
    }
  }

  DocumentNode customGql(String document) => parseString(document);

  Future<void> _mutationLongRunning(List<dynamic> param) async {
    final url = param[0] as String;
    final headers = param[1] as Map<String, String>;
    final isPrintLog = param[2] as bool;
    final options = param[3] as MutationOptions;
    final sendPort = param[4] as SendPort;

    final client = await _client(url, headers, isPrintLog: isPrintLog);
    final result = await client.mutate(options);
    sendPort.send(result);
  }
}
