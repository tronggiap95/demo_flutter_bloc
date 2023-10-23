import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/application/utils/string/string_utils.dart';
import 'package:octo360/presentation/widgets/card/select_card/select_card.dart';
import 'package:octo360/presentation/widgets/shadowBox/container_with_shadow/container_with_shadow.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class SelectCardItem {
  String? iconPath;
  String? label;
  bool isEnable;

  SelectCardItem(this.iconPath, this.label, {this.isEnable = true});
}

class MultipleSelectCard extends StatelessWidget {
  final List<SelectCardItem> data;
  final Function(int index) onTap;
  const MultipleSelectCard({
    required this.data,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContainerWithShadow(
      child: Card(
        color: ColorsApp.white,
        elevation: ElevationApp.ev0,
        margin: const EdgeInsets.all(MarginApp.m0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderRadiusApp.r8),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) => _renderItem(
              data[index].label,
              data[index].iconPath,
              () => onTap(index),
              data[index].isEnable,
              index),
          itemCount: data.length,
          separatorBuilder: (context, index) {
            return const SizedBox.shrink();
          },
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }

  Widget _renderItem(String? label, String? iconPath, VoidCallback onTap,
      bool isEnable, int index) {
    return AnimatedOpacity(
      key: ValueKey('$index'),
      opacity: isEnable ? 1 : 0.3,
      duration: DurationsApp.openSizeAnimateDuration,
      child: SelectCard(
        borderRadius: BorderRadiusApp.r0,
        textColor: ColorsApp.coalDarker,
        iconColor: ColorsApp.coalDarker,
        hasShadow: false,
        title: label ?? '',
        onTap: onTap,
        hasBorder: false,
        isEnable: isEnable,
        leftIcon: StringUtils.isNullOrEmpty(iconPath)
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: PaddingApp.p12),
                child: SvgPicture.asset(iconPath!),
              ),
      ),
    );
  }
}
