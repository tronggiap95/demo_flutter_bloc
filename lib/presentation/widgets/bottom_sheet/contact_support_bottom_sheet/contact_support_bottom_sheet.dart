import 'package:flutter/material.dart';
import 'package:octo360/application/constants/contact_support_constant.dart';
import 'package:octo360/application/utils/url/url_utils.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/presentation/widgets/separator/dash_separator/dash_separator.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class ContactSupportBottomSheet extends StatelessWidget {
  const ContactSupportBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _renderHeader(),
              _renderDepartment(),
              _renderPhoneNumber(),
              _renderEmail(),
              _renderButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PaddingApp.p14),
      child: Text(
        StringsApp.contactInformation,
        style: TextStylesApp.bold(
          color: ColorsApp.coalDarkest,
          fontSize: FontSizeApp.s16,
        ),
      ),
    );
  }

  Widget _renderDepartment() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PaddingApp.p12),
      child: Text(
        StringsApp.customerSupport,
        style: TextStylesApp.medium(
          color: ColorsApp.coalDarkest,
          fontSize: FontSizeApp.s16,
        ),
      ),
    );
  }

  Widget _renderPhoneNumber() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(PaddingApp.p12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringsApp.phoneNumber,
                style: TextStylesApp.regular(
                  color: ColorsApp.coalDarkest,
                  fontSize: FontSizeApp.s16,
                ),
              ),
              const SizedBox(width: SizeApp.s12),
              Expanded(
                child: GestureDetector(
                  onTap: () => UrlUtils.launchUrl(
                      "tel:${ContactSupportConstant.phoneNumber}"),
                  child: Text(
                    ContactSupportConstant.phoneNumber,
                    style: TextStylesApp.medium(
                      color: ColorsApp.primaryBase,
                      fontSize: FontSizeApp.s16,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ),
        DashSeparator(color: ColorsApp.coalLighter),
      ],
    );
  }

  Widget _renderEmail() {
    return Padding(
      padding: const EdgeInsets.all(PaddingApp.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringsApp.email,
            style: TextStylesApp.regular(
              color: ColorsApp.coalDarkest,
              fontSize: FontSizeApp.s16,
            ),
          ),
          const SizedBox(width: SizeApp.s12),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  UrlUtils.launchUrl("mailto:${ContactSupportConstant.email}"),
              child: Text(
                ContactSupportConstant.email,
                style: TextStylesApp.medium(
                  color: ColorsApp.primaryBase,
                  fontSize: FontSizeApp.s16,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: PaddingApp.p16),
      child: FilledButtonApp(
        label: StringsApp.done,
        onPressed: () => NavigationApp.pop(context),
      ),
    );
  }
}
