import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show Skeleton;
import 'package:transparent_image/transparent_image.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show BackDropArguments, Category;
import '../../../routes/flux_navigate.dart';
import '../../../widgets/common/tree_view.dart';
import '../../base_screen.dart';
import '../../index.dart';

class CardCategories extends StatefulWidget {
  static const String type = 'card';

  final List<Category>? categories;

  const CardCategories(this.categories);

  @override
  _StateCardCategories createState() => _StateCardCategories();
}

class _StateCardCategories extends BaseScreen<CardCategories> {
  ScrollController controller = ScrollController();
  late double page;

  @override
  void initState() {
    page = 0.0;
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    controller.addListener(() {
      setState(() {
        page = _getPage(controller.position, screenSize.width * 0.30 + 10);
      });
    });
  }

  bool hasChildren(id) {
    return widget.categories!.where((o) => o.parent == id).toList().isNotEmpty;
  }

  double _getPage(ScrollPosition position, double width) {
    return position.pixels / width;
  }

  List<Category> getSubCategories(id) {
    return widget.categories!.where((o) => o.parent == id).toList();
  }

  void navigateToBackDrop(Category category) {
    FluxNavigate.pushNamed(
      RouteList.backdrop,
      arguments: BackDropArguments(
        cateId: category.id,
        cateName: category.name,
      ),
    );
  }

  Widget getChildCategoryList(category) {
    return ChildList(
      children: [
        GestureDetector(
          onTap: () => navigateToBackDrop(category),
          child: SubItem(
            category,
            seeAll: S.of(context).seeAll,
          ),
        ),
        for (var cat in getSubCategories(category.id))
          Parent(
            isSelected: cat.isExpanded,
            onTap: () {
              print(cat.isExpanded);
              getSubCategories(category.id).forEach((c) {
                setState(() {
                  c.isExpanded = false;
                });
              });
              setState(() {
                cat.isExpanded = !cat.isExpanded;
              });
            },
            callback: (isSelected) {
              if (getSubCategories(cat.id).isEmpty) {
                navigateToBackDrop(cat);
              }
            },
            parent: SubItem(cat),
            childList: ChildList(
              children: [
                for (var cate2 in getSubCategories(cat.id))
                  Parent(
                    isSelected: cate2.isExpanded,
                    onTap: () {
                      print(cate2.isExpanded);
                      getSubCategories(cat.id).forEach((c) {
                        setState(() {
                          c.isExpanded = false;
                        });
                      });
                      setState(() {
                        cate2.isExpanded = !cate2.isExpanded;
                      });
                    },
                    callback: (isSelected) {
                      if (getSubCategories(cate2.id).isEmpty) {
                        FluxNavigate.pushNamed(
                          RouteList.backdrop,
                          arguments: BackDropArguments(
                            cateId: cate2.id,
                            cateName: cate2.name,
                          ),
                        );
                      }
                    },
                    parent: SubItem(cate2, level: 1),
                    childList: ChildList(
                      children: [
                        for (var _cate in getSubCategories(cate2.id))
                          Parent(
                            isSelected: _cate.isExpanded,
                            onTap: () {
                              print(_cate.isExpanded);
                              getSubCategories(cate2.id).forEach((c) {
                                setState(() {
                                  c.isExpanded = false;
                                });
                              });
                              setState(() {
                                _cate.isExpanded = !_cate.isExpanded;
                              });
                            },
                            callback: (isSelected) {
                              FluxNavigate.pushNamed(
                                RouteList.backdrop,
                                arguments: BackDropArguments(
                                  cateId: _cate.id,
                                  cateName: _cate.name,
                                ),
                              );
                            },
                            parent: SubItem(_cate, level: 2),
                            childList: const ChildList(children: []),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var _categories =
        widget.categories!.where((item) => item.parent == '0').toList();
    if (_categories.isEmpty) {
      _categories = widget.categories!;
    }

    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          TreeView(
            parentList: List.generate(
              _categories.length,
              (index) {
                return Parent(
                  isSelected: _categories[index].isExpanded,
                  onTap: () {
                    for (var cat in _categories) {
                      if (cat.id == _categories[index].id) {
                        _categories[index].isExpanded =
                            !_categories[index].isExpanded;
                      } else {
                        cat.isExpanded = false;
                      }
                    }
                    setState(() {});
                  },
                  parent: _CategoryCardItem(
                    _categories[index],
                    hasChildren: hasChildren(_categories[index].id),
                    offset: page - index,
                  ),
                  childList:
                      getChildCategoryList(_categories[index]) as ChildList,
                );
              },
            ),
          ),
          const SizedBox(height: 100)
        ],
      ),
    );
  }
}

class _CategoryCardItem extends StatelessWidget {
  final Category category;
  final bool hasChildren;
  final offset;

  const _CategoryCardItem(this.category,
      {this.hasChildren = false, this.offset});

  /// Render category Image support caching on ios/android
  /// also fix loading on Web
  Widget renderCategoryImage(maxWidth) {
    final image = category.image ?? '';
    if (image.isEmpty) return const SizedBox();

    var imageProxy = '$kImageProxy${maxWidth}x,q30/';

    if (image.contains('http') && kIsWeb) {
      return FadeInImage.memoryNetwork(
        image: '$imageProxy$image',
        fit: BoxFit.cover,
        width: maxWidth,
        height: maxWidth * 0.35,
        placeholder: kTransparentImage,
      );
    }

    return image.contains('http')
        ? CachedNetworkImage(
            imageUrl: category.image!,
            fit: BoxFit.cover,
            alignment: Alignment(
              0.0,
              (offset >= -1 && offset <= 1)
                  ? offset
                  : (offset > 0)
                      ? 1.0
                      : -1.0,
            ),
            // fadeInCurve: Curves.easeIn,
            errorWidget: (context, url, error) => const SizedBox(),
            imageBuilder:
                (BuildContext context, ImageProvider<dynamic> imageProvider) {
              return Image(
                width: maxWidth,
                image: imageProvider as ImageProvider<Object>,
                fit: BoxFit.cover,
              );
            },
            placeholder: (context, url) => Skeleton(
              width: maxWidth,
              height: maxWidth * 0.35,
            ),
          )
        : Image.asset(
            category.image!,
            fit: BoxFit.cover,
            width: maxWidth,
            height: maxWidth * 0.35,
            alignment: Alignment(
              0.0,
              (offset >= -1 && offset <= 1)
                  ? offset
                  : (offset > 0)
                      ? 1.0
                      : -1.0,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: hasChildren
          ? null
          : () {
              FluxNavigate.pushNamed(
                RouteList.backdrop,
                arguments: BackDropArguments(
                  cateId: category.id,
                  cateName: category.name,
                ),
              );
            },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxWidth * 0.35,
            padding: const EdgeInsets.only(left: 10, right: 10),
            margin: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                    child: renderCategoryImage(constraints.maxWidth)),
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth * 0.35,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.3),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth /
                        (2 / (screenSize.height / constraints.maxWidth)),
                    height: constraints.maxWidth * 0.35,
                    child: Center(
                      child: Text(
                        category.name ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SubItem extends StatelessWidget {
  final Category category;
  final String seeAll;
  final int level;

  const SubItem(this.category, {this.seeAll = '', this.level = 0});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 0.5,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withOpacity(level == 0 && seeAll == '' ? 0.2 : 0),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 15.0),
              for (int i = 1; i <= level; i++)
                Container(
                  width: 20.0,
                  margin: const EdgeInsets.only(top: 8.0, right: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1.5,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  seeAll != '' ? seeAll : category.name!,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
              // Text(
              //   S.of(context).nItems(category.totalProduct.toString()),
              //   style: TextStyle(
              //       fontSize: 14, color: Theme.of(context).primaryColor),
              // ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  FluxNavigate.pushNamed(
                    RouteList.backdrop,
                    arguments: BackDropArguments(
                      cateId: category.id,
                      cateName: category.name,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
