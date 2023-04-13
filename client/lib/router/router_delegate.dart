import 'package:beautifood_lite/providers/auth.dart';
import 'package:beautifood_lite/providers/shop.dart';
import 'package:beautifood_lite/router/app_state.dart';
import 'package:beautifood_lite/router/fade_animation.dart';
import 'package:beautifood_lite/router/route_path.dart';
import 'package:beautifood_lite/screens/auth_screen.dart';
import 'package:beautifood_lite/screens/cart_screen.dart';
import 'package:beautifood_lite/screens/home_screen.dart';
import 'package:beautifood_lite/screens/menu_item_screen.dart';
import 'package:beautifood_lite/screens/shop_screen.dart';
import 'package:beautifood_lite/screens/page_not_found_screen.dart';
import 'package:flutter/material.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final Auth _authService;
  final Shop _shopService;
  final AppState _appState = AppState();
  bool? autoLoginResult;
  // String? _emailVerificationToken;
  // String? _passwordResetToken;
  bool _showPageNotFound = false;

  AppRouterDelegate(this._authService, this._shopService)
      : navigatorKey = GlobalKey<NavigatorState>() {
    _authService.addListener(notifyListeners);
    _shopService.addListener(notifyListeners);
    // addListener(shop.notifyListeners);
    _appState.addListener(notifyListeners);
    if (autoLoginResult == null) {
      _authService.tryAutoLogin().then((value) {
        autoLoginResult = value;
        notifyListeners();
      });
    }
  }

  @override
  AppRoutePath? get currentConfiguration {
    // if (_emailVerificationToken != null) {
    //   return EmailVerificationPath(_emailVerificationToken!);
    // } else if (_passwordResetToken != null) {
    //   return PasswordResetPath(_passwordResetToken!);
    // }
    if (!_authService.isAuth) {
      return AuthPath();
    } else if (_appState.isShowCart) {
      return CartPath();
    } else if (_shopService.selectedShopId == null) {
      return HomePath();
    } else if (_shopService.selectedShopId != null &&
        _shopService.selectedMenuItemId == null) {
      return ShopPath(
          _shopService.selectedShopId!, null, _shopService.orderSessionId);
    } else if (_shopService.selectedShopId != null &&
        _shopService.selectedMenuItemId != null) {
      return MenuItemPath(
          _shopService.selectedShopId!, _shopService.selectedMenuItemId!);
    } else if (_showPageNotFound == true) {
      return PageNotFoundPath();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<Page> stack;
    if (!_authService.isAuth) {
      stack = [
        const MaterialPage(
          child: AuthScreen(),
          key: ValueKey('AuthPage'),
        ),
      ];
      // } else if (_emailVerificationToken != null) {
      //   stack = [
      //     MaterialPage(
      //       child: BPEmailTokenVerificationScreen(
      //           tokenFromEmail: _emailVerificationToken!),
      //       key: const ValueKey('EmailVerificationPage'),
      //     ),
      //   ];
      // } else if (_passwordResetToken != null) {
      //   stack = [
      //     MaterialPage(
      //       child: BPResetPasswordScreen(tokenFromEmail: _passwordResetToken!),
      //       key: const ValueKey('PasswordResetPage'),
      //     ),
      //   ];
    } else if (_showPageNotFound) {
      stack = [
        const MaterialPage(
          key: ValueKey('PageNotFoundPage'),
          child: PageNotFoundScreen(),
        )
      ];
    } else {
      stack = [
        if (_shopService.selectedShopId == null)
          FadeAnimationPage(
            key: const ValueKey('HomeScreen'),
            child: HomeScreen(
              goToShop: (p0) {
                _shopService.selectedShopId = p0;
                // notifyListeners();
              },
            ),
          ),
        if (_shopService.selectedShopId != null)
          FadeAnimationPage(
            key: ValueKey(_shopService.selectedShopId!),
            child: ShopScreen(
              id: _shopService.selectedShopId!,
              onSelectMenuItem: (p0) {
                _shopService.selectedMenuItemId = p0;
                // notifyListeners();
              },
              onShowCart: () {
                _appState.isShowCart = true;
              },
            ),
          ),
        if (_shopService.selectedMenuItemId != null)
          FadeAnimationPage(
            key: ValueKey(_shopService.selectedMenuItemId),
            child: MenuItemScreen(
              shopId: _shopService.selectedShopId!,
              menuItemId: _shopService.selectedMenuItemId!,
              goBackToMenu: () {
                _shopService.selectedMenuItemId = null;
              },
            ),
          ),
        if (_appState.isShowCart)
          const MaterialPage(
            child: CartScreen(),
            key: ValueKey('CartPage'),
          ),
      ];
    }
    return Navigator(
      key: navigatorKey,
      pages: stack,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (_appState.isShowCart) {
          _appState.isShowCart = false;
        } else if (_shopService.selectedMenuItemId != null) {
          _shopService.selectedMenuItemId = null;
        } else if (_shopService.selectedShopId != null) {
          _shopService.selectedShopId = null;
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    if (configuration is ShopPath) {
      if (_shopService.selectedShopId != configuration.id) {
        _shopService.clear();
        _shopService.selectedShopId = configuration.id;
      }
      if (configuration.sessionId != null &&
          _shopService.orderSessionId == null) {
        _shopService.orderSessionId = configuration.sessionId;
      } else if (configuration.tableNo != null) {
        // if (orders.ordersSubscription == null) {
        //   orders.tableNumber = configuration.tableNo;
        // } else if (orders.currentOrder?.tableNumber != configuration.tableNo) {
        //   orders.clear();
        //   orders.tableNumber = configuration.tableNo;
        // }
      }
    }
    if (configuration is MenuItemPath) {
      _shopService.selectedShopId = configuration.shopId;
      _shopService.selectedMenuItemId = configuration.menuItemId;
    }
    if (configuration is HomePath) {
      _shopService.selectedShopId = null;
      _shopService.selectedMenuItemId = null;
      _shopService.clear();
    }
    if (configuration is AuthPath) {
      _shopService.selectedShopId = null;
      _shopService.selectedMenuItemId = null;
      _shopService.clear();
    }
    // if (configuration is EmailVerificationPath) {
    //   _emailVerificationToken = configuration.token;
    //   return;
    // } else if (configuration is PasswordResetPath) {
    //   _passwordResetToken = configuration.token;
    //   return;
    // } else {
    //   _emailVerificationToken = null;
    //   _passwordResetToken = null;
    // }
    if (configuration is PageNotFoundPath) {
      _showPageNotFound = true;
      return;
    } else {
      _showPageNotFound = false;
    }
  }
}
