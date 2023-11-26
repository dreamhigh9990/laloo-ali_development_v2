import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;

class VivaServices {
  String domain = 'https://accounts.vivapayments.com/connect/token';
  var production_url = 'https://api.vivapayments.com';
  // var sendbox_url = 'https://demo-api.vivapayments.com';

  // Future<String> getAccessToken() async {
  //   try {
  //     final token = base64.encode(latin1.encode(
  //         'q49o1cdz67bkbohxw1i4o234h6n9ke860kouj15cbefe2.apps.vivapayments.com:JUqUz38Rvv9E47M26YR4dY7i30ts7F'));
  //     final authstr = 'Basic ' + token.trim();
  //     var response = await http.post(
  //       domain.toUri(),
  //       body: {'grant_type': 'client_credentials'},
  //       headers: {
  //         'content-type': 'application/x-www-form-urlencoded',
  //         'Authorization': authstr,
  //         'accept': 'application/json'
  //       },
  //     );
  //     print(response.body);
  //     final body = convert.jsonDecode(response.body);
  //     print(body);
  //     if (response.statusCode == 200) {
  //       return body['access_token'];
  //     } else {
  //       throw Exception;
  //     }
  //   } catch (err) {
  //     print('getAccessToken VivaServices => $err');
  //     rethrow;
  //   }
  // }

  Future<String> getAccessToken() async {
    try {
      var response = await http.post(Uri.parse(domain),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          encoding: Encoding.getByName('utf-8'),
          body: {
            'client_id':
                'wo04s41btwgc9j1jk9mgvwqr7xks8klg2a05qltc67or4.apps.vivapayments.com',
            'client_secret': '7sJ3jD9D9wkWhmq86gU0Jqi3u5Mr9Y',
            'grant_type': 'client_credentials'
          });
      final body = convert.jsonDecode(response.body);
      print(body);
      if (response.statusCode == 200) {
        return body['access_token'];
      } else {
        throw body['error_description'];
      }
    } catch (e) {
      print('getAccessToken Error $e');
      rethrow;
    }
  }

  Future<String?> createVivaPayment(transactions, accessToken) async {
    try {
      var response = await http.post(
          Uri.parse('$production_url/checkout/v2/orders'),
          body: convert.jsonEncode(transactions),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        print(body);
        return 'https://www.vivapayments.com/web2?ref=${body['orderCode']}';
      } else {
        return null;
      }
    } catch (err) {
      print('createVivaPayment ::::: => $err');
      rethrow;
    }
  }

  Future<String?> executeVivaPayment(payerId, accessToken) async {
    try {
      print('$production_url/checkout/v2/transactions/$payerId');
      var response = await http.get(
          Uri.parse('$production_url/checkout/v2/transactions/$payerId'),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });
      print('executeVivaPayment executeVivaPayment');
      print(response.body);
      print('executeVivaPayment executeVivaPayment executeVivaPayment');
      final body = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['orderCode'].toString();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
