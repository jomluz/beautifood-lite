import 'package:beautifood_lite/providers/auth.dart';
import 'package:beautifood_lite/router/route_path.dart';
import 'package:beautifood_lite/theme/colors.dart';
import 'package:beautifood_lite/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPath extends AppRoutePath {
  AuthPath();
  @override
  String getRouteInformation() {
    return '/auth';
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Consumer<Auth>(builder: (context, auth, _) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: deviceSize.height * 0.1,
                width: double.maxFinite,
              ),
              Hero(
                tag: 'hero',
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: deviceSize.height * 0.12,
                  child: Image.asset(
                      'assets/beautifood-logo.png'), //Image.asset('assets/logo.jpg'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Beautifood~~',
                  style:
                      TextStyle(color: ThemeColors.primarySwatch, fontSize: 24),
                ),
              ),
              SizedBox(
                height: deviceSize.height * 0.07,
              ),
              (auth.isAuth)
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account',
                          ),
                          Text(
                            auth.account!,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                'Chain: ',
                              ),
                              Text(
                                auth.networkName!,
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ))
                  : ElevatedButton(
                      onPressed: () async {
                        try {
                          await auth.login(context);
                        } catch (e) {
                          showErrorDialog(e.toString(), context);
                        }
                      },
                      child: const Text("Connect with Metamask"),
                    ),
            ],
          ),
        );
      }),
    );
  }
}
