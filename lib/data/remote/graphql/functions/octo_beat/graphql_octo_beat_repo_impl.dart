import 'package:octo360/data/model/graphql/request/ecg0_study_by_patient_info_filter/ecg0_study_by_patient_info_filter.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';
import 'package:octo360/data/remote/graphql/functions/octo_beat/sub/get/get_study_octobeat_function.dart';
import 'package:octo360/data/remote/graphql/graphql_client.dart';
import 'package:octo360/data/repository/graphql/graphql_octo_beat_repo.dart';

class GraphQlOctoBeatRepoImpl extends GraphQlOctoBeatRepo {
  final GraphQLClientApp _client;
  GraphQlOctoBeatRepoImpl(this._client);

  @override
  Future<ECG0StudyByPatientInfo?> getStudyByPatientInfo({
    required ECG00StudyByPatientInfoFilter filter,
    isPrintLog = false,
  }) {
    return GetStudyOctobeatFunction.getStudyByPatientInfo(
      _client,
      filter,
      isPrintLog: isPrintLog,
    );
  }
}
