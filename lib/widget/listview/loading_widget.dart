import 'package:fastodon/widget/common/loading_view.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({Key key, this.childWidget, this.endLoading}) : super(key: key);
  final Widget childWidget;
  final bool endLoading;

  @override
  Widget build(BuildContext context) { 
    if (endLoading == false) {
      return LoadingView();
    } else {
      return childWidget;
    }
  }
}
