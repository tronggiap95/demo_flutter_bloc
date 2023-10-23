import 'package:octo360/src/strings/string_manager.dart';

class OctoBeatSymptomsSnapshotStaticData {
  static List<String> get octoBeatSymptoms => [
        StringsApp.palpitations,
        StringsApp.shortnessOfBreath,
        StringsApp.dizziness,
        StringsApp.chestPainOrPressure,
        StringsApp.other,
      ];

  static const int defaultCountdownTime = 20;
}
