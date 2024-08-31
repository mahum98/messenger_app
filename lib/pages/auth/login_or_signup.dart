import 'package:flutter/widgets.dart';
import 'package:messenger_app/pages/auth/login_page.dart';
import 'package:messenger_app/pages/auth/signup_page.dart';

bool flag = false;

class LoginOrSignup extends StatefulWidget {
  @override
  State<LoginOrSignup> createState() => LogInOrSignUpState();
}

class LogInOrSignUpState extends State<LoginOrSignup> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return flag
        ? LoginPage(
            refresh: refresh,
          )
        : SignupPage(refresh: refresh);
  }
}
