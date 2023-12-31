import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config/category_config.dart';
import '../config/category_item_config.dart';
import '../helper/helper.dart';
import 'category_icon_item.dart';

const _defaultSeparateWidth = 24.0;

const _paddingList = 24.0;

class CategoryIcons extends StatelessWidget {
  final CategoryConfig config;
  final int crossAxisCount;
  final Function onShowProductList;
  final Map<String?, String?> listCategoryName;

  const CategoryIcons({
    required this.onShowProductList,
    required this.listCategoryName,
    required this.config,
    this.crossAxisCount = 5,
    Key? key,
  }) : super(key: key);

  String? _getCategoryName({required CategoryItemConfig item}) {
    if (config.commonItemConfig.hideTitle) {
      return '';
    }

    if (item.keepDefaultTitle) {
      return item.title ?? '';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final listItemData = config.items;
    var numberItemOnScreen = config.columns ?? crossAxisCount;

    numberItemOnScreen = getValueForScreenType(
      context: context,
      mobile: numberItemOnScreen,
      tablet: numberItemOnScreen + 3,
      desktop: numberItemOnScreen + 8,
    );

    var row = (listItemData.length.toDouble() / numberItemOnScreen).ceil();
    final size = config.commonItemConfig.size ?? 1.0;
    final widthItem = (MediaQuery.of(context).size.width -
            _paddingList -
            (_defaultSeparateWidth * (numberItemOnScreen))) /
        numberItemOnScreen *
        size;
    var items = <Widget>[];

    for (var i = 0; i < config.items.length; i++) {
      var name = _getCategoryName(item: config.items[i]);

      items.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CategoryIconItem(
              onTap: () => onShowProductList(config.items[i]),
              iconSize: widthItem,
              name: name,
              itemConfig: config.items[i],
              commonConfig: config.commonItemConfig,
            ),
            if (i < (config.items.length - 1))
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: 1.5,
                height: 40,
                color: config.items[i].colors![1],
              ),
          ],
        ),
      );
    }

    if (config.wrap == false && items.isNotEmpty) {
      return SizedBox(
        height: 110,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: config.marginLeft,
            right: config.marginRight,
            top: config.marginTop,
            bottom: config.marginBottom,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // children: items.expand((element) {
            //   return [
            //     element,
            //     ScreenTypeLayout(
            //       mobile: const SizedBox(width: _defaultSeparateWidth),
            //       tablet: const SizedBox(width: _defaultSeparateWidth + 12),
            //       desktop: const SizedBox(width: _defaultSeparateWidth + 24),
            //     ),
            //   ];
            // }).toList()
            //   ..removeLast(),
            children: items,
          ),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Container(
        margin: EdgeInsets.only(
          left: config.marginLeft,
          right: config.marginRight,
          top: config.marginTop,
          bottom: config.marginBottom,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            if (config.shadow != null)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: Helper.formatDouble(config.shadow ?? 15.0)!,
                offset: Offset(0, Helper.formatDouble(config.shadow ?? 10.0)!),
              )
          ],
        ),
        child: Column(
          children: List.generate(row, (indexCol) {
            return Row(
              children: List.generate(numberItemOnScreen, (indexRow) {
                return Expanded(
                  child:
                      numberItemOnScreen * indexCol + indexRow >= items.length
                          ? const SizedBox()
                          : items[numberItemOnScreen * indexCol + indexRow],
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
