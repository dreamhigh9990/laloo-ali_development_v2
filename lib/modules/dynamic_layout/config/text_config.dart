import 'package:flutter/material.dart';
import '../../../common/font_family.dart';
import '../helper/helper.dart';

class TextConfig {
  String text = '';
  String fontFamily = FontFamily.pFCenturyRegular;
  double fontSize = 20.0;
  String color = '#3FC1BE';
  bool enableShadow = false;

  Alignment alignment = Alignment.topCenter;
  TextConfig({
    this.text = '',
    this.fontFamily = FontFamily.pFCenturyRegular,
    this.fontSize = 20.0,
    this.color = '#3FC1BE',
    this.alignment = Alignment.topCenter,
    this.enableShadow = false,
  });

  TextConfig.fromJson(Map<String, dynamic> json) {
    text = json['text'] ?? '';
    fontFamily = json['fontFamily'] ?? FontFamily.pFCenturyRegular;
    fontSize = Helper.formatDouble(json['fontSize']) ?? 20.0;
    color = json['color'] ?? '#3FC1BE';
    alignment = Alignment(Helper.formatDouble(json['x']) ?? 0.0,
        Helper.formatDouble(json['y']) ?? 0.0);
    enableShadow = json['enableShadow'] ?? false;
  }
}
