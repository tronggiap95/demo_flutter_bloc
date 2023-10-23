import 'package:octo360/data/model/graphql/request/ecg0_study_by_patient_info_filter/ecg0_study_by_patient_info_filter.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';

abstract class GraphQlOctoBeatRepo {
  Future<ECG0StudyByPatientInfo?> getStudyByPatientInfo({
    required ECG00StudyByPatientInfoFilter filter,
    isPrintLog = false,
  });
}
