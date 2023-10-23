import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/model/graphql/request/ecg0_study_by_patient_info_filter/ecg0_study_by_patient_info_filter.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_by_patient_info_response/ecg0_study_by_patient_info_response.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';
import 'package:octo360/data/remote/graphql/exceptions/graphql_exception_handler.dart';
import 'package:octo360/data/remote/graphql/graphql_client.dart';
import 'package:octo360/data/remote/graphql/queries/octo_beat/ecg0_study_by_patient_info_querry.dart';

class GetStudyOctobeatFunction {
  static Future<ECG0StudyByPatientInfo?> getStudyByPatientInfo(
    GraphQLClientApp client,
    ECG00StudyByPatientInfoFilter filter, {
    bool isPrintLog = false,
  }) async {
    try {
      final params = {"filter": filter.toJson()};
      final res = await client.query(
        isPrintLog: true,
        queries: ecg0studyByPatientInfoQuerry,
        variables: params,
      );
      if (res.hasException) {
        throw GraphQLExceptionHandler.handleException(res.exception);
      }
      final Map<String, dynamic>? data = res.data;
      Map<String, dynamic> json = data!['ECG0studyByPatientInfo'];

      return ECG0StudyByPatientInfoResponse.fromJson(json).study;
    } catch (error) {
      Log.e("getStudyByPatientInfo: $error");
      throw GraphQLExceptionHandler.handleException(error);
    }
  }
}
