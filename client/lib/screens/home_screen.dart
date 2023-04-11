import 'package:beautifood_lite/router/route_path.dart';
import 'package:beautifood_lite/theme/colors.dart';
import 'package:flutter/material.dart';

class HomePath extends AppRoutePath {
  @override
  String getRouteInformation() {
    return '/';
  }
}

class HomeScreen extends StatefulWidget {
  final Function(String) goToShop;
  const HomeScreen({Key? key, required this.goToShop}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _shopIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
        title: const Text(
          'Beautifood Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Shop Id'),
              controller: _shopIdController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                widget.goToShop(_shopIdController.text);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeColors.primarySwatch,
                side: const BorderSide(
                  width: 2.0,
                  color: ThemeColors.primarySwatch,
                ),
                shape: const StadiumBorder(),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: ThemeColors.primarySwatch,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
