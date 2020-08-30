import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/public.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    Key key,
    Widget leading,
    bool automaticallyImplyLeading = true,
    Widget title,
    List<Widget> actions,
    Widget flexibleSpace,
    PreferredSizeWidget bottom,
    double elevation,
    Color shadowColor,
    ShapeBorder shape,
    Color backgroundColor,
    Brightness brightness,
    IconThemeData iconTheme,
    IconThemeData actionsIconTheme,
    TextTheme textTheme,
    bool primary = true,
    bool centerTitle = true,
    bool excludeHeaderSemantics = false,
    double titleSpacing = NavigationToolbar.kMiddleSpacing,
    double toolbarOpacity = 1.0,
    double bottomOpacity = 1.0,
    double toolbarHeight = 45,
  }) : super(
          key: key,
          leading :leading == null ? InkWell(
            onTap: () => AppNavigate.pop(),
            child: Icon(IconFont.back,size: 28,),
          ) : leading,
          automaticallyImplyLeading:automaticallyImplyLeading,
          title: title,
          actions:actions,
          flexibleSpace:flexibleSpace,
          bottom:bottom,
          elevation:elevation,
          shadowColor:shadowColor,
          shape:shape,
          backgroundColor:backgroundColor,
          brightness:brightness,
          iconTheme:iconTheme,
          actionsIconTheme:actionsIconTheme,
          textTheme:textTheme,
          primary:primary,
          centerTitle:centerTitle,
          excludeHeaderSemantics:excludeHeaderSemantics,
          titleSpacing :titleSpacing,
          toolbarOpacity:toolbarOpacity,
          bottomOpacity :bottomOpacity,
          toolbarHeight :toolbarHeight,
        );


}
