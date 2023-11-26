import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Product;
import '../../../widgets/common/expansion_info.dart';
import '../../../widgets/html/index.dart' as html;

class ProductShortDescription extends StatelessWidget {
  final Product product;

  const ProductShortDescription(this.product);

  @override
  Widget build(BuildContext context) {
    if (product.shortDescription?.isEmpty ?? true) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ExpansionInfo(
        title: S.of(context).shortDescription,
        expand: true,
        children: <Widget>[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: html.HtmlWidget(
              product.shortDescription!,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
