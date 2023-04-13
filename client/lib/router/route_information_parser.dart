import 'package:beautifood_lite/router/route_path.dart';
import 'package:beautifood_lite/screens/auth_screen.dart';
import 'package:beautifood_lite/screens/cart_screen.dart';
import 'package:beautifood_lite/screens/home_screen.dart';
import 'package:beautifood_lite/screens/menu_item_screen.dart';
import 'package:beautifood_lite/screens/shop_screen.dart';
import 'package:beautifood_lite/screens/page_not_found_screen.dart';
import 'package:flutter/material.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.isEmpty) {
      return HomePath();
    } else if(uri.pathSegments.length == 1) {
      final first = uri.pathSegments[0].toLowerCase();
      switch (first) {
        case 'auth':
          return AuthPath();
        case 'cart':
         return CartPath();
        default:
      }
    } else if (uri.pathSegments.length == 2) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1].toLowerCase();
      if (first == 'shop') {
        return ShopPath(second, uri.queryParameters['tableNo'],
            uri.queryParameters['sessionId']);
      // } else if (first == 'emailverification') {
      //   return EmailVerificationPath(uri.pathSegments[1]);
      // } else if (first == 'passwordreset') {
      //   return PasswordResetPath(uri.pathSegments[1]);
      }
    } else if (uri.pathSegments.length == 3) {
      final first = uri.pathSegments[0].toLowerCase();
      final second = uri.pathSegments[1].toLowerCase();
      final third = uri.pathSegments[2].toLowerCase();
      if (first == 'shop' && second.length == 24 && third.length == 24) {
        return MenuItemPath(second, third);
      }
    }
    return PageNotFoundPath();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(location: configuration.getRouteInformation());
  }
}
