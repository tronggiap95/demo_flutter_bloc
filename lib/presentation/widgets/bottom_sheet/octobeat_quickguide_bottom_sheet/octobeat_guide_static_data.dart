import 'package:octo360/presentation/widgets/guide_view/octobeat_quickguide_pages.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';

class OctobeatGuideStaticData {
  static List<OctobeatQuickGuideItem> get listOctobeat => [
        OctobeatQuickGuideItem(
            StringsApp.unifieldMaleAndFemaleApplication,
            ImagesApp.octobeatGuideFirst,
            StringsApp.raFirstPageContent,
            StringsApp.llFirstPageContent,
            StringsApp.laFirstPageContent,
            false,
            true,
            ImagesApp.raIcon,
            ImagesApp.llIcon,
            ImagesApp.laIcon,
            false),
        OctobeatQuickGuideItem(
            StringsApp.alternativePlacementOption,
            ImagesApp.octobeatGuideSecond,
            StringsApp.raSecondPageContent,
            StringsApp.llSecondPageContent,
            StringsApp.laSecondPageContent,
            true,
            true,
            ImagesApp.raIcon,
            ImagesApp.llIcon,
            ImagesApp.laIcon,
            false),
        OctobeatQuickGuideItem(
            StringsApp.thingNotToDo,
            ImagesApp.octobeatGuideThird,
            StringsApp.dontPowerOff,
            StringsApp.octobeatDevice,
            '',
            true,
            true,
            '',
            '',
            '',
            true)
      ];
}
