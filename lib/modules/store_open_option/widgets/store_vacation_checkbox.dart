import 'package:flutter/material.dart';

import '../../../common/font_family.dart';

class StoreVacationCheckbox extends StatefulWidget {
  final onCallBack;
  final String title;
  final bool value;
  const StoreVacationCheckbox(
      {Key? key,
      required this.onCallBack,
      required this.title,
      required this.value})
      : super(key: key);

  @override
  _StoreVacationCheckboxState createState() => _StoreVacationCheckboxState();
}

class _StoreVacationCheckboxState extends State<StoreVacationCheckbox> {
  bool? value;

  void _update() {
    value = !value!;
    setState(() {});
    widget.onCallBack(value);
  }

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final titleTheme = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.pFCenturyRegular,
        );
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: titleTheme,
          ),
        ),
        Checkbox(
          value: value,
          onChanged: (val) {
            _update();
          },
        ),
      ],
    );
  }
}
