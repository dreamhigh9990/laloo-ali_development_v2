import 'package:flutter/material.dart';
import '../../widgets/common/webview.dart';

class LinksScreen extends StatefulWidget {
  final List links;
  final String title;
  const LinksScreen({required this.links, required this.title});
  @override
  _LinksScreenState createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   titleSpacing: 0,
      //   centerTitle: true,
      //   title: Text(
      //     widget.title,
      //   ),
      //   leading: _backButton(),
      // ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.title,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: widget.links.length,
            itemBuilder: (c, i) {
              return GestureDetector(
                onTap: () {
                  launchWebView(widget.links[i]['link'],
                      (widget.links[i]['title']), widget.links[i]['webview']);
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 15.0, top: 5, right: 15),
                  child: ListTile(
                    title: Text(
                      widget.links[i]['title'],
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.black54, fontSize: 15),
                    ),
                    tileColor: Colors.grey[300],
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 20, color: Colors.black54),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: const Icon(
          Icons.arrow_back_ios,
          size: 20,
        ));
  }

  Future launchWebView(String url, String title, bool webview) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => WebView(
          url: url,
          title: title,
          // isHtmlTrue: url.contains('laloo-academy') ? false : true,
          isHtmlTrue: !webview,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
