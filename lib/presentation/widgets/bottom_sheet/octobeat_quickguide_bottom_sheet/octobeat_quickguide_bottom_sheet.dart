import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/widgets/bottom_sheet/octobeat_quickguide_bottom_sheet/octobeat_guide_static_data.dart';

import 'package:octo360/presentation/widgets/guide_view/octobeat_quickguide_pages.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/values/values_manager.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class OctobeatQuickGuideBottomSheet extends StatefulWidget {
  const OctobeatQuickGuideBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<OctobeatQuickGuideBottomSheet> createState() =>
      _OctobeatQuickGuideBottomSheetState();
}

class _OctobeatQuickGuideBottomSheetState
    extends State<OctobeatQuickGuideBottomSheet> {
  final _controllerForOctobeat =
      PageController(viewportFraction: 1, keepPage: true);
  int currentPage = 1;
  void _goToPage(int page) {
    if (page == 3) {
      NavigationApp.back(context);
      return;
    }
    setState(() {
      currentPage = page + 1;
    });
    _controllerForOctobeat.animateToPage(page,
        duration: const Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _renderIndicator(),
          _renderPageview(),
        ],
      )),
    );
  }

  Widget _renderPageview() {
    return Expanded(
      child: PageView.builder(
        itemBuilder: (context, index) => OctobeatQuickGuidePages(
          octobeatItem: OctobeatGuideStaticData.listOctobeat[index],
          onPressedBack: (() {
            _goToPage(index - 1);
          }),
          onPressedNext: () {
            _goToPage(index + 1);
          },
        ),
        onPageChanged: ((value) {
          _goToPage(value);
        }),
        controller: _controllerForOctobeat,
        itemCount: OctobeatGuideStaticData.listOctobeat.length,
        padEnds: false,
        physics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _renderIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
      child: Column(
        children: [
          const SizedBox(height: MarginApp.m16),
          StepProgressIndicator(
            totalSteps: OctobeatGuideStaticData.listOctobeat.isEmpty
                ? 1
                : OctobeatGuideStaticData.listOctobeat.length,
            currentStep: currentPage,
            selectedColor: ColorsApp.secondaryBase,
            unselectedColor: ColorsApp.coalLighter,
            roundedEdges: const Radius.circular(RadiusApp.r3),
            size: SizeApp.s6,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: PaddingApp.p16),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: SvgPicture.asset(
                  ImagesApp.icClose,
                  height: SizeApp.s24,
                  width: SizeApp.s24,
                ),
                onPressed: () {
                  NavigationApp.back(context, true);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
