// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fstore/common/constants.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    as core;
import '../../models/index.dart';
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/common/index.dart';
import '../index.dart';
import 'menu_one_widget.dart';
import 'menu_two_widget.dart';

class CategoryMenueScreen extends StatefulWidget {
  final MenuPageModel data;
  const CategoryMenueScreen({super.key, required this.data});

  @override
  State<CategoryMenueScreen> createState() => _CategoryMenueScreenState();
}

class _CategoryMenueScreenState extends State<CategoryMenueScreen> {
  @override
  Widget build(BuildContext context) {
    logger.i(widget.data.data);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.data.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white),
          ),
        ),
        body: widget.data.pageId == '61'
            ? MenuOneWidget(
                data: widget.data,
              )
            : widget.data.pageId == '63'
                ? MenuTwoWidget(
                    data: widget.data,
                  )
                : Container());
  }

  _onTapProduct({required BuildContext context, required String id}) async {
    try {
      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoadingWidget(),
      );
      final p = await Services().api.getProduct(id);
      logger.i(p?.toJson());
      Navigator.pop(context);

      if (p != null) {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) =>
              ProductDetailScreen(product: p),
        );
      }
    } catch (e) {
      logger.e(e);
      Navigator.pop(context);
    }
  }
}
