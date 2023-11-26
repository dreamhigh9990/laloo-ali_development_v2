import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, CartModel, Product;
import '../../services/service_config.dart';
import '../../widgets/product/dialog_add_to_cart.dart';

class EmptyWishlist extends StatefulWidget {
  final VoidCallback onShowHome;
  final VoidCallback onSearchForItem;

  const EmptyWishlist({
    required this.onShowHome,
    required this.onSearchForItem,
  });

  @override
  State<EmptyWishlist> createState() => _EmptyWishlistState();
}

class _EmptyWishlistState extends State<EmptyWishlist> {
  String fontSettings = 'Disabled';
  late SharedPreferences preferences;

  @override
  void initState() {
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
    log('Font Settings (Wish List Screen)==> $fontSettings');
  }

  @override
  Widget build(BuildContext context) {
    return fontSettings == 'Disabled'
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 80),
                  Image.asset(
                    'assets/images/empty_wishlist.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).noFavoritesYet,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(S.of(context).emptyWishlistSubtitle,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.black,
                            ),
                            onPressed: widget.onShowHome,
                            child: Text(
                              S.of(context).startShopping.toUpperCase(),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: kGrey400, backgroundColor: kGrey200,
                            ),
                            onPressed: widget.onSearchForItem,
                            child: Text(
                                S.of(context).searchForItems.toUpperCase()),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 80),
                Image.asset(
                  'assets/images/empty_wishlist.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  S.of(context).noFavoritesYet,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(S.of(context).emptyWishlistSubtitle,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ButtonTheme(
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.black,
                          ),
                          onPressed: widget.onShowHome,
                          child: Text(
                            S.of(context).startShopping.toUpperCase(),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ButtonTheme(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: kGrey400, backgroundColor: kGrey200,
                          ),
                          onPressed: widget.onSearchForItem,
                          child:
                              Text(S.of(context).searchForItems.toUpperCase()),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
  }
}

class WishlistItem extends StatelessWidget {
  const WishlistItem({required this.product, this.onAddToCart, this.onRemove});

  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final localTheme = Theme.of(context);
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteList.productDetail,
                arguments: product,
              );
            },
            child: Row(
              key: ValueKey(product.id),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onRemove,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxWidth * 0.3,
                              child: ImageTools.image(
                                  url: product.imageFeature,
                                  size: kSize.medium),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? '',
                                    style: localTheme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                      PriceTools.getPriceProduct(
                                          product, currencyRate, currency)!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: kGrey400, fontSize: 14)),
                                  const SizedBox(height: 10),
                                  if (kEnableShoppingCart &&
                                      !Config().isListingType)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: localTheme.primaryColor,
                                      ),
                                      onPressed: () => DialogAddToCart.show(
                                          context,
                                          product: product),
                                      child: (product.isPurchased &&
                                              product.isDownloadable!)
                                          ? Text(S
                                              .of(context)
                                              .download
                                              .toUpperCase())
                                          : Text(S
                                              .of(context)
                                              .addToCart
                                              .toUpperCase()),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          const Divider(color: kGrey200, height: 1),
          const SizedBox(height: 10.0),
        ]);
      },
    );
  }
}
