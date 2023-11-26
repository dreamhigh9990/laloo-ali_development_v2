import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/index.dart' show AppModel, CartModel;
import 'services.dart';

class VivaPayment extends StatefulWidget {
  final Function onFinish;

  const VivaPayment({required this.onFinish});

  @override
  _VivaPaymentState createState() => _VivaPaymentState();
}

class _VivaPaymentState extends State<VivaPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? checkoutUrl;
  String? executeUrl;
  String? accessToken;
  VivaServices services = VivaServices();

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();

        final transactions = getOrderParams();
        final res = await services.createVivaPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res;
            controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onProgress: (int progress) {
                    // Update loading bar.
                  },
                  onPageStarted: (String url) {},
                  onPageFinished: (String url) {},
                  onWebResourceError: (WebResourceError error) {},
                  onNavigationRequest: (NavigationRequest request) {
                    // if (request.url.startsWith('http://return.example.com')) {
                    //   final uri = Uri.parse(request.url);
                    //   final payerID = uri.queryParameters['PayerID'];
                    //   if (payerID != null) {
                    //     services
                    //         .executePayment(executeUrl, payerID, accessToken)
                    //         .then((id) {
                    //       widget.onFinish!(id);
                    //     });
                    //   }
                    //   Navigator.of(context).pop();
                    // }
                    // if (request.url.startsWith('http://cancel.example.com')) {
                    //   Navigator.of(context).pop();
                    // }
                    // return NavigationDecision.navigate;
                    final uri = Uri.parse(request.url);
                    print(uri.queryParameters);
                    print(request.url);
                    if (request.url.startsWith(
                        'https://laloo.gr/module/vivapay/validation')) {
                      final uri = Uri.parse(request.url);
                      final payerID = uri.queryParameters['t'];
                      if (payerID != null) {
                        services
                            .executeVivaPayment(payerID, accessToken)
                            .then((id) {
                          widget.onFinish(id);
                        });
                      }
                      Navigator.of(context).pop();
                    }
                    if (request.url
                        .startsWith('https://laloo.gr/module/vivapay/fail')) {
                      widget.onFinish(null);
                      Navigator.of(context).pop();
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              )
              ..loadRequest(Uri.parse(checkoutUrl.toString()));
          });
        }
      } catch (e) {
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        // ignore: deprecated_member_use
        _scaffoldKey.currentState != null
            ? ScaffoldMessenger.of(context).showSnackBar(snackBar)
            : throw (e);
      }
    });
  }

  Map<String, dynamic> getOrderParams() {
    var cartModel = Provider.of<CartModel>(context, listen: false);
    var appModel = Provider.of<AppModel>(context, listen: false);

    // return {
    //   'amount': cartModel.getTotal(),
    //   'customerTrns': 'The payment transaction description.',
    //   'customer': {
    //     'email': cartModel.address.email,
    //     'fullName':
    //         '${cartModel.address.firstName} ${cartModel.address.lastName}',
    //     'phone': cartModel.address.phoneNumber ?? '',
    //     'countryCode': cartModel.address.country,
    //     'requestLang': appModel.langCode
    //   },
    //   'paymentTimeout': 300,
    //   'preauth': false,
    //   'allowRecurring': false,
    //   'maxInstallments': 0,
    //   'paymentNotification': true,
    //   'tipAmount': 0,
    //   'disableExactAmount': false,
    //   'disableCash': true,
    //   'disableWallet': false,
    //   'sourceCode': '2364',
    //   'merchantTrns': 'The payment transaction description.',
    //   'tags': ['']
    // };
    return {
      'amount': cartModel.getTotal()! * 100,
      'customerTrns':
          'Short description of purchased items/services to display to your customer',
      'customer': {
        'email': cartModel.address!.email,
        'fullName':
            '${cartModel.address!.firstName} ${cartModel.address!.lastName}',
        'phone': cartModel.address!.phoneNumber ?? '',
        'countryCode': cartModel.address!.country ?? '',
        'requestLang': appModel.langCode
      },
      'paymentTimeout': 300,
      'preauth': false,
      'allowRecurring': false,
      'maxInstallments': 0,
      'paymentNotification': true,
      'disableExactAmount': false,
      'disableCash': true,
      'disableWallet': true,
      // 'sourceCode': '9059',
      'sourceCode': '8010',
      'merchantTrns':
          'Short description of items/services purchased by customer',
      'tags': []
    };
  }

  @override
  Widget build(BuildContext context) {
    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: GestureDetector(
            onTap: () {
              widget.onFinish(null);
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        // body: WebView(
        //   initialUrl: checkoutUrl,
        //   javascriptMode: JavascriptMode.unrestricted,
        //   navigationDelegate: (NavigationRequest request) {
        //     final uri = Uri.parse(request.url);
        //     print(uri.queryParameters);
        //     print(request.url);
        //     if (request.url
        //         .startsWith('https://laloo.gr/module/vivapay/validation')) {
        //       final uri = Uri.parse(request.url);
        //       final payerID = uri.queryParameters['t'];
        //       if (payerID != null) {
        //         services.executeVivaPayment(payerID, accessToken).then((id) {
        //           widget.onFinish(id);
        //         });
        //       }
        //       Navigator.of(context).pop();
        //     }
        //     if (request.url
        //         .startsWith('https://laloo.gr/module/vivapay/fail')) {
        //       widget.onFinish(null);
        //       Navigator.of(context).pop();
        //     }
        //     return NavigationDecision.navigate;
        //   },
        // ),
        body: WebViewWidget(
          controller: controller,
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onFinish(null);
              Navigator.of(context).pop();
            }),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      body: Container(child: kLoadingWidget(context)),
    );
  }
}
