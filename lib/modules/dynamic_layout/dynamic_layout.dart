// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// import 'package:google_fonts/google_fonts.dart';
import 'package:intro_slider/intro_slider.dart';
// import 'package:intro_slider/slide_object.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:intro_slider/dot_animation_enum.dart';
import '../../app.dart';
import '../../common/constants.dart';
import '../../common/font_family.dart';
import '../../common/tools.dart';

import '../../models/index.dart';
import '../../routes/flux_navigate.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/index.dart';
import '../../services/index.dart';
import '../../widgets/common/index.dart';
import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider.dart';
import 'blog/blog_grid.dart';
import 'brand/brand_layout.dart';
import 'button/button.dart';
import 'category/category_icon.dart';
import 'category/category_image.dart';
import 'category/category_menu_with_products.dart';
import 'category/category_text.dart';
import 'chart_screen.dart';
import 'config/brand_config.dart';
import 'config/index.dart';
import 'divider/divider.dart';
import 'header/header_search.dart';
import 'header/header_text.dart';
import 'instagram_story/instagram_story.dart';
import 'links_screen.dart';
import 'logo/logo.dart';
import 'product/product_list_simple.dart';
import 'product/product_recent_placeholder.dart';
import 'slider_testimonial/index.dart';
import 'spacer/spacer.dart';
import 'story/index.dart';
import 'testimonial/index.dart';
import 'video/index.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    as core;

import 'package:html/parser.dart';

class DynamicLayout extends StatefulWidget {
  final config;
  final bool cleanCache;
  final Map<String, dynamic> landingDatas;
  late CategoryItemConfig? link;
  DynamicLayout(
      {this.config,
      this.cleanCache = false,
      required this.landingDatas,
      this.link});

  @override
  State<DynamicLayout> createState() => _DynamicLayoutState();
}

class _DynamicLayoutState extends State<DynamicLayout> {
  Map<String, dynamic> landingData = {};

  @override
  initState() {
    super.initState();

    setState(() {
      landingData = widget.landingDatas;
    });
  }

  Future launchWebView(String url, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => WebView(
          url: url,
          title: title,
          isHtmlTrue: false,
          //  url.contains('laloo-academy') ? false : true,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _nameIconColumn(String title, String subTitle, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 14),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            _parseHtmlString(subTitle),
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
  }

  Widget _imageContainer(
      double height, String imgUrl, double pTop, double pBottom) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: pTop, bottom: pBottom),
      width: MediaQuery.of(context).size.width,
      height: height,
      decoration: BoxDecoration(
        image:
            DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.contain),
      ),
    );
  }

  Widget _numbersContainer(
      double height, double pTop, double pBottom, Map<String, dynamic> config) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: pTop, bottom: pBottom),
        width: MediaQuery.of(context).size.width - 20,
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(config['back_image'].toString()),
              fit: BoxFit.fill),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 4, bottom: 5),
            width: MediaQuery.of(context).size.width - 20,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(config['title'],
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 24, color: Colors.black)),
                ...(config['items'] as List)
                    .map((json) => Column(
                          children: [
                            Text(json['title'].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: 24, color: Colors.black)),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(json['subtitle'].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: 10, color: Colors.black)),
                          ],
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _testimonials(Map<String, dynamic> config) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(config['title']?.toString() ?? 'Cutomers Testimonials',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 3,
          width: 40,
          color: Colors.black,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 180,
          alignment: Alignment.topCenter,
          child: IntroSlider(
            listCustomTabs: (config['items'] as List)
                .map((json) => SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(
                                top: 30.0, left: 20, right: 20),
                            child: Text(
                              json['subtitle'].toString(),
                              textAlign: TextAlign.center,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Colors.black,
                                      fontFamily:
                                          FontFamily.pFCenturyMediumItalic),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              json['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      fontSize: 12.0, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            // backgroundColorAllSlides: Colors.white,
            refFuncGoToTab: (refFunc) {
              //this.goToTab = refFunc;
            },

            // Behavior
            scrollPhysics: const BouncingScrollPhysics(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEng = Localizations.localeOf(context).languageCode == 'en';
    Widget _iconsRow() {
      final first = isEng ? 'ay3v8vz' : 'qz2x1nk';
      final second = isEng ? 'nl168d0' : 'qsca9fr';
      final third = isEng ? 'srbyl5z' : 'z4qlsfj';
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _nameIconColumn('${landingData[first]?['title_text'] ?? ''}',
              '${landingData[first]?['description_text'] ?? ''}', Icons.public),
          _nameIconColumn('${landingData[second]?['title_text'] ?? ''}',
              '${landingData[second]?['description_text'] ?? ''}', Icons.cut),
          _nameIconColumn(
              '${landingData[third]?['title_text'] ?? ''}',
              '${landingData[third]?['description_text'] ?? ''}',
              Icons.security)
        ],
      );
    }

    final appModel = Provider.of<AppModel>(context, listen: true);

    switch (widget.config['layout']) {
      case 'logo':
        final themeConfig = appModel.themeConfig;
        return Logo(
          config: LogoConfig.fromJson(widget.config),
          logo: themeConfig.logo,
          totalCart:
              Provider.of<CartModel>(context, listen: true).totalCartQuantity,
          notificationCount:
              Provider.of<NotificationModel>(context).unreadCount,
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
          onSearch: () => Navigator.of(context).pushNamed(RouteList.homeSearch),
          onCheckout: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  body: const CartScreen(isModal: true),
                ),
                fullscreenDialog: true,
              ),
            );
          },
          onTapNotifications: () {
            Navigator.of(context).pushNamed(RouteList.notify);
          },
          onTapDrawerMenu: () => NavigateTools.onTapOpenDrawerMenu(context),
        );

      case 'header_text':
        return HeaderText(
          config: HeaderConfig.fromJson(widget.config),
          onSearch: () => Navigator.of(context).pushNamed(RouteList.homeSearch),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );

      case 'header_search':
        return HeaderSearch(
          config: HeaderConfig.fromJson(widget.config),
          onSearch: () {
            Navigator.of(App.fluxStoreNavigatorKey.currentContext!)
                .pushNamed(RouteList.homeSearch);
          },
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'featuredVendors':
        return Services().widget.renderFeatureVendor(widget.config);
      case 'category':
        if (widget.config['type'] == 'image') {
          return CategoryImages(
            config: CategoryConfig.fromJson(widget.config),
            key: widget.config['key'] != null
                ? Key(widget.config['key'])
                : UniqueKey(),
          );
        }
        return Consumer<CategoryModel>(builder: (context, model, child) {
          var _config = CategoryConfig.fromJson(widget.config);
          var _listCategoryName =
              model.categoryList.map((key, value) => MapEntry(key, value.name));

          void _onShowProductList(CategoryItemConfig item) {
            switch (item.category) {
              case 'links':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LinksScreen(
                            links: item.data ?? [], title: item.title ?? '')));
                break;

              case 'chart_screen':
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChartScreen(
                    link: item.link!,
                    title: item.title!,
                    locale: Localizations.localeOf(context).languageCode,
                  ),
                );
                log(item.link.toString());
                log(item.title.toString());

                break;
              default:
                FluxNavigate.pushNamed(
                  RouteList.backdrop,
                  arguments: BackDropArguments(
                    config: item.jsonData,
                    data: item.data,
                  ),
                );
            }
          }

          if (widget.config['type'] == 'menuWithProducts') {
            return CategoryMenuWithProducts(
              config: _config,
              listCategoryName: _listCategoryName,
              onShowProductList: _onShowProductList,
              key: widget.config['key'] != null
                  ? Key(widget.config['key'])
                  : UniqueKey(),
            );
          }

          if (widget.config['type'] == 'text') {
            return CategoryTexts(
              config: _config,
              listCategoryName: _listCategoryName,
              onShowProductList: _onShowProductList,
              key: widget.config['key'] != null
                  ? Key(widget.config['key'])
                  : UniqueKey(),
            );
          }

          return CategoryIcons(
            config: _config,
            listCategoryName: _listCategoryName,
            onShowProductList: _onShowProductList,
            key: widget.config['key'] != null
                ? Key(widget.config['key'])
                : UniqueKey(),
          );
        });
      case 'bannerAnimated':
        if (kIsWeb) return const SizedBox();
        return BannerAnimated(
          config: BannerConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );

      case 'bannerImage':
        if (widget.config['isSlider'] == true) {
          return BannerSlider(
              config: BannerConfig.fromJson(widget.config),
              onTap: (itemConfig) {
                NavigateTools.onTapNavigateOptions(
                  context: context,
                  config: itemConfig,
                );
              },
              key: widget.config['key'] != null
                  ? Key(widget.config['key'])
                  : UniqueKey());
        }

        return BannerGroupItems(
          config: BannerConfig.fromJson(widget.config),
          onTap: (itemConfig) {
            NavigateTools.onTapNavigateOptions(
              context: context,
              config: itemConfig,
            );
          },
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'shipping_details':
        return SizedBox(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              _iconsRow(),
              const SizedBox(
                height: 20,
              ),
              if (landingData['zrv2qut'] != null)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 2,
                  color: Theme.of(context).primaryColor,
                ),
              if (landingData['zrv2qut'] != null)
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: const EdgeInsets.only(top: 7.0, bottom: 8.0),
                  height: 35,
                  //color: Colors.green,
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Text(
                      landingData['zrv2qut']?['title'].toString().trim() ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 14),
                    ),
                  ),
                ),
              if (landingData['zrv2qut'] != null)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 2,
                  color: Theme.of(context).primaryColor,
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      case 'footer':
        final imagesList = isEng ? 'dc24sqf' : 'ydilbrf';
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //! ********* Color Palette **************
                  if (landingData['r8w5x16'] != null)
                    GestureDetector(
                      onTap: () {
                        // launchUrl(Uri.parse(landingData['r8w5x16']['link']));
                        launchWebView(
                          landingData['r8w5x16']['link'],
                          landingData['r8w5x16']['title'],
                        );
                      },
                      child: CachedNetworkImage(
                          imageUrl: landingData['r8w5x16']['image']),
// =======
//                         // launchWebView(landingData['r8w5x16']['link'],
//                         //     landingData['r8w5x16']['title']);
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (BuildContext context) => ChartScreen(
//                               link: landingData['r8w5x16']['link'],
//                               // 'https://laloo.gr/bridge.php?u=8f99e1315fcc7875325149dda085c504f&action=chart&lang=2x',
//                               title: landingData['r8w5x16']['title'],
//                               locale:
//                                   Localizations.localeOf(context).languageCode,
//                             ),
//                           ),
//                         );
//                       },
//                       child: CachedNetworkImage(
//                         imageUrl: landingData['r8w5x16']['image'],
//                       ),
// >>>>>>> Stashed changes
                    ),
                  if (landingData['r8w5x16'] != null)
                    const SizedBox(
                      height: 12,
                    ),
                  if (landingData['0zgq9bt'] != null)
                    GestureDetector(
                      onTap: () {
                        // launchUrl(Uri.parse(landingData['0zgq9bt']['link']));
                        launchWebView(
                          landingData['0zgq9bt']['link'],
                          landingData['r8w5x16']['title'],
                        );
                      },
                      child: CachedNetworkImage(
                          imageUrl: landingData['0zgq9bt']['image']),
                    ),
                  if (landingData['0zgq9bt'] != null)
                    const SizedBox(
                      height: 20,
                    ),
                ],
              ),
            ),
            //! **************** Stikoudi photo *****************************
            if (landingData['nxz43si'] != null)
              GestureDetector(
                  onTap: () {
// <<<<<<< Updated upstream
//                     launchUrl(Uri.parse(landingData['nxz43si']['link']));
// =======
                    // launchWebView(
                    //     "https://laloo.gr/bridge.php?u=8f99e1315fcc7875325149dda085c504f&action=beginner&lang=2",
                    //     '');
                    launchWebView(landingData['nxz43si']['link'],
                        landingData['nxz43si']['title']);
// >>>>>>> Stashed changes
                  },
                  child: CachedNetworkImage(
                      imageUrl: landingData['nxz43si']['image'])),
            const SizedBox(
              height: 30,
            ),
            if (landingData[imagesList] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: List.generate(
                      landingData[imagesList]['images_list'].length,
                      (index) => Expanded(
                              child: GestureDetector(
                            onTap: () async {
                              FluxNavigate.pushNamed(
                                RouteList.backdrop,
                                arguments: BackDropArguments(
                                  config: {
                                    "name": landingData[imagesList]
                                        ['images_list'][index]['text'],
                                    "title": landingData[imagesList]
                                        ['images_list'][index]['text'],
                                    "category": landingData[imagesList]
                                        ['images_list'][index]['id'],
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
                                imageUrl: 'https://laloo.gr' +
                                    landingData[imagesList]['images_list']
                                        [index]['image']),
                          ))),
                ),
              ),
            if (landingData['vzweq69'] != null)
              Container(
                width: MediaQuery.of(context).size.width,
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
            if (landingData['vzweq69'] != null)
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                margin: const EdgeInsets.only(top: 7.0, bottom: 8.0),
                height: 35,
                //color: Colors.green,
                child: FittedBox(
                  child: Text(
                    landingData['vzweq69']?['title'] ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 14),
                  ),
                ),
              ),
            if (landingData['vzweq69'] != null)
              Container(
                width: MediaQuery.of(context).size.width,
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
            if (landingData['v9yjvmz'] != null)
              GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: landingData['v9yjvmz']['id']),
                child: CachedNetworkImage(
                    imageUrl: landingData['v9yjvmz']['image']),
              ),
            if (landingData['ilyoxtf'] != null)
              GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: landingData['ilyoxtf']['id']),
                child: CachedNetworkImage(
                    imageUrl: landingData['ilyoxtf']['image']),
              ),
            if (landingData['u15d63s'] != null)
              GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: landingData['u15d63s']['id']),
                child: CachedNetworkImage(
                    imageUrl: landingData['u15d63s']['image']),
              ),
            if (landingData['rvzphil'] != null)
              GestureDetector(
                onTap: () => _onTapProduct(
                    context: context, id: landingData['rvzphil']['id']),
                child: CachedNetworkImage(
                    imageUrl: landingData['rvzphil']['image']),
              ),
            if (landingData['kk24is5'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CachedNetworkImage(
                    imageUrl: landingData['kk24is5']['image']),
              ),
            if (landingData['2vasu9z'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CachedNetworkImage(
                    imageUrl: landingData['2vasu9z']['image']),
              ),
            Builder(builder: (context) {
              if (landingData['dp3zqf7'] == null) {
                return Container();
              }
              List<dynamic> list =
                  (landingData['dp3zqf7']['images_list'] as List<dynamic>);
              final twoDList = create2DList(list, 2);
              return Column(
                children: twoDList
                    .map((e) => Row(
                          children: e
                              .map((e) => Expanded(
                                    child: Builder(builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            FluxNavigate.pushNamed(
                                              RouteList.backdrop,
                                              arguments: BackDropArguments(
                                                config: {
                                                  "name": e['text'],
                                                  "title": e['text'],
                                                  "category": e['id'],
                                                  "keepDefaultTitle": true,
                                                  "image":
                                                      "https://i.imgur.com/BpJQMg6.png",
                                                  "colors": [
                                                    "#bb8737",
                                                    "#F57F17"
                                                  ],
                                                  "originalColor": true,
                                                  "showText": true
                                                },
                                                data: [],
                                              ),
                                            );
                                          },
                                          child: CachedNetworkImage(
                                              imageUrl: 'https://laloo.gr' +
                                                  e['image']),
                                        ),
                                      );
                                    }),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              );
            }),
            if (landingData['zn4ymk3'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CachedNetworkImage(
                    imageUrl: landingData['zn4ymk3']['image']),
              ),
            if (landingData['1qk3u03'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CachedNetworkImage(
                    imageUrl: landingData['1qk3u03']['image']),
              ),
            if (landingData['vcko1hv'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CachedNetworkImage(
                    imageUrl: landingData['vcko1hv']['image']),
              ),
            if (landingData['xkbeg5y'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CachedNetworkImage(
                    imageUrl: landingData['xkbeg5y']['image']),
              ),
          ],
        );
      case 'numbers':
        return Container();
      case 'blog':
        return BlogGrid(
          config: BlogConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'customer_testimonials':
        return Column(
          children: [
            // _testimonials(widget.config),
            if (landingData['ejqdco6'] != null)
              CachedNetworkImage(imageUrl: landingData['ejqdco6']['image']),
            if (landingData['5j0wpvw'] != null)
              CachedNetworkImage(imageUrl: landingData['5j0wpvw']['image'])
          ],
        );
      case 'video':
        return VideoLayout(
          config: widget.config,
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );

      case 'story':
        return StoryWidget(
          config: widget.config,
          onTapStoryText: (cfg) {
            NavigateTools.onTapNavigateOptions(context: context, config: cfg);
          },
        );
      case 'recentView':
        if (Config().isBuilder) {
          return ProductRecentPlaceholder();
        }
        return Services().widget.renderHorizontalListItem(widget.config);
      case 'fourColumn':
      case 'threeColumn':
      case 'twoColumn':
      case 'staggered':
      case 'saleOff':
      case 'card':
      case 'listTile':
        if (landingData['e042mgg'] == null) return Container();
        //! ****************** Carousel Vernikiwn ***************************
        List<dynamic> list =
            (landingData['e042mgg']['images_list'] as List<dynamic>);
        final twoDList = create2DList(list, 2);
        return CarouselSlider(
          options: CarouselOptions(
            height: 200,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(milliseconds: 3500),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.3,
            // onPageChanged: callbackFunction,
            scrollDirection: Axis.horizontal,
          ),
          items: twoDList
              .map((e) => Row(
                    children: e
                        .map((e) => Expanded(
                              child: Builder(builder: (context) {
                                return GestureDetector(
                                  onTap: () async {
                                    _onTapProduct(
                                        context: context, id: e['id']);
                                  },
                                  child: CachedNetworkImage(
                                      imageUrl:
                                          'https://laloo.gr' + e['image']),
                                );
                              }),
                            ))
                        .toList(),
                  ))
              .toList(),
        );

      /// New product layout style.
      case 'largeCardHorizontalListItems':
      case 'largeCard':
        return Services()
            .widget
            .renderLargeCardHorizontalListItems(widget.config);
      case 'simpleVerticalListItems':
      case 'simpleList':
        return SimpleVerticalProductList(
          config: ProductConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );

      case 'brand':
        return BrandLayout(
          config: BrandConfig.fromJson(widget.config),
        );

      /// FluxNews
      case 'sliderList':
        return Services().widget.renderSliderList(widget.config);
      case 'sliderItem':
        return Services().widget.renderSliderItem(widget.config);

      case 'geoSearch':
        return Services().widget.renderGeoSearch(widget.config);
      case 'divider':
        return DividerLayout(
          config: DividerConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'spacer':
        return SpacerLayout(
          config: SpacerConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'button':
        return ButtonLayout(
          config: ButtonConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'testimonial':
        return TestimonialLayout(
          config: TestimonialConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'sliderTestimonial':
        return SliderTestimonial(
          config: SliderTestimonialConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      case 'instagramStory':
        return InstagramStory(
          config: InstagramStoryConfig.fromJson(widget.config),
          key: widget.config['key'] != null
              ? Key(widget.config['key'])
              : UniqueKey(),
        );
      default:
        return const SizedBox();
    }
  }

  List<List<dynamic>> create2DList<T>(List<dynamic> list, int cols) {
    List<List<dynamic>> result = [];
    for (int i = 0; i < list.length; i += cols) {
      result.add(
          list.sublist(i, i + cols > list.length ? list.length : i + cols));
    }
    return result;
  }

  _onTapProduct({required BuildContext context, required String id}) async {
    try {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const LoadingWidget()));
      final p = await Services().api.getProduct(id);
      logger.i(p?.toJson());
      // Navigator.pop(context);

      if (p != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: p)));
      }
    } catch (e) {
      logger.e(e);
      Navigator.pop(context);
    }
  }
}
