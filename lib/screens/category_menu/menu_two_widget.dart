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

class MenuTwoWidget extends StatefulWidget {
  final MenuPageModel data;
  const MenuTwoWidget({super.key, required this.data});

  @override
  State<MenuTwoWidget> createState() => _MenuTwoWidgetState();
}

class _MenuTwoWidgetState extends State<MenuTwoWidget> {
  @override
  Widget build(BuildContext context) {
    logger.i(widget.data.data);
    return CustomScrollView(
      // slivers:

      // data.data.keys.skip(1).map((key) {
      //   if (data.data[key]['image'] != '' &&
      //       data.data[key]['link'] != '' &&
      //       data.data[key]['id'] != '') {
      //     return SliverToBoxAdapter(
      //       child: GestureDetector(
      //         onTap: () {
      //           FluxNavigate.pushNamed(
      //             RouteList.backdrop,
      //             arguments: BackDropArguments(
      //               config: {
      //                 "name": "",
      //                 "title": "",
      //                 "category": data.data['el57xm1']['id'],
      //                 "keepDefaultTitle": true,
      //                 "image": "https://i.imgur.com/BpJQMg6.png",
      //                 "colors": ["#bb8737", "#F57F17"],
      //                 "originalColor": true,
      //                 "showText": true
      //               },
      //               data: [],
      //             ),
      //           );
      //         },
      //         child: CachedNetworkImage(
      //           imageUrl: data.data[key]['image'],
      //           fit: BoxFit.cover,
      //         ),
      //       ),
      //     );
      //   }
      //   if (data.data[key]['editor'] != '' && data.data[key]['id'] == '') {
      //     return SliverToBoxAdapter(
      //       child: Padding(
      //         padding:
      //             const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      //         child: core.HtmlWidget(
      //           data.data[key]['editor'].toString(),
      //           textStyle: Theme.of(context)
      //               .textTheme
      //               .labelMedium!
      //               .copyWith(height: 1.6, fontSize: 16),
      //         ),
      //       ),
      //     );
      //   }
      //   // if(){
      //   //  return  SliverToBoxAdapter(
      //   //     child: Padding(
      //   //       padding:
      //   //           const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      //   //       child: GestureDetector(
      //   //         onTap: () => _onTapProduct(
      //   //             context: context, id: data.data['11kwaxf']['id']),
      //   //         child: CachedNetworkImage(
      //   //           imageUrl: data.data['11kwaxf']['image'],
      //   //           fit: BoxFit.cover,
      //   //         ),
      //   //       ),
      //   //     ),
      //   //   );
      //   // }
      //   return SliverToBoxAdapter(child: Container());
      // }).toList(),
      slivers: [
        if (widget.data.data['3n5kx6o'] != null)
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(RouteList.homeSearch);
                // FluxNavigate.pushNamed(
                //   RouteList.backdrop,
                //   arguments: BackDropArguments(
                //     config: {
                //       "name": "Αποτελέσματα αναζήτησης",
                //       "title": "Αποτελέσματα αναζήτησης",
                //       "category": widget.data.data['3n5kx6o']
                //           ['searchiqit?s=229'],
                //       "keepDefaultTitle": true,
                //       "image": "https://i.imgur.com/BpJQMg6.png",
                //       "colors": ["#bb8737", "#F57F17"],
                //       "originalColor": true,
                //       "showText": true
                //     },
                //     data: [],
                //   ),
                // );
              },
              child: CachedNetworkImage(
                imageUrl: widget.data.data['3n5kx6o']['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (widget.data.data['hj1czg6'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data['hj1czg6']['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        SliverToBoxAdapter(
            child:
                Image.asset('assets/images/SunsetRomance_Title_Landing.png')),
        if (widget.data.data['vsq7w74'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data['vsq7w74']['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (widget.data.data['5s2hqco'] != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 20),
                      child: GestureDetector(
                        onTap: () {
                          FluxNavigate.pushNamed(
                            RouteList.backdrop,
                            arguments: BackDropArguments(
                              config: {
                                "name": "Αποτελέσματα αναζήτησης",
                                "title": "Αποτελέσματα αναζήτησης",
                                "category": 172,
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
                          imageUrl: widget.data.data['5s2hqco']['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 10,
                ),
                if (widget.data.data['etgz4uz'] != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 20),
                      child: GestureDetector(
                        onTap: () {
                          FluxNavigate.pushNamed(
                            RouteList.backdrop,
                            arguments: BackDropArguments(
                              config: {
                                "name": "Αποτελέσματα αναζήτησης",
                                "title": "Αποτελέσματα αναζήτησης",
                                "category": 172,
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
                          imageUrl: widget.data.data['etgz4uz']['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.data.data['x2neazx'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data['x2neazx']['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xffec9caf)),
              ),
            ),
          ),
        if (widget.data.data['xegffzi'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data['xegffzi']['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        if (widget.data.data['urundya'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () {
                  FluxNavigate.pushNamed(
                    RouteList.backdrop,
                    arguments: BackDropArguments(
                      config: {
                        "name": "Αποτελέσματα αναζήτησης",
                        "title": "Αποτελέσματα αναζήτησης",
                        "category": 172,
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
                  imageUrl: widget.data.data['urundya']['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data['tsznbcg'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                  onPressed: () {
                    FluxNavigate.pushNamed(
                      RouteList.backdrop,
                      arguments: BackDropArguments(
                        config: {
                          "name": "",
                          "title": "",
                          "category": widget.data.data['tsznbcg']['id'],
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
                  child: Text(widget.data.data['tsznbcg']['text'])),
            ),
          ),
        if (widget.data.data['iqzewnm'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data['iqzewnm']['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xffffa096)),
              ),
            ),
          ),
        if (widget.data.data['thfdcpe'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data['thfdcpe']['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        if (widget.data.data['gbna6db'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data['gbna6db']['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data['gbna6db']['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data['sup2koi'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data['sup2koi']['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xfff7df57)),
              ),
            ),
          ),
        if (widget.data.data['a72eocb'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data['a72eocb']['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),
        if (widget.data.data['v4wlubw'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data['v4wlubw']['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data['v4wlubw']['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data['vr3cp2n'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data['vr3cp2n']['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xfff7df57)),
              ),
            ),
          ),
        if (widget.data.data['k5doifi'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data['k5doifi']['editor'].toString(),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(height: 1.6, fontSize: 16),
              ),
            ),
          ),

        ///
        if (widget.data.data['kbqqp1o'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: widget.data.data['kbqqp1o']['id']),
                child: CachedNetworkImage(
                  imageUrl: widget.data.data['kbqqp1o']['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (widget.data.data['qanvrbe'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                widget.data.data['qanvrbe']['title'].toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 22, color: const Color(0xff36b4cd)),
              ),
            ),
          ),
        if (widget.data.data['k3vo6c9'] != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: core.HtmlWidget(
                widget.data.data['k3vo6c9']['editor'].toString(),
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
