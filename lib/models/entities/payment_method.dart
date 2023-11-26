import 'package:quiver/strings.dart';

import '../../common/constants.dart';
import '../serializers/payment.dart';

class PaymentMethod {
  String? id;
  String? title;
  String? description;
  bool? enabled;
  double? codCost;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'enabled': enabled
    };
  }

  PaymentMethod.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    title = isNotBlank(parsedJson['title'])
        ? parsedJson['title']
        : parsedJson['method_title'];
    description = parsedJson['description'];
    enabled = true;
  }

  PaymentMethod.fromNotion(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    title = isNotBlank(parsedJson['title'])
        ? parsedJson['title']
        : parsedJson['method_title'];
    description = parsedJson['description'];
    enabled = true;
  }

  PaymentMethod.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['code'];
    title = parsedJson['title'];
    description = '';
    enabled = true;
  }

  PaymentMethod.fromOpencartJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['code'];
    title = parsedJson['title'];
    description = '';
    enabled = true;
  }

  PaymentMethod.fromPrestaJson(Map<String, dynamic> parsedJson) {
    logger.i(parsedJson);
    id = parsedJson['name'];
    title = parsedJson['active'];
    description = '';
    codCost = _codCost(parsedJson['name']);
    enabled = _setEnable(parsedJson['name']);
  }

  bool _setEnable(String name) {
    switch (name) {
      case 'vivapay':
      case 'ps_cashondelivery':
      case 'paypal':
        return true;
      default:
        return false;
    }
  }

  double? _codCost(String name) {
    switch (name) {
      case 'ps_cashondelivery':
        return 1.5;
      default:
        return null;
    }
  }

  PaymentMethod.fromStrapiJson(Map<String, dynamic> parsedJson) {
    var model = SerializerPayment.fromJson(parsedJson);
    try {
      id = model.id.toString();
      title = model.title;
      description = model.description ?? '';
      enabled = true;
    } on Exception catch (e, trace) {
      printLog('Error on Payment Models Strapi: $e trace: ${trace.toString()}');
    }
  }
}
