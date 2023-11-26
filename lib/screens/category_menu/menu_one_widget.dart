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

class MenuOneWidget extends StatefulWidget {
  final MenuPageModel data;
  const MenuOneWidget({super.key, required this.data});

  @override
  State<MenuOneWidget> createState() => _MenuOneWidgetState();
}

class _MenuOneWidgetState extends State<MenuOneWidget> {
  @override
  Widget build(BuildContext context) {
    final isEng = Localizations.localeOf(context).languageCode == 'en';
    final bannerId = isEng ? 'yh2vldf' : 'el57xm1';
    final editorOne = isEng ? 'vykw30t' : 'mfz7lpu';
    final third = isEng ? 'a9rrt9e' : '11kwaxf';
    final forth = isEng ? 'wyy9c53' : 'x2neazx';
    final five = isEng ? 'yhaioaa' : 'xegffzi';
    final six = isEng ? 'phdq8nr' : 'yrryjcl';
    final saven = isEng ? 'yhcshyg' : 'iqzewnm';
    final eight = isEng ? 'ajydgc6' : 'thfdcpe';
    final nine = isEng ? 'vy445t7' : 'gbna6db';
    final ten = isEng ? 'fp828mw' : 'sup2koi';
    final eleven = isEng ? 'xf4c13u' : 'a72eocb';
    final twelve = isEng ? 'itxp8s3' : 'v4wlubw';
    final thirteen = isEng ? '5htrygu' : 'vr3cp2n';
    final fourteen = isEng ? '9g2vmn1' : 'k5doifi';
    final fivteen = isEng ? '21p0so0' : 'kbqqp1o';
    final sixteen = isEng ? '14zwnf1' : 'qanvrbe';
    final saventeen = isEng ? '1uz5kj3' : 'k3vo6c9';

    return CustomScrollView(
      slivers: [
        if (widget.data.data[bannerId] != null)
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                FluxNavigate.pushNamed(
                  RouteList.backdrop,
                  arguments: BackDropArguments(
                    config: {
                      "name": "Ημιμόνιμα βερνίκια 15ml",
                      "title": "Ημιμόνιμα βερνίκια 15ml",
                      "category": widget.data.data[bannerId]['id'],
                      "keepDefaultTitle": true,
                      "image": "https://i.imgur.com/BpJQMg6.png",
                      "colors": ["#bb8737", "#F57F17"],
                      "originalColor": true,
                      "showText": true
                    },
                    data: [],
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: widget.data.data[bannerId]['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (widget.data.data[editorOne] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: core.HtmlWidget(
                widget.data.data[editorOne]['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        if (widget.data.data[third] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data[third]['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data[third]['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data[forth] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data[forth]['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xffec9caf)),
              ),
            ),
          ),
        if (widget.data.data[five] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data[five]['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        if (widget.data.data[six] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data[six]['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data[six]['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data[saven] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data[saven]['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xffffa096)),
              ),
            ),
          ),
        if (widget.data.data[eight] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data[eight]['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        if (widget.data.data[nine] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data[nine]['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data[nine]['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data[ten] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data[ten]['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xfff7df57)),
              ),
            ),
          ),
        if (widget.data.data[eleven] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data[eleven]['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        if (widget.data.data[twelve] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data[twelve]['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data[twelve]['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data[thirteen] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data[thirteen]['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xfff7df57)),
              ),
            ),
          ),
        if (widget.data.data[fourteen] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data[fourteen]['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),

        ///
        if (widget.data.data[fivteen] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data[fivteen]['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data[fivteen]['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data[sixteen] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data[sixteen]['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xff36b4cd)),
              ),
            ),
          ),
        if (widget.data.data[saventeen] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data[saventeen]['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
      ],
    );
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
