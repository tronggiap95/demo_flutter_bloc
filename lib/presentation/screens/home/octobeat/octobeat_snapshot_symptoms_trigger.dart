import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/application/constants/octobeat_symptoms_snapshot_static_data.dart';
import 'package:octo360/application/utils/widget/widget_utils.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_snapshot_symptoms_trigger_bloc.dart';
import 'package:octo360/domain/model/home/octobeat/octobeat_snapshot_symptoms_trigger_state.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/presentation/widgets/button/outline_button/outline_button.dart';
import 'package:octo360/presentation/widgets/check_box/square_check_box/square_check_box.dart';
import 'package:octo360/presentation/widgets/separator/dash_separator/dash_separator.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OctoBeatSnapshotSymptomsTrigger extends StatefulWidget {
  final int eventTime;
  final int timeRemaining;
  const OctoBeatSnapshotSymptomsTrigger({
    required this.eventTime,
    required this.timeRemaining,
    Key? key,
  }) : super(key: key);

  @override
  State<OctoBeatSnapshotSymptomsTrigger> createState() =>
      _OctoBeatSnapshotSymptomsTriggerState();
}

class _OctoBeatSnapshotSymptomsTriggerState
    extends State<OctoBeatSnapshotSymptomsTrigger> {
  final symptoms = OctoBeatSymptomsSnapshotStaticData.octoBeatSymptoms;
  @override
  void initState() {
    super.initState();
    context
        .read<OctoBeatSnapshotSymptomsTriggerBloc>()
        .initState(widget.eventTime, widget.timeRemaining);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OctoBeatSnapshotSymptomsTriggerBloc,
        OctoBeatSnapshotSymptomsTriggerState>(
      listener: (context, state) {
        if (state.countDown == 0) {
          context
              .read<OctoBeatSnapshotSymptomsTriggerBloc>()
              .submitOctoBeatSnapshotSymptoms();
          NavigationApp.pop(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: ColorsApp.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(RadiusApp.r16),
                topRight: Radius.circular(RadiusApp.r16))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _renderAppBar(),
          _renderTimerCountDown(),
          _renderMenu(),
          _renderButton()
        ]),
      ),
    );
  }

  Widget _renderAppBar() {
    return SizedBox(
      height: ScaleSize.verticalScale(
          SizeApp.s52, MediaQuery.of(context).size.height),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(StringsApp.selectSymptoms,
                  style: TextStylesApp.bold(
                      color: ColorsApp.coalDarkest, fontSize: SizeApp.s16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _renderTimerCountDown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
          horizontal: PaddingApp.p16, vertical: PaddingApp.p10),
      decoration: BoxDecoration(
        color: ColorsApp.fogBackground,
        borderRadius: BorderRadius.circular(BorderRadiusApp.r4),
      ),
      child: BlocSelector<OctoBeatSnapshotSymptomsTriggerBloc,
          OctoBeatSnapshotSymptomsTriggerState, String>(
        selector: ((state) => state.countDown.toString()),
        builder: ((context, state) {
          return WidgetUtil.createRichText(
            value: StringsApp.theEventWillBeSent
                .replaceAll(StringsApp.replaceValue, state),
            boldStrings: [state],
            normalTextStyle: TextStylesApp.regular(
                color: ColorsApp.coalDarker, fontSize: FontSizeApp.s16),
            boldTextStyle: TextStylesApp.medium(
              color: ColorsApp.coalDarker,
              fontSize: FontSizeApp.s16,
            ),
          );
        }),
      ),
    );
  }

  Widget _renderMenu() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: symptoms.length,
            itemExtent: ScaleSize.verticalScale(SizeApp.s272 / symptoms.length,
                MediaQuery.of(context).size.height),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: PaddingApp.p13),
                      child: SquareCheckBox(
                        label: symptoms[index],
                        onValueChanged: (isCheck) {
                          context
                              .read<OctoBeatSnapshotSymptomsTriggerBloc>()
                              .onChangedSymptoms(
                                OctoBeatSymptomsSnapshotStaticData
                                    .octoBeatSymptoms[index],
                                isCheck,
                              );
                        },
                        checkBoxIsAfter: true,
                        selectedTextStyle: TextStylesApp.medium(
                          color: ColorsApp.coalDarkest,
                          fontSize: FontSizeApp.s16,
                        ),
                      ),
                    ),
                  ),
                  index ==
                          (OctoBeatSymptomsSnapshotStaticData
                                  .octoBeatSymptoms.length -
                              1)
                      ? const SizedBox()
                      : DashSeparator(
                          color: ColorsApp.coalLighter,
                        )
                ],
              );
            }),
      ),
    );
  }

  Widget _renderButton() {
    return BlocBuilder<OctoBeatSnapshotSymptomsTriggerBloc,
        OctoBeatSnapshotSymptomsTriggerState>(
      buildWhen: ((previous, current) => previous.hasData != current.hasData),
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: SizeApp.s16, bottom: SizeApp.s20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - SizeApp.s25,
                  child: OutlinedButtonApp(
                    onPressed: () {
                      context
                          .read<OctoBeatSnapshotSymptomsTriggerBloc>()
                          .onPressCloseButton();
                      NavigationApp.pop(context);
                    },
                    label: StringsApp.close,
                  ),
                ),
                const SizedBox(width: SizeApp.s16),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - SizeApp.s25,
                  child: FilledButtonApp(
                    isEnable: state.hasData,
                    onPressed: () {
                      context
                          .read<OctoBeatSnapshotSymptomsTriggerBloc>()
                          .submitOctoBeatSnapshotSymptoms();
                      NavigationApp.pop(context);
                    },
                    label: StringsApp.submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
