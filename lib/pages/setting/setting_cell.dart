import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';

class SettingCell extends StatelessWidget {
  SettingCell({
    Key key, 
    this.title, 
    this.leftIcon = const Opacity(child: Icon(Icons.remove),opacity: 0,),
    this.onPress,
    this.tail = const Icon(Icons.keyboard_arrow_right, size: 30,),
    this.subTitle
  }) : super(key: key);
  final String title;
  final String subTitle;
  final Widget leftIcon;
  final Function onPress;
  final Widget tail;

  @override
  Widget build(BuildContext context) {
    Widget cont;
    if (subTitle != null) {
      cont = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 15)),
          Text(subTitle, style: TextStyle(fontSize: 12),)
        ],
      );
    } else {
      cont = Text(title, style: TextStyle(fontSize: 15));
    }

    return InkWell(
      onTap: () => onPress(),
      child: Column(
        children: <Widget>[
          Ink(
            color: MyColor.widgetDefaultColor,
            height: subTitle == null ? 50 : 55,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                    leftIcon,
                    SizedBox(width: 10),
                    cont,
              Spacer(),
                tail
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 50),
            child: Divider(height: 1.0, color: MyColor.dividerLineColor),
          )
        ],
      ),
    );
  }
}
