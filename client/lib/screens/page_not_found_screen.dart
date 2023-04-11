import 'package:beautifood_lite/router/route_path.dart';
import 'package:flutter/material.dart';

class PageNotFoundPath extends AppRoutePath {
  @override
  String getRouteInformation() {
    return '/not-found';
  }
}

class PageNotFoundScreen extends StatelessWidget {
  const PageNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('404 -- Page Not Found'),
      ),
    );
  }
}