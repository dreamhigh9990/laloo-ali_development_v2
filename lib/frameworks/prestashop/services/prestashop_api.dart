import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import '../../../common/constants.dart';

class PrestashopAPI {
  late final String url;
  late final String key;

  PrestashopAPI({required this.url, required this.key});

  String apiLink(String endPoint) {
    if (endPoint.contains('?')) {
      return '$url/api/$endPoint&ws_key=$key&output_format=JSON';
    } else {
      return '$url/api/$endPoint?ws_key=$key&output_format=JSON';
    }
  }

  Future<dynamic> getAsync(String endPoint) async {
    log('==>> End Point Data==>> ${apiLink(endPoint)}');
    var response = await httpGet(Uri.tryParse(apiLink(endPoint))!);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<dynamic> postAsync(String endPoint, {Map? body}) async {
    var response = await httpPost(Uri.tryParse(apiLink(endPoint))!,
        body: body != null ? jsonEncode(body) : null);

    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}




// https://laloo.gr/api/images/categories/product_options?display=[id,name,group_type]&ws_key=X2SHFNYYQKHYMZ46Q8KF3J4K3W5449WT&output_format=JSON