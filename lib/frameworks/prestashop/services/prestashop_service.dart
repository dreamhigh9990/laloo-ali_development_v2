import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import 'prestashop_api.dart';

class PrestashopService extends BaseServices {
  PrestashopService({
    required String domain,
    String? blogDomain,
    required String key,
  })  : prestaApi = PrestashopAPI(url: domain, key: key),
        super(domain: domain, blogDomain: blogDomain);

  final PrestashopAPI prestaApi;

  List<Category>? cats;
  List<Map<String, dynamic>>? productOptions;
  List<Map<String, dynamic>>? productOptionValues;
  List<Map<String, dynamic>>? orderStates;
  Map<String, dynamic> orderAddresses = <String, dynamic>{};
  String? idLang;
  String? languageCode;

  void appConfig(appConfig) {
    productOptions = null;
    productOptionValues = null;
    orderStates = null;
    cats = null;
    orderAddresses = <String, dynamic>{};
  }

  List<dynamic> downLevelsCategories(dynamic cats) {
    int? parent;
    var categories = <dynamic>[];
    for (var item in cats) {
      if (parent == null || int.parse(item['id_parent'].toString()) < parent) {
        parent = int.parse(item['id_parent'].toString());
      }
    }
    for (var item in cats) {
      if (int.parse(item['id_parent'].toString()) == parent) continue;
      categories.add(item);
    }
    return categories;
  }

  List<dynamic> setParentCategories(dynamic cats) {
    int? parent;
    var categories = <dynamic>[];
    for (var item in cats) {
      if (parent == null || int.parse(item['id_parent'].toString()) < parent) {
        parent = int.parse(item['id_parent'].toString());
      }
    }
    for (var item in cats) {
      if (int.parse(item['id_parent'].toString()) == parent) {
        item['id_parent'] = '0';
      }
      categories.add(item);
    }
    return categories;
  }

  @override
  Future<List<Category>?> getCategories({lang}) async {
    try {
      if (languageCode != lang) await getLanguage(lang: lang);
      if (cats != null) return cats;
      var categoriesId;
      var result = <Category>[];
      categoriesId =
          await prestaApi.getAsync('categories?filter[active]=1&display=full');
      var categories = categoriesId['categories'];
      categories = downLevelsCategories(categories);
      categories = downLevelsCategories(categories);
      categories = setParentCategories(categories);
      for (var item in categories) {
        item['name'] = getValueByLang(item['name']);
        // printLog(item);
        result.add(Category.fromJsonPresta(item, prestaApi.apiLink));
      }
      result.sort((a, b) => a.position!.compareTo(b.position!));
      cats ??= result;
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) async {
    try {
      var productsId;
      var products = <Product>[];
      productsId = await prestaApi.getAsync('products');
      for (var item in productsId['products']) {
        var category = await prestaApi.getAsync('products/${item["id"]}');
        if (category['product']['name'].isEmpty) continue;
        products
            .add(Product.fromPresta(category['product'], prestaApi.apiLink));
      }
      return products;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout(
      {required config, lang, userId, bool refreshCache = false}) async {
    try {
      var products = <Product>[];
      if (languageCode != lang) await getLanguage(lang: lang);
      if (cats == null) await getCategories();
      if (productOptions == null) {
        await getProductOptions();
      }
      if (productOptionValues == null) {
        await getProductOptionValues();
      }
      var filter = '';
      if (config.containsKey('category')) {
        var childs = getChildCategories([config['category'].toString()]);
        filter = '&id_category=${childs.toString()}';
        filter = filter.replaceAll('[', '');
        filter = filter.replaceAll(']', '');
      }
      if (kAdvanceConfig['hideOutOfStock']) {
        filter += '&hide_stock=true';
      }
      var page = config.containsKey('page') ? config['page'] : 1;
      var display = 'full';
      var limit =
          '${(page - 1) * apiPageSize},${config['limit'] ?? apiPageSize}';
      var response = await prestaApi
          .getAsync('product?display=$display&limit=$limit$filter&lang=$lang');
      if (response is Map) {
        for (var item in response['products']) {
          var productOptionValues =
              item['associations']['product_option_values'];
          if (productOptionValues != null) {
            var attribute = <String?, dynamic>{};
            for (var option in productOptionValues) {
              var opt = productOptionValues!.firstWhereOrNull(
                  (e) => e['id'].toString() == option['id'].toString());
              if (opt != null) {
                var name = productOptions!.firstWhereOrNull((e) =>
                    e['id'].toString() == opt['id_attribute_group'].toString());
                if (name != null) {
                  var val = attribute[getValueByLang(name['name'])] ?? [];
                  val.add(getValueByLang(opt['name']));
                  attribute.update(getValueByLang(name['name']), (value) => val,
                      ifAbsent: () => val);
                }
              }
            }
            item['attributes'] = attribute;
          }
          products.add(Product.fromPresta(item, prestaApi.apiLink));
        }
      } else {
        return [];
      }
      return products;
    } catch (e, trace) {
      printLog(trace.toString());
      printLog(e.toString());
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      return [];
    }
  }

  //get all attribute_term for selected attribute for filter menu
  @override
  Future<List<SubAttribute>> getSubAttributes({int? id, String? lang}) async {
    try {
      var list = <SubAttribute>[];
      if (productOptionValues == null) await getProductOptions();
      for (var item in productOptionValues!) {
        if (item['id_attribute_group'].toString() == id.toString()) {
          list.add(SubAttribute.fromJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  //get all attributes for filter menu
  @override
  Future<List<FilterAttribute>> getFilterAttributes({String? lang}) async {
    var list = <FilterAttribute>[];
    if (productOptions == null) await getProductOptions();

    for (var item in productOptions!) {
      list.add(FilterAttribute.fromJson(
          {'id': item['id'], 'name': item['name'], 'slug': item['name']}));
    }
    return list;
  }

  List<String?> getChildCategories(List<String?> categories) {
    // ignore: unnecessary_null_comparison
    var categoriesList = categories != null ? [...categories] : [];
    if (cats?.firstWhereOrNull((e) {
          for (var item in categoriesList) {
            var exist =
                categoriesList.firstWhere((i) => i == e.id, orElse: () => null);
            if (item == e.parent && exist == null) return true;
          }
          return false;
        }) ==
        null) return categories;
    for (var item in categories) {
      var categoryItem = cats?.where((e) => e.parent == item);

      if (categoryItem?.isNotEmpty ?? false) {
        for (var cat in categoryItem!) {
          var exist =
              categories.firstWhere((i) => i == cat.id, orElse: () => null);
          if (exist == null) categoriesList.add(cat.id);
        }
      }
    }
    return getChildCategories(categoriesList as List<String?>);
  }

  @override
  Future<List<Product>?> fetchProductsByCategory(
      {categoryId,
      tagId,
      page = 1,
      minPrice,
      maxPrice,
      orderBy,
      lang,
      order,
      attribute,
      attributeTerm,
      featured,
      onSale,
      listingLocation,
      userId,
      String? include,
      String? search,
      nextCursor}) async {
    try {
      var products = <Product>[];
      if (languageCode != lang) await getLanguage(lang: lang);
      if (cats == null) await getCategories();
      if (productOptions == null) {
        await getProductOptions();
      }
      if (productOptionValues == null) {
        await getProductOptionValues();
      }
      var childs = getChildCategories([categoryId]);
      var filter = '';
      filter = '&id_category=${childs.toString()}';
      filter = filter.replaceAll('[', '');
      filter = filter.replaceAll(']', '');
      if (attributeTerm != null && attributeTerm.isNotEmpty) {
        var attributeId =
            attributeTerm.substring(0, attributeTerm.indexOf(','));
        filter += '&attribute=$attributeId';
      }

      if (onSale ?? false) {
        filter += '&sale=1';
      }
      if (orderBy != null && orderBy == 'date' && !(featured ?? false)) {
        filter += '&date=${order.toUpperCase()}';
      }
      if (kAdvanceConfig['hideOutOfStock']) {
        filter += '&hide_stock=true';
      }
      var display = 'full';
      var limit = '${(page - 1) * apiPageSize},$apiPageSize';
      var response = await prestaApi
          .getAsync('product?display=$display&limit=$limit$filter&lang=$lang');
      if (response is Map) {
        for (var item in response['products']) {
          var productOptionValues =
              item['associations']['product_option_values'];
          if (productOptionValues != null) {
            var attribute = <String?, dynamic>{};
            for (var option in productOptionValues) {
              var opt = productOptionValues!.firstWhereOrNull(
                  (e) => e['id'].toString() == option['id'].toString());
              if (opt != null) {
                var name = productOptions!.firstWhereOrNull((e) =>
                    e['id'].toString() == opt['id_attribute_group'].toString());
                if (name != null) {
                  var val = attribute[getValueByLang(name['name'])] ?? [];
                  val.add(getValueByLang(opt['name']));
                  attribute.update(getValueByLang(name['name']), (value) => val,
                      ifAbsent: () => val);
                }
              }
            }
            item['attributes'] = attribute;
          }
          products.add(Product.fromPresta(item, prestaApi.apiLink));
        }
      } else {
        return [];
      }
      return products;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future createReview(
      {String? productId, Map<String, dynamic>? data, String? token}) async {
    try {} catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  Future<void> getProductOptions() async {
    try {
      productOptions = List<Map<String, dynamic>>.from((await prestaApi
              .getAsync('product_options?display=[id,name,group_type]'))[
          'product_options']);
    } catch (e) {
      productOptions = [];
    }
    return;
  }

  Future<void> getProductOptionValues() async {
    try {
      productOptionValues = List<
          Map<String, dynamic>>.from((await prestaApi.getAsync(
              'product_option_values?display=[id,id_attribute_group,color,name]'))[
          'product_option_values']);
    } catch (e) {
      productOptionValues = [];
    }
    return;
  }

  String? getValueByLang(dynamic values) {
    if (values is! List) return values;
    for (var item in values) {
      if (item['id'].toString() == (idLang ?? '1')) {
        return item['value'];
      }
    }
    return 'Error';
  }

  Future<void> getLanguage({lang = 'en'}) async {
    languageCode = lang;
    var res = await prestaApi.getAsync('languages?display=full');
    for (var item in res['languages']) {
      if (item['iso_code'] == lang.toString()) {
        idLang = item['id'].toString();
        return;
      }
    }
    idLang = res['languages'].length > 0
        ? res['languages'][0]['id'].toString()
        : '1';
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product,
      {String? lang = 'en'}) async {
    try {
      var productVariantions = <ProductVariation>[];
      // var _product = await prestaApi.getAsync('products/${product.id}');
      // List<dynamic> combinations =
      //     _product['product']['associations']['combinations'];
      if (languageCode != lang) await getLanguage(lang: lang);
      if (productOptions == null) await getProductOptions();
      if (productOptionValues == null) await getProductOptionValues();
      var params = 'id_product=${product.id}&display=full';
      if (product.idShop != null && product.idShop!.isNotEmpty) {
        params += '&id_shop_default=${product.idShop}';
      }
      var combinationRes = await prestaApi.getAsync('attribute?$params');

      for (var i = 0; i < (combinationRes?['combinations']?.length ?? 0); i++) {
        var combination = combinationRes['combinations'][i];
        var options = combination['associations']['product_option_values'];
        var attributes = <Map<String, dynamic>>[];
        for (var option in options) {
          var optionValue = productOptionValues!.firstWhereOrNull(
              (element) => element['id'].toString() == option['id'].toString());
          if (optionValue != null) {
            var name = productOptions!.firstWhereOrNull((e) =>
                e['id'].toString() ==
                optionValue['id_attribute_group'].toString())!;
            attributes.add({
              'id': optionValue['id'],
              'name': getValueByLang(name['name']),
              'option': getValueByLang(optionValue['name'])
            });
          }
        }
        combination['attributes'] = attributes;

        combination['image'] = product.imageFeature;
        productVariantions.add(ProductVariation.fromPrestaJson(combination));
      }
      return productVariantions;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    CartModel? cartModel,
    String? token,
    String? checkoutId,
    Store? store,
  }) async {
    var address = cartModel!.address!;
    var lists = <ShippingMethod>[];
    var countries = await prestaApi
        .getAsync('countries?filter[iso_code]=${address.country}&display=full');
    var zone = '1';
    if (countries is Map) {
      zone = countries['countries'][0]['id_zone'] ?? 1 as String;
    }
    var shipping = await prestaApi.getAsync(
        'shipping?$checkoutId&zone=$zone&display=full&id_lang=$idLang');
    for (var item in shipping['carriers']) {
      lists.add(ShippingMethod.fromPrestaJson(item));
    }
    return lists;
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel,
      ShippingMethod? shippingMethod,
      String? token}) async {
    var lists = <PaymentMethod>[];
    var payment = await prestaApi.getAsync('payment?display=full');
    for (var item in payment['taxes']) {
      lists.add(PaymentMethod.fromPrestaJson(item));
    }
    return lists;
  }

  Future<void> getOrderStates() async {
    orderStates = List<Map<String, dynamic>>.from((await prestaApi
        .getAsync('order_states?display=full'))['order_states']);
    return;
  }

  Future<void> getMyOrderAddress(String id) async {
    if (orderAddresses.containsKey(id)) return;
    var response =
        await prestaApi.getAsync('addresses?filter[id]=$id&display=full');
    if (response is Map && response['addresses'].isNotEmpty) {
      orderAddresses.update(id, (value) => response['addresses'][0],
          ifAbsent: () => response['addresses'][0]);
    } else {
      orderAddresses.update(id, (value) => {'firstname': 'Not found'},
          ifAbsent: () => {'firstname': 'Not found'});
    }
    return;
  }

  @override
  Future<PagingResponse<Order>> getMyOrders({
    User? user,
    dynamic cursor,
    String? cartId,
  }) async {
    try {
      var lists = <Order>[];
      if (orderStates == null) await getOrderStates();
      var limit = '${(cursor - 1) * apiPageSize},$apiPageSize';
      var response = await prestaApi.getAsync(
          'orders?sort=[id_DESC]&limit=$limit&filter[id_customer]=${user!.id}&display=full&dummy=${DateTime.now().millisecondsSinceEpoch}');
      //log("Order Data: $response");
      if (response['orders']?.isEmpty ?? true) {
        return const PagingResponse(data: []);
      }
      for (var item in response['orders']) {
        var order = item;
        var status = orderStates!.firstWhereOrNull(
            (e) => e['id'].toString() == item['current_state'].toString());
        if (status != null) {
          order['status'] = getValueByLang(status['name'][0]['value']);
        }
        await getMyOrderAddress(item['id_address_delivery'].toString());
        var address = orderAddresses[item['id_address_delivery'].toString()];
        order['address'] = address;
        lists.add(Order.fromJson(order));
      }
      return PagingResponse(data: lists);
    } catch (e) {
      return const PagingResponse(data: []);
    }
  }

  @override
  Future<Order> createOrder({
    CartModel? cartModel,
    UserModel? user,
    bool? paid,
    String? transactionId,
  }) async {
    try {
      var idCarrier = cartModel!.shippingMethod!.id;
      var idCustomer = user?.user?.id ?? user?.guestUser?.id;
      var idCurrency = await cartModel.getCurrency();
      var address = await createAddress(cartModel, user);
      var idAddressDelivery = address;
      var idAddressInvoice = address;
      var currentState = '1';
      var payment = cartModel.paymentMethod!.title;
      var module = cartModel.paymentMethod!.id;
      var totalShipping = cartModel.shippingMethod!.cost.toString();
      var totalProducts = cartModel.getSubTotal()! < 50
          ? (cartModel.getSubTotal()! +
                  (module == 'ps_cashondelivery' ? 1.5 : 0))
              .toString()
          : cartModel.getSubTotal().toString();
      final products = cartModel.item;
      final productVariationInCart =
          cartModel.productVariationInCart.keys.toList();
      var productsId = <String?>[];
      var attribute = <String>[];
      var productsQuantity = [];
      if (orderStates == null) await getOrderStates();
      for (var key in products.keys.toList()) {
        if (productVariationInCart.toString().contains('$key-')) {
          for (var item in productVariationInCart) {
            if (item.contains('$key-')) {
              productsId.add(key);
              attribute.add(item.replaceAll('$key-', ''));
              productsQuantity.add(cartModel.productsInCart[item]);
            }
          }
        } else {
          productsId.add(key);
          attribute.add('-1');
          productsQuantity.add(cartModel.productsInCart[key!]);
        }
      }
      logger.i('Here you are with id of customer', idCustomer);
      var body = {
        'products': productsId,
        'quantity': productsQuantity,
        'attribute': attribute,
        'id_carrier': idCarrier,
        'id_lang': idLang,
        'id_customer': idCustomer,
        'id_currency': idCurrency,
        'id_address_delivery': idAddressDelivery,
        'id_address_invoice': idAddressInvoice,
        'current_state': currentState,
        'payment': payment,
        'module': module,
        'total_shipping': totalShipping,
        'total_products': totalProducts,
        'notes': cartModel.notes,
      };
      // if (idCustomer == null) {
      //   body['is_guest'] = true;
      //   body['id_default_group'] = 2;
      // }
      var response = await prestaApi.postAsync(
        'order?display=full',
        body: body,
      );
      logger.i(response);
      return Order.fromJson(response['orders'][0]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) async {}

  @override
  Future<PagingResponse<Product>> searchProducts({
    name,
    categoryId = '',
    categoryName,
    tag = '',
    attribute = '',
    attributeId = '',
    required page,
    lang,
    listingLocation,
    userId,
  }) async {
    var products = <Product>[];
    if (cats == null) await getCategories();
    if (languageCode != lang) await getLanguage(lang: lang);
    if (productOptions == null) {
      await getProductOptions();
    }
    if (productOptionValues == null) {
      await getProductOptionValues();
    }
    var filter = '&name=$name';
    if (categoryId != null && categoryId.isNotEmpty) {
      var childs = getChildCategories([categoryId]);
      var idCategory = '&id_category=${childs.toString()}';
      idCategory = idCategory.replaceAll('[', '');
      idCategory = idCategory.replaceAll(']', '');
      filter = filter + idCategory;
    }
    if (attributeId != null && attributeId.isNotEmpty) {
      filter += '&attribute=$attributeId';
    }
    if (kAdvanceConfig['hideOutOfStock']) {
      filter += '&hide_stock=true';
    }
    var display = 'full';
    var limit = '${(page - 1) * apiPageSize},$apiPageSize';
    var response = await prestaApi
        .getAsync('product?display=$display&limit=$limit$filter&lang=$lang');
    if (response is Map) {
      for (var item in response['products']) {
        var productOptionValues = item['associations']['product_option_values'];
        if (productOptionValues != null &&
            productOptionValues is List &&
            productOptionValues.isNotEmpty) {
          var attribute = <String?, dynamic>{};
          for (var option in productOptionValues) {
            var opt = productOptionValues.firstWhereOrNull(
                (e) => e['id'].toString() == option['id'].toString());
            if (opt != null) {
              var name = productOptions!.firstWhereOrNull((e) =>
                  e['id'].toString() == opt['id_attribute_group'].toString());
              if (name != null) {
                var val = attribute[getValueByLang(name['name'])] ?? [];
                val.add(getValueByLang(opt['name']));
                attribute.update(getValueByLang(name['name']), (value) => val,
                    ifAbsent: () => val);
              }
            }
          }
          item['attributes'] = attribute;
        }
        products.add(Product.fromPresta(item, prestaApi.apiLink));
      }
    } else {
      return const PagingResponse(data: <Product>[]);
    }
    return PagingResponse(data: products);
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    printLog('::::request getProduct $id');
    var response = await prestaApi
        .getAsync('product?display=full&limit=5&id_product=$id&lang=$lang');
    logger.d(response);
    return Product.fromPresta(response['products'][0], prestaApi.apiLink);
  }

  /// Auth
  @override
  Future<User?> getUserInfo(cookie) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> updateUserInfo(
      Map<String, dynamic> json, String? token) async {
    return null;
  }

  /// Create a New User
  @override
  Future<User> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
    required bool isGuest,
  }) async {
    try {
      dynamic response;
      if (isGuest) {
        response = await prestaApi.getAsync(
            'register?email=$username&passwd=$password&firstname=$firstName&lastname=$lastName&is_guest=true&id_default_group=2&display=full');
      } else {
        response = await prestaApi.getAsync(
            'register?email=$username&passwd=$password&firstname=$firstName&lastname=$lastName&display=full');
      }

      logger.i(response);

      var user;
      if (response is Map) {
        user = User.fromPrestaJson(response['customers'][0]);
      } else {
        throw ('Email is exist!!!');
      }
      return user;
    } catch (e) {
      printLog(e.toString());
      rethrow;
    }
  }

  /// login
  @override
  Future<User> login({username, password}) async {
    try {
      var response = await prestaApi
          .getAsync('signin?email=$username&passwd=$password&display=full');
      if (response is Map && response['customers'].length == 1) {
        return User.fromPrestaJson(response['customers'][0]);
      } else {
        throw Exception('No match for E-Mail Address and/or Password');
      }
    } catch (err) {
      rethrow;
    }
  }

  //Get list countries
  @override
  Future<dynamic> getCountries() async {
    try {
      var response =
          await prestaApi.getAsync('countries?filter[active]=1&display=full');
      var countries = response['countries'];
      if (countries != null && countries is List) {
        for (var item in countries) {
          item['name'] = getValueByLang(item['name']);
        }
      }
      return countries;
    } catch (err) {
      return [];
    }
  }

  @override
  Future getStatesByCountryId(countryId) async {
    try {
      var response = await prestaApi.getAsync(
          'states?filter[id_country]=$countryId&filter[active]=1&display=full');
      var states = response['states'];
      if (states != null && states is List) {
        for (var item in states) {
          item['name'] = getValueByLang(item['name']);
        }
      }
      return states;
    } catch (err) {
      return [];
    }
  }

  //Get list states
  Future<dynamic> getStates(String? idCountry) async {
    try {
      var response = await prestaApi.getAsync(
          'states?filter[id_country]=$idCountry&filter[active]=1&display=full');
      var states = response['states'];
      if (states != null && states is List) {
        for (var item in states) {
          item['name'] = getValueByLang(item['name']);
        }
      }
      return states;
    } catch (err) {
      return [];
    }
  }

  //Create user address in order
  Future<String> createAddress(CartModel cartModel, UserModel? user) async {
    try {
      var param = '';
      param += 'id_customer=${user?.user?.id ?? user?.guestUser?.id}';
      param += '&country_iso=${cartModel.address!.country}';
      param += '&id_state=${cartModel.address!.state}';
      param += '&firstname=${cartModel.address!.firstName}';
      param += '&lastname=${cartModel.address!.lastName}';
      param += '&email=${cartModel.address!.email}';
      param += '&address=${cartModel.address!.street}';
      param += '&city=${cartModel.address!.city}';
      param += '&postcode=${cartModel.address!.zipCode}';
      param += '&phone=${cartModel.address!.phoneNumber}';
      param += '&company=${cartModel.address!.company}';
      param += '&vat_number=${cartModel.address!.vatNumber}';
      param += '&alias=${cartModel.address!.alias}';
      param += '&display=full';
      var response = await prestaApi.getAsync('address?$param');
      return response['addresses'][0]['id'].toString();
    } catch (err) {
      return '1';
    }
  }

//   back:
// token: 9621e425b9581064b52df2ecf1163709
// alias: aliasa
// firstname: zeeshan
// lastname: ali
// company: company
// vat_number: 7867786786
// address1: jhal
// address2: jhal
// postcode: 34534
// city: fsd
// id_country: 9
// phone: +923075433996
// saveAddress: delivery
// use_same_address: 1
// submitAddress: 1
// confirm-addresses: 1

  //Get order status
  Future<List<Map<String, dynamic>>> getOrderStatus(String? orderId) async {
    var response = await prestaApi
        .getAsync('order_histories?filter[id_order]=$orderId&display=full');
    var orderHistories = <Map<String, dynamic>>[];
    for (var item in response['order_histories']) {
      var history = Map<String, dynamic>.from(item);
      var status = orderStates!.firstWhereOrNull(
          (e) => e['id'].toString() == history['id_order_state'].toString());
      if (status != null) {
        history['status'] = getValueByLang(status['name']);
      }
      orderHistories.add(history);
    }
    orderHistories.sort((a, b) =>
        DateTime.parse(a['date_add']).compareTo(DateTime.parse(b['date_add'])));
    return orderHistories;
  }

  @override
  Future<Coupons> getCoupons({int page = 1, String search = ''}) async {
    try {
      var response =
          await prestaApi.getAsync('cart_rules?filter[active]=1&display=full');
      if (response is Map) {
        return Coupons.getListCouponsPresta(response['cart_rules']);
      }
      return Coupons.getListCouponsPresta([]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getImagesByProductId(String productId) async {
    var response = await prestaApi
        .getAsync('product?display=full&limit=5&id_product=$productId');
    var products = response['products'] as List?;
    if (products?.isNotEmpty ?? false) {
      var product = products?.first;
      var image = product?['id_default_image'] != null
          ? prestaApi.apiLink(
              'images/products/${product['id']}/${product["id_default_image"]}')
          : null;
      if (image != null) {
        return <String>[image];
      }
    }
    return const <String>[];
  }

// @override
// Future<PagingResponse<Blog>> getBlogs(dynamic cursor) async {
//   try {
//     final param = '_embed&page=$cursor';
//     final response =
//         await httpGet('${blogApi!.url}/wp-json/wp/v2/posts?$param'.toUri()!);
//     if (response.statusCode != 200) {
//       return const PagingResponse();
//     }
//     List data = jsonDecode(response.body);
//     return PagingResponse(data: data.map((e) => Blog.fromJson(e)).toList());
//   } on Exception catch (_) {
//     return const PagingResponse();
//   }
// }
}
