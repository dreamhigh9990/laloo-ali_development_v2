// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fstore/widgets/common/index.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/utils.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

import '../../screens/index.dart';
import '../../services/index.dart';

class ChartScreen extends StatefulWidget {
  final String link, title;
  final String locale;
  const ChartScreen(
      {Key? key, required this.link, required this.title, required this.locale})
      : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List? listCharts;

  List<List<ColorChatDataModel>>? charts;

  List<List<ColorChatDataModel>> chartsDisplay = [];

  bool loading = false;
  bool loadinMore = false;

  @override
  void initState() {
    super.initState();
    getChartData();
    // getColorCharts();
  }

  loadMore() async {
    try {
      logger.d('loading more called');
      loadinMore = true;
      setState(() {});
      await Future.delayed(const Duration(seconds: 3));
      if (chartsDisplay.length != charts?.length) {
        final list = charts!.skip(chartsDisplay.length).take(5).toList();
        chartsDisplay.addAll(list);
        loadinMore = false;
        setState(() {});
      }
    } catch (e) {
      ///
    }
  }

  void getColorCharts() async {
    try {
      var res = await http.get(Uri.parse(widget.link));
      if (res.statusCode == 200) {
        var decode = jsonDecode(res.body);
        listCharts = decode;
        setState(() {});
      } else {
        listCharts = [];
      }
    } catch (e) {
      listCharts = [];
    }
  }

  getChartData() async {
    try {
      List<ColorChatDataModel> charts0 = [];
      final links = await getChartsLinks();
      for (var link in links) {
        if (link.id == '2' && widget.locale == 'en') {
          Map<String, dynamic> map = jsonDecode(link.value);
          map.forEach((key, value) {
            charts0.add(ColorChatDataModel(
                id: value['id'],
                key: key,
                image: value['image'],
                type: value['image'].toString().contains('Home_Page_Banner')
                    ? 'banner'
                    : 'chart_$key'));
          });
        } else if (link.id == '1' && widget.locale == 'el') {
          Map<String, dynamic> map = jsonDecode(link.value);
          map.forEach((key, value) {
            charts0.add(ColorChatDataModel(
                id: value['id'],
                key: key,
                image: value['image'],
                type: value['image'].toString().contains('Home_Page_Banner')
                    ? 'banner'
                    : 'chart_$key'));
          });
        }
        if (mounted) {
          setState(() {
            charts = create2DList(charts0, 2);
          });
          if (charts!.length > 10) {
            chartsDisplay.addAll(charts!.take(10).toList());
          }
        }
      }
    } catch (e) {
      charts = [];
      if (mounted) {
        setState(() {});
      }
    }
  }

  List<List<ColorChatDataModel>> create2DList<T>(
      List<ColorChatDataModel> list, int cols) {
    List<List<ColorChatDataModel>> result = [];
    for (int i = 0; i < list.length; i += cols) {
      if (list[i].type == 'banner') {
        result.add([list[i]]);
      } else {
        result.add(
            list.sublist(i, i + cols > list.length ? list.length : i + cols));
      }
    }
    return result;
  }

  Future<List<ColorChatModel>> getChartsLinks() async {
    try {
      final response = await http.get(Uri.parse(
          'https://X2SHFNYYQKHYMZ46Q8KF3J4K3W5449WT@laloo.gr/api/cms/38'));
      logger.d(response.body);
      final document = XmlDocument.parse(response.body);
      document.toXmlString();
      final myTransformer = Xml2Json();
      myTransformer.parse(document.toXmlString());
      var json = myTransformer.toParkerWithAttrs();
      Map<String, dynamic> data = jsonDecode(json);
      final list =
          (data['prestashop']['cms']['content']['language'] as List<dynamic>)
              .map((e) => ColorChatModel.fromJson(e))
              .toList();
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// Show teacher photo in full screen
  Future<void> _fullScreenPhoto({BuildContext? contextt, String? image}) async {
    await showDialog<void>(
      context: contextt!,
      builder: (contextt) => Dialog(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => Navigator.pop(contextt),
                  )),
              SizedBox(
                // width: 200,
                // height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: CachedNetworkImage(
                    imageUrl: image!,
                    fit: BoxFit.contain,
                    memCacheWidth: 45,
                    memCacheHeight: 60,
                    maxHeightDiskCache: 60,
                    maxWidthDiskCache: 45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white),
          ),
        ),
        body: charts == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : charts!.isEmpty
                ? Container()
                :
                // ListView.builder(
                //     itemCount: 10,
                //     itemBuilder: (context, index) {
                //       logger.d(index);
                //       final ColorChatDataModel e = charts![index];
                //       return Padding(
                //         padding: EdgeInsets.symmetric(
                //             horizontal: e.type == 'banner' ? 0 : 10,
                //             vertical: e.type == 'banner' ? 20 : 0),
                //         child: InkWell(
                //           onTap: e.type == 'banner'
                //               ? null
                //               : e.id.isEmpty
                //                   ? null
                //                   : () async {
                //                       showGeneralDialog(
                //                         context: context,
                //                         pageBuilder: (context, animation,
                //                                 secondaryAnimation) =>
                //                             const LoadingWidget(),
                //                       );
                //                       final p =
                //                           await Services().api.getProduct(e.id);
                //                       Navigator.pop(context);

                //                       if (p != null) {
                //                         showGeneralDialog(
                //                           context: context,
                //                           pageBuilder: (context, animation,
                //                                   secondaryAnimation) =>
                //                               ProductDetailScreen(product: p),
                //                         );
                //                       }
                //                     },
                //           child: CachedNetworkImage(
                //             imageUrl: e.image,
                //             fit: BoxFit.fitWidth,
                //           ),
                //         ),
                //       );
                //     },
                //   )
                NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!loadinMore &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        loadMore();
                      }
                      return true;
                    },
                    child: CustomScrollView(
                        slivers: List.generate(chartsDisplay.length, (index) {
                      final List<ColorChatDataModel> charts1 =
                          chartsDisplay[index];
                      return SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Row(
                              children: charts1
                                  .map((e) => Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  e.type == 'banner' ? 0 : 10,
                                              vertical:
                                                  e.type == 'banner' ? 20 : 0),
                                          child: InkWell(
                                            onTap: e.type == 'banner'
                                                ? null
                                                : e.id.isEmpty
                                                    ? null
                                                    : () async {
                                                        showGeneralDialog(
                                                          context: context,
                                                          pageBuilder: (context,
                                                                  animation,
                                                                  secondaryAnimation) =>
                                                              const LoadingWidget(),
                                                        );
                                                        final p =
                                                            await Services()
                                                                .api
                                                                .getProduct(
                                                                    e.id);
                                                        Navigator.pop(context);

                                                        if (p != null) {
                                                          showGeneralDialog(
                                                            context: context,
                                                            pageBuilder: (context,
                                                                    animation,
                                                                    secondaryAnimation) =>
                                                                ProductDetailScreen(
                                                                    product: p),
                                                          );
                                                        }
                                                      },
                                            child: CachedNetworkImage(
                                              imageUrl: e.image,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            if (chartsDisplay.length - 1 == index)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 40),
                                child: LoadingWidget(),
                              )
                          ],
                        ),
                      );
                    })),
                  )
        // : GridView.count(
        //     crossAxisCount: 2,
        //     children: charts!
        //         .map((data) => Padding(
        //               padding: const EdgeInsets.all(3.0),
        //               child: InkWell(
        //                 onTap: () {
        //                   _fullScreenPhoto(
        //                       image: data.image, contextt: context);
        //                 },
        //                 child: CachedNetworkImage(
        //                   imageUrl: data.image,
        //                   fit: BoxFit.cover,
        //                 ),
        //               ),
        //             ))
        //         .toList()),
        );
  }
}

class ColorChatModel {
  final String id;
  final String value;

  ColorChatModel({required this.id, required this.value});

  factory ColorChatModel.fromJson(json) {
    return ColorChatModel(id: json['_id'], value: json['value']);
  }
}

class ColorChatDataModel {
  final String image;
  final String key;
  final String? type;
  final String id;
  ColorChatDataModel(
      {required this.image,
      required this.key,
      required this.type,
      required this.id});
}
