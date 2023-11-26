import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants.dart';
import '../../services/index.dart';

class PreviewReload extends StatefulWidget {
  final bool isDynamic;
  final String? previewKey;
  final Map<String, dynamic>? configs;
  final builder;

  const PreviewReload({
    this.configs,
    this.isDynamic = false,
    this.previewKey,
    required this.builder,
  }) : assert(builder != null);

  @override
  _PreviewReloadState createState() => _PreviewReloadState();
}

class _PreviewReloadState extends State<PreviewReload> {
  late Map<String, dynamic> configs;
  String fontSettings = 'Disabled';
  late SharedPreferences preferences;
  @override
  void initState() {
    /// init listener preview configs
    eventBus.on<EventReloadConfigs>().listen((event) {
      if (event.key != null) {
        if (event.key == widget.previewKey && widget.isDynamic) {
          setState(() {
            configs = event.configs;
          });
        }
      } else if (!widget.isDynamic) {
        setState(() {
          configs = event.configs;
        });
      }
    });
    configs = widget.configs ?? {};
    super.initState();
    init();
  }

  // ignore: always_declare_return_types
  init() async {
    preferences = await SharedPreferences.getInstance();
    var fontSetting = preferences.getString('fontSetting');
    if (fontSetting == null) {
      await preferences.setString('fontSetting', 'Disabled');
    } else {
      setState(() {
        fontSettings = fontSetting;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return fontSettings == 'Disabled'
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Container(
              child: widget.builder(
                Config().isBuilder ? configs : widget.configs,
              ),
            ),
          )
        : Container(
            child: widget.builder(
              Config().isBuilder ? configs : widget.configs,
            ),
          );
  }
}
