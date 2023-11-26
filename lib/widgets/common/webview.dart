import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' as htmlv2;
import 'package:html/dom.dart' as dom;
import '../html/index.dart';

class WebView extends StatefulWidget {
  final String? url;
  final String? title;
  final AppBar? appBar;
  final bool enableForward;
  final bool isHtmlTrue;
  const WebView(
      {Key? key,
      this.title,
      required this.url,
      this.appBar,
      this.enableForward = false,
      this.isHtmlTrue = false})
      : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  bool isLoading = true;
  String html = '';

  late final WebViewController controller;

  @override
  void initState() {
    getHtmlText();
    // fetchAndParseHTML();
    // if (widget.isHtmlTrue) {
    //   httpGet(Uri.parse(widget.url.toString())).then((response) {
    //     print(response.runtimeType);
    //     setState(() {
    //       html = response.body;
    //     });
    //   });
    // }

    // if (isAndroid) WebView.platform = SurfaceAsndroidWebView();

    super.initState();
    setState(() {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {
              controller.runJavaScript(
                  "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
              controller.runJavaScript(
                  "document.getElementsByTagName('footer')[0].style.display='none'");

              controller.runJavaScript(
                  "document.getElementById('more-info').style.display='none';");
            },
            onPageFinished: (String url) {
              controller.runJavaScript(
                  "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
              controller.runJavaScript(
                  "document.getElementsByTagName('footer')[0].style.display='none'");

              controller.runJavaScript(
                  "document.getElementById('more-info').style.display='none';");
            },
            onWebResourceError: (WebResourceError error) {},
          ),
        )
        ..loadRequest(Uri.parse(widget.url!));
    });
  }

  void getHtmlText() async {
    try {
      var res = await http.get(Uri.parse(widget.url!));
      logger.i(res.body);
      var decode = json.decode(utf8.decode(res.bodyBytes));
      logger.i(decode);
      if (mounted) {
        setState(() {
          html = decode[0]['html'];
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> fetchAndParseHTML() async {
    final url =
        Uri.parse(widget.url!); // Replace with the URL you want to fetch

    try {
      final response = await http.get(url);
      logger.i(response.body);
      if (response.statusCode == 200) {
        final document = htmlv2.parse(response.body);

        // Extract the content of the <head> section
        final headElement = document.querySelector('head');
        if (headElement != null) {
          // Now you can further process the <head> section or its children elements.
          // For example, to extract the page title:
          final titleElement = headElement.querySelector('title');
          final title = titleElement?.text ?? 'No title found';

          logger.i('Title: $title');
        }
      } else {
        print('Failed to load page: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHtmlTrue) {
      return Scaffold(
        appBar: widget.appBar ??
            AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              elevation: 0.0,
              title: Text(
                widget.title ?? '',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: HtmlWidget(html),
        ),
      );
    }

    // /// is Mobile or Web
    // if (!kIsWeb && (kAdvanceConfig['inAppWebView'] ?? false)) {
    //   return WebViewInApp(url: widget.url!, title: widget.title);
    // }

    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0.0,
            title: Text(
              widget.title ?? '',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
            // leadingWidth: 150,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                var value = await controller.canGoBack();
                if (value) {
                  await controller.goBack();
                } else if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  // Tools.showSnackBar(Scaffold.of(buildContext),
                  //     S.of(context).noBackHistoryItem);
                }
              },
            ),
            // leading: Builder(builder: (buildContext) {
            //   return Row(
            //     children: [
            //       IconButton(
            //         icon: const Icon(Icons.arrow_back_ios),
            //         onPressed: () async {
            //           var value = await _controller.canGoBack();
            //           if (value) {
            //             await _controller.goBack();
            //           } else if (Navigator.canPop(context)) {
            //             Navigator.of(context).pop();
            //           } else {
            //             Tools.showSnackBar(Scaffold.of(buildContext),
            //                 S.of(context).noBackHistoryItem);
            //           }
            //         },
            //       ),
            //       if (widget.enableForward)
            //         IconButton(
            //           onPressed: () async {
            //             if (await _controller.canGoForward()) {
            //               await _controller.goForward();
            //             } else {
            //               Tools.showSnackBar(Scaffold.of(buildContext),
            //                   S.of(context).noForwardHistoryItem);
            //             }
            //           },
            //           icon: const Icon(Icons.arrow_forward_ios),
            //         ),
            //     ],
            //   );
            // }),
          ),
      body: Builder(builder: (BuildContext context) {
        return WebViewWidget(controller: controller);
      }),
    );
  }
}
