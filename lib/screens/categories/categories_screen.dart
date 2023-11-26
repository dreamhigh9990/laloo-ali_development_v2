// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fstore/widgets/common/index.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../menu/appbar.dart';
import '../../models/index.dart' show AppModel, Category, CategoryModel;
import '../../modules/dynamic_layout/config/app_config.dart';
import '../../services/index.dart';
import '../category_menu/category_menu_screen.dart';
import 'layouts/column.dart';
import 'layouts/grid.dart';
import 'layouts/side_menu.dart';
import 'layouts/side_menu_with_sub.dart';
import 'layouts/sub.dart';

class CategoriesScreen extends StatefulWidget {
  final bool showSearch;
  final String lang;
  const CategoriesScreen({Key? key, this.showSearch = true, required this.lang})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late FocusNode _focus;
  bool isVisibleSearch = false;
  String? searchText;
  var textController = TextEditingController();

  late Animation<double> animation;
  late AnimationController controller;

  AppBarConfig? get appBar =>
      context.select((AppModel model) => model.appConfig?.appBar);
  String fontSettings = 'Disabled';
  late SharedPreferences preferences;

  // ignore: always_declare_return_types
  init() async {
    preferences = await SharedPreferences.getInstance();
    var fontSetting = preferences.getString('fontSetting');
    setState(() {
      fontSettings = fontSetting!;
    });
    log('Font Settings (Category Screen)==> $fontSettings');
  }

  String locale = '';
  @override
  void initState() {
    super.initState();
    locale = widget.lang;
    init();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
    loadedMenues();
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  List<MenuPageModel>? pages;

  loadedMenues() async {
    try {
      List<MenuPageModel> _pages = [];
      final links = await getLinks();
      for (final link in links) {
        final MenuPageModel? menuPageModel = await getLinkData(link.id);
        if (menuPageModel != null) {
          _pages.add(menuPageModel);
        }
      }

      setState(() {
        pages = _pages;
      });
    } catch (e) {
      setState(() {
        pages = [];
      });
    }
  }

  Future<MenuPageModel?> getLinkData(String id) async {
    try {
      String link =
          'https://X2SHFNYYQKHYMZ46Q8KF3J4K3W5449WT@laloo.gr/api/cms/$id';
      logger.d(link);
      final response = await http.get(Uri.parse(link));
      final document = XmlDocument.parse(response.body);
      document.toXmlString();
      final myTransformer = Xml2Json();
      myTransformer.parse(document.toXmlString());
      var json = myTransformer.toParkerWithAttrs();
      Map<String, dynamic> data = jsonDecode(json);
      final langId =
          Localizations.localeOf(context).languageCode == 'en' ? '1' : '2';
      final pageTitle =
          (data['prestashop']['cms']['meta_title']['language'] as List<dynamic>)
              .firstWhere((element) => element['_id'] == langId);
      final pageValue =
          (data['prestashop']['cms']['content']['language'] as List<dynamic>)
              .firstWhere((element) => element['_id'] == langId);
      pageTitle['pageId'] = id;
      MenuPageModel menuPageModel =
          MenuPageModel.fromJson(pageTitle, jsonDecode(pageValue['value']));
      return menuPageModel;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<List<LinkModel>> getLinks() async {
    try {
      const String menues =
          'https://X2SHFNYYQKHYMZ46Q8KF3J4K3W5449WT@laloo.gr/api/appMenu';
      final response = await http.get(Uri.parse(menues));
      final document = XmlDocument.parse(response.body);
      document.toXmlString();
      final myTransformer = Xml2Json();
      myTransformer.parse(document.toXmlString());
      var json = myTransformer.toParkerWithAttrs();
      Map<String, dynamic> data = jsonDecode(json);
      final links = data['prestashop']['cms']['cms'];
      final List<LinkModel> linksMenu =
          (links as List<dynamic>).map((e) => LinkModel.fromJson(e)).toList();
      return linksMenu;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);
    final appModel = Provider.of<AppModel>(context);

    return fontSettings == 'Disabled'
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await loadedMenues();
                  },
                  child: ListenableProvider.value(
                    value: category,
                    updateShouldNotify: (previous, current) {
                      if (current.isLoading) {
                        loadedMenues();
                      }
                      return true;
                    },
                    child: Consumer<CategoryModel>(
                      builder: (context, value, child) {
                        // if (value.isLoading) {
                        //   return kLoadingWidget(context);
                        // }

                        // if (value.categories == null) {
                        //   return Container(
                        //     width: double.infinity,
                        //     height: double.infinity,
                        //     alignment: Alignment.center,
                        //     child: Text(S.of(context).dataEmpty),
                        //   );
                        // }

                        // var categories = value.categories;
                        // categories!.sort(
                        //   (a, b) => a.position!.compareTo(b.position!),
                        // );
                        // return SafeArea(
                        //   bottom: false,
                        //   child: [
                        //     GridCategory.type,
                        //     ColumnCategories.type,
                        //     SideMenuCategories.type,
                        //     SubCategories.type,
                        //     SideMenuSubCategories.type
                        //   ].contains(appModel.categoryLayout)
                        //       ? Column(
                        //           children: <Widget>[
                        //             renderHeader(),
                        //             // Expanded(
                        //             //   child: renderCategories(
                        //             //       categories, appModel.categoryLayout),
                        //             // )
                        //           ],
                        //         )
                        //       : ListView(
                        //           children: <Widget>[
                        //             renderHeader(),
                        //             renderCategories(
                        //                 categories, appModel.categoryLayout)
                        //           ],
                        //         ),
                        // );
                        return Column(
                          children: [
                            AppBar(
                              titleSpacing: 0,
                              elevation: 0,
                              automaticallyImplyLeading: false,
                              centerTitle: true,
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              title: Text(S.of(context).menuPages),
                            ),
                            pages == null
                                ? const LoadingWidget()
                                : pages?.isNotEmpty == true
                                    ? Flexible(
                                        child: ListView(
                                          children: pages!
                                              .map(
                                                (e) => GestureDetector(
                                                  onTap: () {
                                                    showGeneralDialog(
                                                      context: context,
                                                      pageBuilder: (context,
                                                              animation,
                                                              secondaryAnimation) =>
                                                          CategoryMenueScreen(
                                                        data: e,
                                                      ),
                                                    );
                                                    // CategoryMenueScreen
                                                  },
                                                  child: LayoutBuilder(builder:
                                                      (context, constraints) {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      width:
                                                          constraints.maxWidth,
                                                      height:
                                                          constraints.maxWidth *
                                                              0.35,
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                                .fromRGBO(
                                                            0, 0, 0, 0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          e.title,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      )
                                    : Container(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: (appBar?.shouldShowOn(RouteList.category) ?? false)
                ? AppBar(
                    titleSpacing: 0,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    title: FluxAppBar(),
                  )
                : null,
            backgroundColor: Theme.of(context).colorScheme.background,
            body: ListenableProvider.value(
              value: category,
              child: Consumer<CategoryModel>(
                builder: (context, value, child) {
                  if (value.isLoading) {
                    return kLoadingWidget(context);
                  }

                  if (value.categories == null) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Text(S.of(context).dataEmpty),
                    );
                  }

                  var categories = value.categories;

                  return SafeArea(
                    bottom: false,
                    child: [
                      GridCategory.type,
                      ColumnCategories.type,
                      SideMenuCategories.type,
                      SubCategories.type,
                      SideMenuSubCategories.type
                    ].contains(appModel.categoryLayout)
                        ? Column(
                            children: <Widget>[
                              renderHeader(),
                              Expanded(
                                child: renderCategories(
                                    categories, appModel.categoryLayout),
                              )
                            ],
                          )
                        : ListView(
                            children: <Widget>[
                              renderHeader(),
                              renderCategories(
                                  categories, appModel.categoryLayout)
                            ],
                          ),
                  );
                },
              ),
            ),
          );
  }

  Widget renderHeader() {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (Navigator.canPop(context))
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.arrow_back_ios,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, bottom: 10, right: 10),
                child: Text(
                  S.of(context).category,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (widget.showSearch)
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.6),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteList.categorySearch);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderCategories(List<Category>? categories, String layout) {
    return Services().widget.renderCategoryLayout(categories, layout);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class LinkModel {
  final String id;
  final String link;
  LinkModel({required this.id, required this.link});

  factory LinkModel.fromJson(json) {
    return LinkModel(id: json['_id'], link: json['_xlink:href']);
  }
}

class MenuPageModel {
  final String pageId;
  final String languageId;
  final String title;
  final Map<String, dynamic> data;

  MenuPageModel({
    required this.languageId,
    required this.title,
    required this.pageId,
    required this.data,
  });

  factory MenuPageModel.fromJson(json, data) {
    return MenuPageModel(
        languageId: json['_id'],
        title: json['value'],
        pageId: json['pageId'],
        data: data);
  }
}
