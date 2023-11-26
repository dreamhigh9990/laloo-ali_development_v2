import 'package:flutter/material.dart';
import 'package:inspireui/utils.dart';
import '../common/config.dart';

import '../models/cart/cart_model.dart';
import '../services/index.dart';
import 'entities/order_delivery_date.dart';
import 'entities/shipping_method.dart';

class ShippingMethodModel extends ChangeNotifier {
  final Services _service = Services();
  List<ShippingMethod>? shippingMethods;
  bool isLoading = true;
  String? message;

  List<OrderDeliveryDate>? _deliveryDates;
  List<OrderDeliveryDate>? get deliveryDates => _deliveryDates;

  Future<void> getShippingMethods(
      {CartModel? cartModel, String? token, String? checkoutId}) async {
    try {
      isLoading = true;
      notifyListeners();
      final _shippingMethods = await _service.api.getShippingMethods(
          cartModel: cartModel, token: token, checkoutId: checkoutId);
      _shippingMethods?.forEach((element) {
        print(element.toJson());
      });
      if (_shippingMethods?.isNotEmpty == true) {
        shippingMethods = [];
      }
      for (final method in _shippingMethods ?? []) {
        if (method.id == '387') {
          shippingMethods!.insert(0, method);
        } else if (method.id == '388') {
          try {
            shippingMethods!.insert(1, method);
          } catch (e) {
            shippingMethods!.insert(0, method);
          }
        } else {
          shippingMethods!.add(method);
        }
      }

      if (kAdvanceConfig['EnableDeliveryDateOnCheckout'] ?? false) {
        _deliveryDates = await getDelivery();
      }
      isLoading = false;
      message = null;
      notifyListeners();
    } catch (err) {
      logger.e(err);
      isLoading = false;
      message = '⚠️ ' + err.toString();
      notifyListeners();
    }
  }

  Future<List<OrderDeliveryDate>> getDelivery() async {
    return await _service.api.getListDeliveryDates();
  }
}
