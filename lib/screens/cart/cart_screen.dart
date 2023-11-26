import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants.dart';
import '../../models/cart/cart_base.dart';
import '../../widgets/common/loading_body.dart';
import '../common/app_bar_mixin.dart';
import 'my_cart_screen.dart';

class CartScreenArgument {
  final bool isModal;
  final bool isBuyNow;

  CartScreenArgument({
    required this.isModal,
    required this.isBuyNow,
  });
}

class CartScreen extends StatefulWidget {
  final bool? isModal;
  final bool isBuyNow;

  const CartScreen({this.isModal, this.isBuyNow = false});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with AppBarMixin {
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
    log('Font Settings (Cart Screen)==> $fontSettings');
  }

  @override
  Widget build(BuildContext context) {
    return fontSettings == 'Disabled'
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Scaffold(
              appBar: showAppBar(RouteList.cart) ? appBarWidget : null,
              backgroundColor: Theme.of(context).colorScheme.background,
              body: Selector<CartModel, bool>(
                selector: (_, cartModel) => cartModel.calculatingDiscount,
                builder: (context, calculatingDiscount, child) {
                  return LoadingBody(
                    isLoading: calculatingDiscount,
                    child: child!,
                  );
                },
                child: MyCart(
                  isBuyNow: widget.isBuyNow,
                  isModal: widget.isModal,
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: showAppBar(RouteList.cart) ? appBarWidget : null,
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Selector<CartModel, bool>(
              selector: (_, cartModel) => cartModel.calculatingDiscount,
              builder: (context, calculatingDiscount, child) {
                return LoadingBody(
                  isLoading: calculatingDiscount,
                  child: child!,
                );
              },
              child: MyCart(
                isBuyNow: widget.isBuyNow,
                isModal: widget.isModal,
              ),
            ),
          );
  }
}
