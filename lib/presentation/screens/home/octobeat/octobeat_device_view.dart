import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:octo360/data/remote/socketio/socket_manager.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_device_view_bloc.dart';
import 'package:octo360/domain/model/home/octobeat/octobeat_device_view_state.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/providers/home/home_provider.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/screens/home/octobeat/octobeat_no_study_view.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OctoBeatDeviceView extends StatefulWidget {
  const OctoBeatDeviceView({super.key});

  @override
  State<OctoBeatDeviceView> createState() => _OctoBeatDeviceViewState();
}

class _OctoBeatDeviceViewState extends State<OctoBeatDeviceView> {
  @override
  void initState() {
    SocketManager.connectSocket(context);
    context.read<OctoBeatDeviceViewBloc>().initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OctoBeatDeviceViewBloc, OctoBeatDeviceViewState>(
        builder: (context, state) {
          switch (state.screenState) {
            case ScreenState.haveStudy:
              return octoBeatStudyViewProvider(study: state.study);
            case ScreenState.noStudy:
              return OctobeatNoStudyView(
                phoneNumber: state.phoneNumber ?? '',
              );
            default:
              return _renderLoadingView();
          }
        },
      ),
    );
  }

  Widget _renderLoadingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              width: 180,
              height: 160,
              child: SizedBox(
                width: 80,
                height: 80,
                child: Lottie.asset(
                  ImagesApp.loadingAnimation,
                  frameRate: FrameRate.max,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: MarginApp.m16),
              child: Text(
                StringsApp.weAreCompletingTheNecessary,
                style: TextStylesApp.regular(
                  color: ColorsApp.coalDarkest,
                  fontSize: FontSizeApp.s16,
                  lineHeight: SizeApp.s24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderMainScreen() {
    return Container(
      width: double.infinity,
      color: ColorsApp.fogBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _renderBackground(),
          Padding(
            padding: const EdgeInsets.all(PaddingApp.p24),
            child: Column(
              children: [
                _renderMsg(),
                _renderConnectBtn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderConnectBtn() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: MarginApp.m32),
      child: BlocSelector<OctoBeatDeviceViewBloc, OctoBeatDeviceViewState,
          String?>(
        selector: (state) {
          return state.deviceId;
        },
        builder: (context, state) {
          return FilledButtonApp(
            label: StringsApp.connectNow,
            onPressed: () {
              NavigationApp.routeTo(
                context,
                Routes.octoBeatPairDeviceRoute,
                agrs: {
                  "deviceId": state,
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _renderMsg() {
    return Text(
      StringsApp.connectToYourOctobeatFor,
      style: TextStylesApp.medium(
        color: ColorsApp.coalDarker,
        fontSize: FontSizeApp.s24,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _renderBackground() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Image.asset(
            ImagesApp.bgHome,
            fit: BoxFit.fitWidth,
          ),
        ),
        Image.asset(ImagesApp.octobeatDevice),
      ],
    );
  }
}
