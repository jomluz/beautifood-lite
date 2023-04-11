import 'package:beautifood_lite/router/route_path.dart';
import 'package:flutter/material.dart';

class CartPath extends AppRoutePath {
  CartPath();
  @override
  String getRouteInformation() {
    return '/auth';
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}