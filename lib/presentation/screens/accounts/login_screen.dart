import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/application/utils/widget/widget_utils.dart';
import 'package:octo360/domain/bloc/account/log_in_screen_bloc.dart';
import 'package:octo360/domain/model/account/log_in_screen_state.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/screens/accounts/receive_otp_screen.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/presentation/widgets/input/input_text_field/phone_input/phone_input.dart';
import 'package:octo360/presentation/widgets/snack_bar/custom_snackar/custom_snackbar.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LogInScreenBloc, LogInScreenState>(
        listenWhen: (previous, current) =>
            previous.screenState != current.screenState,
        listener: (context, state) {
          _handleListenState(state);
        },
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
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
                    _renderTitle(),
                    _renderPhoneInput(),
                    const SizedBox(height: MarginApp.m10),
                    _renderTermAndPrivacy(),
                    const SizedBox(height: MarginApp.m24),
                    _renderContinueButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleListenState(LogInScreenState state) {
    switch (state.screenState) {
      case BaseScreenState.failed:
        CustomSnackBar.displaySnackBar(
          context: context,
          message: state.screenError,
          imagePath: ImagesApp.icError,
          marginBottom: SizeApp.s24,
        );
        context.read<LogInScreenBloc>().resetScreenError();
        break;
      case BaseScreenState.noInternet:
        CustomSnackBar.displaySnackBar(
          context: context,
          message: state.screenError,
          imagePath: ImagesApp.icError,
          marginBottom: SizeApp.s24,
        );
        context.read<LogInScreenBloc>().resetScreenError();
        break;
      case BaseScreenState.success:
        NavigationApp.routeTo(context, Routes.receiveOtpScreenRoute,
            agrs: ReceiveOtpScreen.routeParam(
                phoneNumber: state.phoneNumber,
                countryCode: state.countryCode));
        context.read<LogInScreenBloc>().resetScreenError();

        break;
      default:
        break;
    }
  }

  Widget _renderTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MarginApp.m24),
      child: Text(
        StringsApp.startWithYourPhoneNumber,
        style: TextStylesApp.bold(
            color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s30),
      ),
    );
  }

  Widget _renderTermAndPrivacy() {
    return WidgetUtil.createRichText(
      value: StringsApp.byContinuingYouAgree,
      boldStrings: [StringsApp.privacyPolicy, StringsApp.termsAndConditions],
      textAlign: TextAlign.left,
      normalTextStyle: TextStylesApp.regular(
          color: ColorsApp.coalDark, fontSize: FontSizeApp.s14),
      boldTextStyle: TextStylesApp.medium(
          color: ColorsApp.primaryBase, fontSize: FontSizeApp.s14),
      boldStringsCallback: [_onPressPrivacy, _onPressTerm],
    );
  }

  void _onPressPrivacy() {
    //TODO navigate to privacy screen
  }

  void _onPressTerm() {
    //TODO navigate to term screen
  }

  Widget _renderPhoneInput() {
    return BlocBuilder<LogInScreenBloc, LogInScreenState>(
      buildWhen: (previous, current) {
        return previous.inputError != current.inputError;
      },
      builder: (context, state) {
        return PhoneInput(
          isShowLabel: true,
          onChangedInput: (value) {
            context.read<LogInScreenBloc>().setPhoneNumber(value);
          },
          onSubmit: (value) {
            FocusScope.of(context).unfocus();
          },
          onPressCountryFlag: _onPressCountryFlag,
          errorText: state.inputError,
        );
      },
    );
  }

  void _onPressCountryFlag() {
    //TODO open flag picker
  }

  Widget _renderContinueButton() {
    return BlocBuilder<LogInScreenBloc, LogInScreenState>(
      buildWhen: (previous, current) {
        return previous.isEnable != current.isEnable ||
            previous.screenState != current.screenState;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: MarginApp.m16),
          child: SizedBox(
              width: double.infinity,
              child: FilledButtonApp(
                  isEnable: state.isEnable,
                  label: StringsApp.continue_,
                  isLoading: state.screenState == BaseScreenState.loading,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<LogInScreenBloc>().continueWithPhoneNumber();
                  })),
        );
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
              ImagesApp.icClose,
              width: SizeApp.s16,
              height: SizeApp.s16,
            ),
          ),
        ),
      ),
    );
  }
}
