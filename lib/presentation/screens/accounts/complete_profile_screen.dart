import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/application/enum/screen/base_screen_state_enum.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/domain/bloc/account/complete_profile_screen_bloc.dart';
import 'package:octo360/domain/model/account/complete_profile_screen_state.dart';
import 'package:octo360/presentation/navigation/app_state/app_state_helper.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/widgets/app_bar/custom_app_bar/custom_app_bar.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/presentation/widgets/input/input_text_field/input_text_field.dart';
import 'package:octo360/presentation/widgets/snack_bar/custom_snackar/custom_snackbar.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        height: SizeApp.s0,
      ),
      body: BlocListener<CompleteProfileScreenBloc, CompleteProfileScreenState>(
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: MarginApp.m16),
                    _renderCloseButton(),
                    _renderTitle(),
                    _renderInput(),
                    _renderFinishButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderInput() {
    return Column(
      children: [
        const SizedBox(height: MarginApp.m20),
        _renderLastName(),
        const SizedBox(height: MarginApp.m24),
        _renderFirstName(),
        const SizedBox(height: MarginApp.m24),
      ],
    );
  }

  Widget _renderLastName() {
    return BlocBuilder<CompleteProfileScreenBloc, CompleteProfileScreenState>(
        buildWhen: (previous, current) =>
            previous.lastNameError != current.lastNameError,
        builder: (context, state) {
          return InputTextFieldApp(
            shouldCapEachWord: true,
            errorText: state.lastNameError,
            label: StringsApp.lastNameExample,
            hint: StringsApp.fillYourLastName,
            onChanged: (value) {
              context
                  .read<CompleteProfileScreenBloc>()
                  .setLastName(value?.trim() ?? '');
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus();
            },
          );
        });
  }

  Widget _renderFirstName() {
    return BlocBuilder<CompleteProfileScreenBloc, CompleteProfileScreenState>(
        builder: (context, state) {
      return InputTextFieldApp(
        shouldCapEachWord: true,
        errorText: state.firstNameError,
        label: StringsApp.middleAndFirstNameExample,
        hint: StringsApp.fillYourMiddleAndFirstName,
        onChanged: (value) {
          context
              .read<CompleteProfileScreenBloc>()
              .setFirstName(value?.trim() ?? '');
        },
        onSubmit: (_) {
          FocusScope.of(context).requestFocus();
        },
      );
    });
  }

  void _handleListenState(CompleteProfileScreenState state) {
    switch (state.screenState) {
      case BaseScreenState.noInternet:
        CustomSnackBar.displaySnackBar(
          context: context,
          message: state.screenError,
          imagePath: ImagesApp.icError,
          marginBottom: SizeApp.s24,
        );
        context.read<CompleteProfileScreenBloc>().resetScreenError();
        break;
      case BaseScreenState.failed:
        CustomSnackBar.displaySnackBar(
          context: context,
          message: state.screenError,
          imagePath: ImagesApp.icError,
          marginBottom: SizeApp.s24,
        );
        context.read<CompleteProfileScreenBloc>().resetScreenError();
        break;
      case BaseScreenState.success:
        AppStateHelper.handleState(AppState.completedProfile);
        break;
      default:
        break;
    }
  }

  Widget _renderTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MarginApp.m24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringsApp.welcome1,
            style: TextStylesApp.bold(
                color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s30),
          ),
          const SizedBox(height: MarginApp.m16),
          Text(
            StringsApp.pleaseFillInYourFullName,
            style: TextStylesApp.regular(
                color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s16),
          ),
        ],
      ),
    );
  }

  Widget _renderFinishButton() {
    return BlocSelector<CompleteProfileScreenBloc, CompleteProfileScreenState,
        CompleteProfileScreenState>(
      selector: (state) => state,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: MarginApp.m16),
          child: SizedBox(
              width: double.infinity,
              child: FilledButtonApp(
                  isEnable: state.isEnable ?? false,
                  label: StringsApp.complete,
                  isLoading: state.isLoading ?? false,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<CompleteProfileScreenBloc>().finish();
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
            FactoryManager.provideGlobalRepo().handleSignOut(context);
            NavigationApp.replaceWith(context, Routes.welcomeScreenRoute);
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
