import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:octo360/presentation/widgets/separator/solid_separator/solid_separator.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final bool hideAppBar;
  final Widget? leadingWidget;
  final bool isTextBtnLeadingWidget;
  final Widget? titleWidget;
  final bool centerTitle;
  final Color statusBarColor;
  final Color backgroundColor;
  final SystemUiOverlayStyle? statusBarStyle;
  final double marginLeftIcon;
  final double marginRightIcon;
  final double leftIconsSpacing;
  final double elevation;
  final List<Widget>? actionButtons;
  final VoidCallback? onPressLeftIcon;
  final BoxConstraints? leftIconButtonConstraints;
  final bool displayBottomSeparator;
  final Color? bottomSeparatorColor;
  final bool hasBottomText;
  final Color? shadowColor;

  const CustomAppBar({
    Key? key,
    this.height = kToolbarHeight,
    this.hideAppBar = false,
    this.leadingWidget,
    this.isTextBtnLeadingWidget = false,
    this.titleWidget,
    this.centerTitle = true,
    this.statusBarColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.statusBarStyle,
    this.marginLeftIcon = 0,
    this.marginRightIcon = 0,
    this.leftIconsSpacing = 0,
    this.elevation = ElevationApp.ev0,
    this.actionButtons,
    this.onPressLeftIcon,
    this.leftIconButtonConstraints,
    this.displayBottomSeparator = false,
    this.bottomSeparatorColor,
    this.hasBottomText = false,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        bottom: kIsWeb
            ? null
            : Platform.isIOS && hasBottomText
                ? PreferredSize(
                    preferredSize: preferredSize,
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: MarginApp.m16),
                        alignment: Alignment.centerLeft,
                        child: titleWidget))
                : null,
        toolbarHeight: hideAppBar ? 0 : height,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shadowColor: shadowColor,
        titleSpacing: 0,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        title: centerTitle
            ? _renderAppBarWithCenterTitle()
            : _renderAppBarWithLeftTitle(),
        centerTitle: true,
        systemOverlayStyle: statusBarStyle ?? _renderDefaultStatusBar());
  }

  SystemUiOverlayStyle _renderDefaultStatusBar() {
    return kIsWeb
        ? SystemUiOverlayStyle(
            statusBarColor: statusBarColor,
            statusBarIconBrightness: Brightness.dark,
          )
        : Platform.isIOS
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle(
                statusBarColor: statusBarColor,
                statusBarIconBrightness: Brightness.dark,
              );
  }

  Column _renderAppBarWithCenterTitle() {
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          child: Stack(
            children: [
              leadingWidget != null
                  ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: marginLeftIcon),
                      height: height,
                      child: isTextBtnLeadingWidget
                          ? TextButton(
                              onPressed: onPressLeftIcon, child: leadingWidget!)
                          : IconButton(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(0),
                              onPressed: onPressLeftIcon,
                              icon: leadingWidget!,
                            ),
                    )
                  : SizedBox(
                      width: marginLeftIcon,
                    ),
              !hasBottomText
                  ? Container(
                      alignment: Alignment.center,
                      height: height,
                      child: titleWidget,
                    )
                  : Container(),
              Container(
                margin: EdgeInsets.only(right: marginRightIcon),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actionButtons ?? [],
                ),
              ),
            ],
          ),
        ),
        displayBottomSeparator
            ? SolidSeparator(
                color: bottomSeparatorColor ?? ColorsApp.primaryLightest,
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Column _renderAppBarWithLeftTitle() {
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  leadingWidget != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            left: marginLeftIcon,
                            right: leftIconsSpacing,
                          ),
                          height: height,
                          child: IconButton(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(0),
                            onPressed: onPressLeftIcon,
                            icon: leadingWidget!,
                            constraints: leftIconButtonConstraints,
                          ),
                        )
                      : SizedBox(
                          width: marginLeftIcon,
                        ),
                  !hasBottomText
                      ? Container(
                          alignment: Alignment.center,
                          height: height,
                          child: titleWidget,
                        )
                      : Container(),
                ],
              ),
              Container(
                margin: EdgeInsets.only(right: marginRightIcon),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actionButtons ?? [],
                ),
              ),
            ],
          ),
        ),
        displayBottomSeparator
            ? SolidSeparator(
                color: bottomSeparatorColor ?? ColorsApp.primaryLightest,
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        hideAppBar ? 0 : height,
      );
}
