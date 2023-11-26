import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:inspireui/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

import '../../../common/tools.dart';
import '../../../widgets/common/flux_image.dart';
import '../config/banner_config.dart';
import '../header/header_text.dart';
import '../helper/helper.dart';
import 'banner_items.dart';

/// The Banner Group type to display the image as multi columns
class BannerSlider extends StatefulWidget {
  final BannerConfig config;
  final Function onTap;

  const BannerSlider({required this.config, required this.onTap, Key? key})
      : super(key: key);

  @override
  _StateBannerSlider createState() => _StateBannerSlider();
}

class _StateBannerSlider extends State<BannerSlider> {
  int position = 0;
  PageController? _controller;
  late bool autoPlay;
  Timer? timer;
  late int intervalTime;

  List<BannerDataModel> banners = [];

  @override
  void initState() {
    autoPlay = widget.config.autoPlay;
    _controller = PageController(
      initialPage: 0,
    );
    intervalTime = widget.config.intervalTime ?? 3;

    super.initState();
    if (banners.isEmpty) {
      loadBanners();
    }
  }

  void autoPlayBanner() {
    // List? items = widget.config.items;
    timer = Timer.periodic(const Duration(seconds: 3), (callback) {
      if (widget.config.design != 'default' || !autoPlay) {
        timer!.cancel();
      } else if (widget.config.design == 'default' && autoPlay) {
        position = position + 1;

        logger.d(position, banners.length);
        if (_controller!.hasClients) {
          if (position >= banners.length) {
            position = 0;
            _controller!.jumpToPage(0);
          } else {
            logger.i(position);
            _controller!.animateToPage(position,
                duration: const Duration(seconds: 1), curve: Curves.easeInOut);
          }
        }

        // if (position > banners.length - 1 && _controller!.hasClients) {
        //   _controller!.jumpToPage(0);
        // } else {
        //   if (_controller!.hasClients) {
        //     _controller!.animateToPage(position,
        //         duration: const Duration(seconds: 1), curve: Curves.easeInOut);
        //   }
        // }
      }
    });
  }

  bool? isLoading;
  loadBanners() async {
    try {
      if (isLoading == null) {
        isLoading = true;
        List<BannerDataModel> banners0 = [];
        final links = await bannersLinks();
        for (final link in links) {
          final BannerDataModel? banner = await bannersFromLink(link.id);
          if (banner != null) {
            if (banner.enable == '1') {
              banners0.add(banner);
            }
          }
        }
        setState(() {
          banners = banners0.where((element) => element.enable == '1').toList();
        });
        banners.sort((a, b) => a.position.compareTo(b.position));
        logger.d(banners.length);
      }
    } catch (e) {
      ///
    }
  }

  Future<BannerDataModel?> bannersFromLink(String id) async {
    try {
      final url =
          'https://X2SHFNYYQKHYMZ46Q8KF3J4K3W5449WT@laloo.gr/api/banners/$id';
      final response = await http.get(Uri.parse(url));
      final document = XmlDocument.parse(response.body);
      document.toXmlString();
      final myTransformer = Xml2Json();
      myTransformer.parse(document.toXmlString());
      var json = myTransformer.toParkerWithAttrs();
      Map<String, dynamic> data = jsonDecode(json);
      return BannerDataModel.fromJson(data['prestashop']['banners']);
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<List<BannerModel>> bannersLinks() async {
    try {
      final response = await http.get(Uri.parse(
          'https://X2SHFNYYQKHYMZ46Q8KF3J4K3W5449WT@laloo.gr/api/banners/'));
      final document = XmlDocument.parse(response.body);
      document.toXmlString();
      final myTransformer = Xml2Json();
      myTransformer.parse(document.toXmlString());
      var json = myTransformer.toParkerWithAttrs();
      Map<String, dynamic> data = jsonDecode(json);
      final bannersLinks =
          (data['prestashop']['banners']['banners'] as List<dynamic>)
              .map((e) => BannerModel.fromJson(e))
              .toList();
      return bannersLinks;
    } catch (e) {
      logger.e('loadingBanners', e);
      rethrow;
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    _controller!.dispose();
    super.dispose();
  }

  Widget getBannerPageView(width) {
    List items = widget.config.items;
    var showNumber = widget.config.showNumber;
    var boxFit = widget.config.fit;
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 5),
      child: Stack(
        children: <Widget>[
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                position = index;
              });
            },
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                BannerImageItem(
                  config: items[i],
                  width: width,
                  boxFit: boxFit,
                  padding: widget.config.padding,
                  radius: widget.config.radius,
                  onTap: widget.onTap,
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SmoothPageIndicator(
              controller: _controller!, // PageController
              count: items.length,
              effect: const SlideEffect(
                spacing: 8.0,
                radius: 5.0,
                dotWidth: 24.0,
                dotHeight: 2.0,
                paintStyle: PaintingStyle.fill,
                strokeWidth: 1.5,
                dotColor: Colors.black12,
                activeDotColor: Colors.black87,
              ),
            ),
          ),
          showNumber
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.6)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        child: Text(
                          '${position + 1}/${items.length}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget getBannerPageView0() {
    var showNumber = widget.config.showNumber;
    var boxFit = widget.config.fit;
    if (banners.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 5),
      child: Stack(
        children: <Widget>[
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                position = index;
              });
            },
            children: <Widget>[
              for (int i = 1; i < banners.length; i++)
                // BannerImageItem(
                //   config: items[i],
                //   width: width,
                //   boxFit: boxFit,
                //   padding: widget.config.padding,
                //   radius: widget.config.radius,
                //   onTap: widget.onTap,
                // ),
                // if (banners[i].banner['2']?.isEmpty == true)
                //   Container()
                // else if (banners[i].banner['2']?.isNotEmpty == true)
                ImageTools.image(
                  height: 350,
                  fit: BoxFit.cover,
                  url:
                      'https://laloo.gr/modules/soyresponsiveslider/images/${banners[i].banner['2']}',
                  width: MediaQuery.of(context).size.width,
                )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SmoothPageIndicator(
              controller: _controller!, // PageController
              count: banners.length,
              effect: const SlideEffect(
                spacing: 8.0,
                radius: 5.0,
                dotWidth: 24.0,
                dotHeight: 2.0,
                paintStyle: PaintingStyle.fill,
                strokeWidth: 1.5,
                dotColor: Colors.black12,
                activeDotColor: Colors.black87,
              ),
            ),
          ),
          showNumber
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.6)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        child: Text(
                          '${position + 1}/${banners.length}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget renderBannerItem({required BannerItemConfig config, double? width}) {
    return BannerImageItem(
      config: config,
      width: width,
      boxFit: widget.config.fit,
      radius: widget.config.radius,
      padding: widget.config.padding,
      onTap: widget.onTap,
    );
  }

  Widget renderBanner(width) {
    List? items = widget.config.items;

    switch ('swiper') {
      case 'swiper':
        final Locale locale = Localizations.localeOf(context);
        String lngId = locale.languageCode == 'en' ? '1' : '2';
        if (banners.isEmpty) {
          return Container();
        }
        return Swiper(
          // onIndexChanged: (index) {
          //   setState(() {
          //     position = index;
          //   });
          // },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return ImageTools.image(
              fit: BoxFit.contain,
              url:
                  'https://laloo.gr/modules/soyresponsiveslider/images/${banners[index].banner[lngId]}',
              width: MediaQuery.of(context).size.width,
            );
            // return renderBannerItem(config: items[index], width: width);
          },
          itemCount: banners.length,
          // viewportFraction: 0.85,
          // scale: 0.9,
          duration: intervalTime * 100,
        );
      case 'tinder':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return renderBannerItem(config: items[index], width: width);
          },
          itemCount: items.length,
          itemWidth: width,
          itemHeight: width * 1.2,
          layout: SwiperLayout.TINDER,
          duration: intervalTime * 100,
        );
      case 'stack':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return renderBannerItem(config: items[index], width: width);
          },
          itemCount: items.length,
          itemWidth: width - 40,
          layout: SwiperLayout.STACK,
          duration: intervalTime * 100,
        );
      case 'custom':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return renderBannerItem(config: items[index], width: width);
          },
          itemCount: items.length,
          itemWidth: width - 40,
          itemHeight: width + 100,
          duration: intervalTime * 100,
          layout: SwiperLayout.CUSTOM,
          customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
              .addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate(
            [
              const Offset(-370.0, -40.0),
              const Offset(0.0, 0.0),
              const Offset(370.0, -40.0)
            ],
          ),
        );
      default:
        return getBannerPageView0();
      // return getBannerPageView(width);
    }
  }

  double? bannerPercent(width) {
    final screenSize = MediaQuery.of(context).size;
    return Helper.formatDouble(
        widget.config.height ?? 0.5 / (screenSize.height / width));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var isBlur = widget.config.isBlur;

    List? items = widget.config.items;
    var bannerExtraHeight =
        screenSize.height * (widget.config.title != null ? 0.12 : 0.0);
    var upHeight = Helper.formatDouble(widget.config.upHeight);

    //Set autoplay for default template
    autoPlay = widget.config.autoPlay;
    if (widget.config.design == 'default' && timer != null) {
      if (!autoPlay) {
        if (timer!.isActive) {
          timer!.cancel();
        }
      } else {
        if (!timer!.isActive) {
          Future.delayed(Duration(seconds: intervalTime), () => autoPlayBanner);
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraint) {
        var _bannerPercent = bannerPercent(constraint.maxWidth)!;
        var height =
            screenSize.height * _bannerPercent + bannerExtraHeight + upHeight!;
        if (items.isEmpty) {
          return widget.config.title != null
              ? HeaderText(config: widget.config.title!)
              : Container();
        }
        BannerItemConfig item = items[position];
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: Container(
            margin: EdgeInsets.only(
              left: widget.config.marginLeft,
              right: widget.config.marginRight,
              top: widget.config.marginTop,
              bottom: widget.config.marginBottom,
            ),
            child: Stack(
              children: <Widget>[
                if (widget.config.showBackground)
                  SizedBox(
                    height: height,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.elliptical(100, 6),
                        ),
                        child: isBlur
                            ? ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 5.0,
                                  sigmaY: 5.0,
                                ),
                                child: Transform.scale(
                                  scale: 3,
                                  child: FluxImage(
                                    imageUrl: item.background ?? item.image,
                                    fit: BoxFit.fill,
                                    width: screenSize.width + upHeight,
                                  ),
                                ),
                              )
                            : FluxImage(
                                imageUrl: item.background ?? item.image,
                                fit: BoxFit.fill,
                                width: constraint.maxWidth,
                                height: screenSize.height * _bannerPercent +
                                    bannerExtraHeight +
                                    upHeight,
                              ),
                      ),
                    ),
                  ),
                // FilesViewPage(
                //   banners: banners,
                // ),
                Column(
                  children: [
                    if (widget.config.title != null)
                      HeaderText(config: widget.config.title!),
                    SizedBox(
                      height: 400,
                      child: renderBanner(constraint.maxWidth),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BannerModel {
  final String link;
  final String id;

  BannerModel(this.link, this.id);

  factory BannerModel.fromJson(json) {
    return BannerModel(json['_xlink:href'], json['_id']);
  }
}

class BannerDataModel {
  final String enable;
  final String position;
  final Map<String, String> banner;
  // final Map<String, String> href;
  BannerDataModel({
    required this.enable,
    required this.position,
    required this.banner,
    // required this.href
  });

  factory BannerDataModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> bannerByLangId = {};
    // Map<String, String> hrefByLangId = {};
    final bannerMap = json['image_phone']['language'];
    // final hrefMap = json['url']['language'];
    for (final data in bannerMap) {
      bannerByLangId.addAll({
        data['_id']: data['value'],
      });
    }

    // for (final data in hrefMap) {
    //   hrefByLangId.addAll({
    //     data['_id']: data['value'],
    //   });
    // }

    return BannerDataModel(
      enable: json['enabled'],
      position: json['position'],
      banner: bannerByLangId,
      // href: hrefMap,
    );
  }
}

class FilesViewPage extends StatefulWidget {
  final List<BannerDataModel> banners;
  const FilesViewPage({super.key, required this.banners});

  @override
  State<FilesViewPage> createState() => _FilesViewPageState();
}

class _FilesViewPageState extends State<FilesViewPage> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    String lngId = locale.languageCode == 'en' ? '1' : '2';
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final file = widget.banners[index];
              return ImageTools.image(
                fit: BoxFit.fitWidth,
                url:
                    'https://laloo.gr/modules/soyresponsiveslider/images/${file.banner[lngId]}',
                width: MediaQuery.of(context).size.width,
              );
            },
          ),
        ),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (index) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        )
      ],
    );
  }
}
