import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:octo360/application/enum/octobeat_trouble_shooting_menu_enum.dart';
import 'package:octo360/domain/bloc/global_bloc.dart';
import 'package:octo360/l10n/locale_enum.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/widgets/app_bar/custom_app_bar/custom_app_bar.dart';
import 'package:octo360/presentation/widgets/bottom_sheet/contact_support_bottom_sheet/contact_support_bottom_sheet.dart';
import 'package:octo360/presentation/widgets/card/select_card/select_card.dart';
import 'package:octo360/presentation/widgets/modifiedFlutterWidgets/octomed_expansion_panel/octomed_expansion_panel.dart';
import 'package:octo360/presentation/widgets/shadowBox/container_with_shadow/container_with_shadow.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OctobeatTroubleshootingScreen extends StatefulWidget {
  const OctobeatTroubleshootingScreen({Key? key}) : super(key: key);

  @override
  State<OctobeatTroubleshootingScreen> createState() =>
      _OctobeatTroubleshootingScreenState();
}

class _OctobeatTroubleshootingScreenState
    extends State<OctobeatTroubleshootingScreen> {
  var inited = false;
  OctoBeatTroubleShootingMenuEnum? initialOpenPanelValue;

  @override
  void didChangeDependencies() {
    if (!inited) {
      inited = true;
      final arguments = ModalRoute.of(context)?.settings.arguments
          as Map<String, OctoBeatTroubleShootingMenuEnum>?;
      final selectItem = arguments?['selectItem'];
      initialOpenPanelValue = selectItem;
    }
    super.didChangeDependencies();
  }

  final _contentTextStyle = TextStylesApp.regular(
    color: ColorsApp.coalDarkest,
    fontSize: FontSizeApp.s14,
  ).copyWith(height: SizeApp.s22 / FontSizeApp.s14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.fogBackground,
      appBar: _renderAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: PaddingApp.p16,
                  bottom: PaddingApp.p12,
                ),
                child: Text(
                  StringsApp.selectYourIssueToView,
                  style: TextStylesApp.regular(
                    color: ColorsApp.coalDarker,
                    fontSize: FontSizeApp.s14,
                  ),
                ),
              ),
              OctomedExpansionPanelList.radio(
                initialOpenPanelValue: initialOpenPanelValue,
                elevation: ElevationApp.ev0,
                dividerColor: ColorsApp.fogBackground,
                expandedHeaderPadding: EdgeInsets.zero,
                animationDuration: const Duration(milliseconds: 500),
                children: [
                  _troubleShootingPanel(
                    StringsApp.deviceConnection,
                    OctoBeatTroubleShootingMenuEnum.deviceConnection,
                    _deviceConnectionBody(),
                  ),
                  _troubleShootingPanel(
                    StringsApp.serverConnection,
                    OctoBeatTroubleShootingMenuEnum.serverConnection,
                    _serverConnectionBody(),
                  ),
                  _troubleShootingPanel(
                    StringsApp.studyPaused,
                    OctoBeatTroubleShootingMenuEnum.studyPaused,
                    _studyPausedBody(),
                  ),
                ],
              ),
              const SizedBox(height: SizeApp.s16),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _renderAppBar() {
    return CustomAppBar(
      backgroundColor: ColorsApp.white,
      leadingWidget: IconButton(
        onPressed: () => NavigationApp.back(context),
        icon: SvgPicture.asset(
          ImagesApp.icArrowBackAndroid,
          height: SizeApp.s24,
          width: SizeApp.s24,
        ),
      ),
      centerTitle: true,
      titleWidget: Text(
        StringsApp.troubleshooting,
        style: TextStylesApp.medium(
          color: ColorsApp.coalDarkest,
          fontSize: FontSizeApp.s16,
        ),
      ),
      displayBottomSeparator: true,
    );
  }

  OctomedExpansionPanelRadio _troubleShootingPanel(
      String label, OctoBeatTroubleShootingMenuEnum value, Widget body) {
    return OctomedExpansionPanelRadio(
      hasIcon: false, // remove default icon
      backgroundColor: ColorsApp.fogBackground,
      canTapOnHeader: true,
      headerBuilder: (context, isOpen) {
        return _renderHeaderPanel(label, isOpen);
      },
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: MarginApp.m4),
        child: body,
      ),
      value: value,
    );
  }

  Widget _renderHeaderPanel(String label, bool isOpen) {
    return ContainerWithShadow(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: PaddingApp.p12,
          vertical: PaddingApp.p16,
        ),
        margin: const EdgeInsets.symmetric(vertical: PaddingApp.p4),
        decoration: BoxDecoration(
          color: isOpen ? ColorsApp.primaryLightest : ColorsApp.white,
          borderRadius: BorderRadius.circular(BorderRadiusApp.r8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStylesApp.medium(
                color: ColorsApp.coalDarker,
                fontSize: FontSizeApp.s16,
              ),
            ),
            AnimatedRotation(
              turns: isOpen ? 1 / 4 : 0, // turns 90 degrees
              duration: const Duration(milliseconds: 350),
              child: SvgPicture.asset(
                ImagesApp.icCaret,
                color: ColorsApp.coalDarker,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceConnectionBody() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PaddingApp.p16),
      decoration: BoxDecoration(
          color: ColorsApp.white,
          borderRadius: BorderRadius.circular(BorderRadiusApp.r8),
          border: Border.all(
            color: ColorsApp.primaryLightest,
          )),
      child: Text(
        StringsApp.theDeviceMightNotBe,
        style: _contentTextStyle,
      ),
    );
  }

  Widget _serverConnectionBody() {
    return Column(
      children: [
        _renderServerConnectionSolutions(),
        const SizedBox(height: SizeApp.s24),
        Text(StringsApp.ifYouHaveTriedTheSuggestedSolutions,
            style: _contentTextStyle),
        const SizedBox(height: SizeApp.s16),
        _renderContactSupportButton(),
        const SizedBox(height: SizeApp.s16),
      ],
    );
  }

  Widget _studyPausedBody() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PaddingApp.p16),
      decoration: BoxDecoration(
        color: ColorsApp.white,
        borderRadius: BorderRadius.circular(BorderRadiusApp.r8),
        border: Border.all(
          color: ColorsApp.primaryLightest,
        ),
      ),
      child: Text(
        StringsApp.yourStudyPausesAutomatically,
        style: _contentTextStyle,
      ),
    );
  }

  Widget _renderServerConnectionSolutions() {
    return Container(
      padding: const EdgeInsets.all(PaddingApp.p16),
      decoration: BoxDecoration(
        color: ColorsApp.white,
        borderRadius: BorderRadius.circular(BorderRadiusApp.r8),
        border: Border.all(
          color: ColorsApp.primaryLightest,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: _contentTextStyle),
              Expanded(
                child: Text(
                  StringsApp.theDeviceIsOfflineThisOccurs,
                  style: _contentTextStyle,
                ),
              )
            ],
          ),
          const SizedBox(height: SizeApp.s16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: _contentTextStyle),
              Expanded(
                child: Text(
                  StringsApp.confirmTheDeviceIsPowered,
                  style: _contentTextStyle,
                ),
              )
            ],
          ),
          const SizedBox(height: SizeApp.s16),
          Image.asset(
            key: ValueKey(
              GlobalBloc.currentLocaleStatic.withTag('wirelessSignal'),
            ),
            ImagesApp.wirelessSignal.withLocale(),
          ),
        ],
      ),
    );
  }

  Widget _renderContactSupportButton() {
    return SelectCard(
      title: StringsApp.contactSupport,
      bgColor: ColorsApp.secondaryLightest,
      textColor: ColorsApp.coalDarkest,
      iconColor: ColorsApp.coalDarkest,
      iconPaddingRight: PaddingApp.p4,
      containerPadding: PaddingApp.p8,
      leftIcon: Padding(
        padding: const EdgeInsets.only(right: PaddingApp.p12),
        child: SvgPicture.asset(ImagesApp.icContactSupport),
      ),
      onTap: () => _displayContactSupport(),
    );
  }

  void _displayContactSupport() {
    showCupertinoModalBottomSheet(
      duration: DurationsApp.bottomSheetFullScreenDuration,
      animationCurve: Curves.easeOut,
      enableDrag: false,
      context: context,
      builder: (context) => const ContactSupportBottomSheet(),
      barrierColor: Colors.transparent.withOpacity(0.5),
      topRadius: const Radius.circular(RadiusApp.r16),
    );
  }
}
