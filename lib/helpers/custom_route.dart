import 'package:flutter/material.dart';

// <T> indicates generic class
class CustomRouteHelper<T> extends MaterialPageRoute<T> {
  CustomRouteHelper({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  // passes builder and settings to MaterialPageRoute

  // buildTransitions controls how the screen is animated when changing
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // TODO: implement buildTransitions
    // return super
    //     .buildTransitions(context, animation, secondaryAnimation, child);
    // if it is initial route, don't add a transition and just return the widget
    if (settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    // TODO: implement buildTransitions
    // return super
    //     .buildTransition s(context, animation, secondaryAnimation, child);
    // if it is initial route, don't add a transition and just return the widget
    if (route.settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
