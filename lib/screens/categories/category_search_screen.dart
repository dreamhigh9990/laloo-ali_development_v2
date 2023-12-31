import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants.dart';
import '../../models/index.dart'
    show BackDropArguments, Category, CategoryModel;
import '../../routes/flux_navigate.dart';
import '../index.dart' show SearchBox;

class CategorySearch extends StatefulWidget {
  const CategorySearch();

  @override
  State<StatefulWidget> createState() => _CategorySearchState();
}

class _CategorySearchState<T> extends State<CategorySearch> {
  final _searchFieldNode = FocusNode();
  final _searchFieldController = TextEditingController();

  List<Category> categories = [];
  String fontSettings = 'Disabled';
  late SharedPreferences preferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  // ignore: always_declare_return_types
  init() async {
    preferences = await SharedPreferences.getInstance();
    var fontSetting = preferences.getString('fontSetting');
    setState(() {
      fontSettings = fontSetting!;
    });
    log('Font Settings (Cart Search Screen)==> $fontSettings');
  }

  @override
  void dispose() {
    _searchFieldNode.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  void _onSearchTextChange(String value) {
    if (value.isEmpty) {
      setState(() {
        categories = [];
      });
      return;
    }

    if (_searchFieldNode.hasFocus) {
      final categoryModel = Provider.of<CategoryModel>(context, listen: false);
      categories = categoryModel.categories!
          .where((e) => e.name!.toLowerCase().contains(value.toLowerCase()))
          .toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    var theme = Theme.of(context);
    theme = Theme.of(context).copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
    final searchFieldLabel = MaterialLocalizations.of(context).searchFieldLabel;
    var routeName = isIos ? '' : searchFieldLabel;

    return fontSettings == 'Disabled'
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Semantics(
              explicitChildNodes: true,
              scopesRoute: true,
              namesRoute: true,
              label: routeName,
              child: Scaffold(
                backgroundColor: theme.colorScheme.background,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.background,
                  iconTheme: theme.primaryIconTheme,
                  // textTheme: theme.primaryTextTheme,
                  // brightness: theme.primaryColorBrightness,
                  titleSpacing: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: close,
                  ),
                  title: SearchBox(
                    showSearchIcon: false,
                    showCancelButton: false,
                    autoFocus: true,
                    controller: _searchFieldController,
                    focusNode: _searchFieldNode,
                    onChanged: _onSearchTextChange,
                  ),
                ),
                body: AutoHideKeyboard(
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                          child: buildResult(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Semantics(
            explicitChildNodes: true,
            scopesRoute: true,
            namesRoute: true,
            label: routeName,
            child: Scaffold(
              backgroundColor: theme.colorScheme.background,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                backgroundColor: theme.colorScheme.background,
                iconTheme: theme.primaryIconTheme,
                // textTheme: theme.primaryTextTheme,
                // brightness: theme.primaryColorBrightness,
                titleSpacing: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: close,
                ),
                title: SearchBox(
                  showSearchIcon: false,
                  showCancelButton: false,
                  autoFocus: true,
                  controller: _searchFieldController,
                  focusNode: _searchFieldNode,
                  onChanged: _onSearchTextChange,
                ),
              ),
              body: AutoHideKeyboard(
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        reverseDuration: const Duration(milliseconds: 300),
                        child: buildResult(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildResult() {
    return ListView.separated(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        var item = categories[index];
        return _SearchCategoryItem(category: item);
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.black.withOpacity(0.05),
      ),
    );
  }

  void close() {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    Navigator.of(context).pop();
  }
}

class _SearchCategoryItem extends StatelessWidget {
  final Category category;

  const _SearchCategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FluxNavigate.pushNamed(
        RouteList.backdrop,
        arguments: BackDropArguments(
          cateId: category.id,
          cateName: category.name,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(category.image!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(category.name!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
