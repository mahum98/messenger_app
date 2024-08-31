import 'package:flutter/material.dart';
import 'package:messenger_app/pages/auth/login_or_signup.dart';
import 'package:messenger_app/pages/home_page.dart';
import 'package:messenger_app/services/auth.dart';

// ignore: must_be_immutable
class WidgetTree extends StatelessWidget {
  Auth auth = Auth();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: auth.GetAuthStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginOrSignup();
          }
        });
  }
}
