import 'package:flutter/material.dart';
import 'package:inspireui/widgets/expandable/expansion_widget.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show BlogModel, Category, CategoryModel, ProductModel;
import '../../common/tree_view.dart';
import 'category_item.dart';

class CategoryMenu extends StatefulWidget {
  final Function(Category category) onFilter;
  final bool isUseBlog;

  const CategoryMenu({
    Key? key,
    required this.onFilter,
    this.isUseBlog = false,
  }) : super(key: key);

  @override
  State<CategoryMenu> createState() => _CategoryTreeState();
}

class _CategoryTreeState extends State<CategoryMenu> {
  // CategoryModel get category => Provider.of<CategoryModel>(context);
  String? get categoryId => Provider.of<ProductModel>(context).categoryId;
  bool? exp;

  bool? hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category>? getSubCategories(List<Category> categories, id) {
    final cats = categories.where((o) => o.parent == id).toList();
    return cats;
  }

  List<Widget> _getCategoryItems(
    List<Category> categories, {
    String? id,
    required Function onFilter,
    int level = 1,
  }) {
    categories.sort((a, b) => a.position!.compareTo(b.position!));
    final cats0 = getSubCategories(categories, id)!;
    // cats.sort((a, b) => a.position!.compareTo(b.position!));
    return [
      for (int i = 0; i < cats0.length; i++) ...[
        Builder(builder: (_) {
          Category cat;
          try {
            cat = cats0
                .firstWhere((element) => int.parse(element.position!) == i);
          } catch (e) {
            cat = cats0[i];
          }
          return Parent(
            isSelected: cat.id == '12' ? true : cat.isExpanded,
            onTap: () {
              // print(catid);
              getId(cat, cat.id);
              // for (var cat in getSubCategories(categories, id)!) {
              //   if (cat.id == cat.id) {
              //     cat.isExpanded = !cat.isExpanded;
              //   } else {
              //     cat.isExpanded = false;
              //   }
              // }
              setState(() {});
            },
            parent: CategoryItem(
              cat,
              hasChild: hasChildren(categories, cat.id),
              isSelected: cat.id == categoryId,
              onTap: () => onFilter(cat),
              level: level,
            ),
            childList: ChildList(
              children: [
                if (hasChildren(categories, cat.id)!)
                  CategoryItem(
                    cat,
                    isParent: true,
                    isSelected: cat.id == categoryId,
                    onTap: () => onFilter(cat),
                    level: level + 1,
                  ),
                ..._getCategoryItems(
                  categories,
                  id: cat.id,
                  onFilter: widget.onFilter,
                  level: level + 1,
                )
              ],
            ),
          );
        }),
      ],
    ];
  }

  void getId(Category cat, String? id) {
    if (cat.id == id && cat.isExpanded == false) {
      cat.isExpanded = true;
      setState(() {
        exp = true;
      });

      print(cat);
    } else {
      cat.isExpanded = false;
      setState(() {
        exp = false;
      });

      print(cat);
    }
  }

  Widget getTreeView({required List<Category> categories}) {
    final rootCategories =
        categories.where((item) => item.parent == '0').toList();
    // rootCategories.sort((a, b) => a.position!.compareTo(b.position!));
    return TreeView(
      parentList: [
        for (var item in rootCategories)
          Parent(
            isSelected: item.isExpanded,
            onTap: () {
              // print('tap2');
              for (var cat in rootCategories) {
                if (cat.id == item.id) {
                  item.isExpanded = !item.isExpanded;
                } else {
                  cat.isExpanded = false;
                }
              }
              setState(() {});
            },
            parent: CategoryItem(
              item,
              hasChild: hasChildren(categories, item.id),
              expanded: exp,
              isSelected: item.id == categoryId,
              onTap: () => widget.onFilter(item),
            ),
            childList: ChildList(
              children: [
                if (hasChildren(categories, item.id)!)
                  CategoryItem(
                    item,
                    isParent: true,
                    isSelected: item.id == categoryId,
                    onTap: () =>
                        // getId(item),
                        widget.onFilter(item),
                    level: 2,
                  ),
                ..._getCategoryItems(
                  categories,
                  id: item.id,
                  onFilter: widget.onFilter,
                  level: 2,
                )
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionWidget(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 25,
        bottom: 10,
      ),
      title: Text(
        S.of(context).byCategory.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.only(top: 5.0, bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white12,
          ),
          child: widget.isUseBlog
              ? Selector<BlogModel, List<Category>>(
                  builder: (context, categories, child) => getTreeView(
                    categories: categories,
                  ),
                  selector: (_, model) => model.categories,
                )
              : Selector<CategoryModel, List<Category>>(
                  builder: (context, categories, child) => getTreeView(
                    categories: categories,
                  ),
                  selector: (_, model) => model.categories ?? [],
                ),
        ),
      ],
    );
  }
}
