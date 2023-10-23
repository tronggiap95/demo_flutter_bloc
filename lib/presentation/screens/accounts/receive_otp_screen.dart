import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/domain/bloc/account/receive_otp_screen_bloc.dart';
import 'package:octo360/domain/model/account/receive_otp_screen_state.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/presentation/widgets/button/resend_button/resend_otp_button.dart';
import 'package:octo360/presentation/widgets/input/otp_input/otp_input.dart';
import 'package:octo360/presentation/widgets/snack_bar/custom_snackar/custom_snackbar.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class ReceiveOtpScreen extends StatefulWidget {
  const ReceiveOtpScreen({super.key});

  static Map<String, String> routeParam(
      {required String phoneNumber, required String countryCode}) {
    return {'phoneNumber': phoneNumber, 'countryCode': countryCode};
  }

  @override
  State<ReceiveOtpScreen> createState() => _ReceiveOtpScreenState();
}

class _ReceiveOtpScreenState extends State<ReceiveOtpScreen> {
  var inited = false;

  @override
  void didChangeDependencies() {
    if (!inited) {
      inited = true;
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      final phoneNumber = arguments?['phoneNumber'];
      final countryCode = arguments?['countryCode'];

      context.read<ReceiveOtpScreenBloc>().initState(phoneNumber, countryCode);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ReceiveOtpScreenBloc, ReceiveOtpScreenState>(
        listenWhen: (previous, current) =>
            previous.screenState != current.screenState,
        listener: (context, state) {
          _handleListener(state);
        },
        child: SafeArea(
            child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            // *NOTE: should have color for gesture detector can tap
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: MarginApp.m16),
                  _renderCloseButton(),
                  const SizedBox(height: MarginApp.m24),
                  _renderTitle(),
                  _renderOtpInput(),
                  const SizedBox(height: MarginApp.m24),
                  _renderConfirmButton(),
                  const SizedBox(height: MarginApp.m12),
                  _renderResendButton(),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  void _handleListener(ReceiveOtpScreenState state) {
    switch (state.screenState) {
      case BaseScreenState.success:
        context.read<ReceiveOtpScreenBloc>().resetScreenState();
      case BaseScreenState.failed:
        CustomSnackBar.displaySnackBar(
          context: context,
          message: state.screenError,
          imagePath: ImagesApp.icError,
          marginBottom: SizeApp.s24,
        );
        context.read<ReceiveOtpScreenBloc>().resetScreenState();
      case BaseScreenState.noInternet:
        CustomSnackBar.displaySnackBar(
          context: context,
          message: state.screenError,
          imagePath: ImagesApp.icError,
          marginBottom: SizeApp.s24,
        );
        context.read<ReceiveOtpScreenBloc>().resetScreenState();
      default:
        break;
    }
  }

  Widget _renderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringsApp.enterOtp,
          style: TextStylesApp.bold(
              color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s30),
        ),
        const SizedBox(height: MarginApp.m24),
        Text(StringsApp.enterOtpSentToPhoneNumber,
            style: TextStylesApp.regular(
                color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s14)),
        const SizedBox(height: MarginApp.m12),
        Text(context.read<ReceiveOtpScreenBloc>().displayPhoneNumberStr(),
            style: TextStylesApp.semiBold(
                color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s16)),
        const SizedBox(height: MarginApp.m24),
      ],
    );
  }

  Widget _renderResendButton() {
    return BlocSelector<ReceiveOtpScreenBloc, ReceiveOtpScreenState, int>(
      selector: (state) => state.countDownTime,
      builder: (context, countDownTime) {
        return Row(
          children: [
            Text(
              StringsApp.youCantReceiveCode,
              style: TextStylesApp.semiBold(
                  color: ColorsApp.coalDarker, fontSize: FontSizeApp.s14),
            ),
            ResendOtpButton(
              countTime: countDownTime,
              onPressedSendOtp: () {
                context.read<ReceiveOtpScreenBloc>().resendOtp();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _renderOtpInput() {
    return BlocBuilder<ReceiveOtpScreenBloc, ReceiveOtpScreenState>(
      buildWhen: (previous, current) =>
          previous.inputError != current.inputError,
      builder: (context, state) {
        return OtpInput(
          keyboardShowDuration: 100,
          isAutoFillSms: true,
          shouldShowKeyboard: state.shouldShowKeyboard,
          setShowKeyboard: (isShow) =>
              context.read<ReceiveOtpScreenBloc>().setShowKeyboard(isShow),
          textInputType: TextInputType.number,
          onDone: () {
            FocusScope.of(context).unfocus();
            context.read<ReceiveOtpScreenBloc>().confirm();
          },
          onFocus: () {
            context.read<ReceiveOtpScreenBloc>().setInputError(null);
          },
          textCapitalization: TextCapitalization.characters,
          error: state.inputError,
          onChanged: (value) {
            context.read<ReceiveOtpScreenBloc>().setOtp(value);
          },
        );
      },
    );
  }

  Widget _renderConfirmButton() {
    return BlocBuilder<ReceiveOtpScreenBloc, ReceiveOtpScreenState>(
      buildWhen: (previous, current) {
        return previous.isEnable != current.isEnable ||
            previous.screenState != current.screenState;
      },
      builder: (context, state) {
        return SizedBox(
            width: double.infinity,
            child: FilledButtonApp(
                isEnable: state.isEnable,
                label: StringsApp.confirm,
                isLoading: state.screenState == BaseScreenState.loading,
                onPressed: () {
                  context.read<ReceiveOtpScreenBloc>().confirm();
                }));
      },
    );
  }

  Widget _renderCloseButton() {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(color: ColorsApp.primaryBase, width: 1),
            borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            NavigationApp.back(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(PaddingApp.p10),
            child: SvgPicture.asset(
              ImagesApp.icArrowLeft,
              width: SizeApp.s16,
              height: SizeApp.s16,
            ),
          ),
        ),
      ),
    );
  }
}
