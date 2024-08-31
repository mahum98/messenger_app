//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/pages/auth/login_or_signup.dart';
import 'package:messenger_app/services/auth.dart';
import 'package:messenger_app/services/firestore_services.dart';

late Function refreshParent;

class SignupPage extends StatefulWidget {
  SignupPage({super.key, required Function refresh}) {
    refreshParent = refresh;
  }
  @override
  State<SignupPage> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  Auth auth = Auth();
  String? errorMessage = "";
  //email controller
  TextEditingController emailController = TextEditingController();
  //pswd controller
  TextEditingController pswdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 200),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary),
              child: TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: emailController,
                decoration: InputDecoration(
                    hintText: "example@gmail.com",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary),
              child: TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: pswdController,
                decoration: InputDecoration(
                    hintText: "password",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
            ),
            SizedBox(height: 10),
            Text("$errorMessage", style: TextStyle(color: Colors.red[700])),
            SizedBox(height: 10),
            TextButton(
                onPressed: (emailController.text.isNotEmpty &&
                        pswdController.text.isNotEmpty)
                    ? () async {
                        print("in system request");
                        try {
                          await auth.createUser(
                              email: emailController.text,
                              password: pswdController.text);
                          //extra functionality (add user email to UserCollection)
                          UsersCollection usersCollection = UsersCollection();
                          String userName = emailController.text;
                          int index = userName.indexOf("@");
                          userName = userName.substring(0, index);
                          usersCollection.addUserEmail(userEmail: userName);
                          //end of extra functionality
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            errorMessage = e.message;
                          });
                        }
                      }
                    : null,
                style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sign In"),
                    ],
                  ),
                )),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? ",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),
                GestureDetector(
                    onTap: () {
                      flag = true;
                      refreshParent();
                    },
                    child: Text("LogIn",
                        style: TextStyle(fontWeight: FontWeight.bold)))
              ],
            )
          ],
        ),
      )),
    );
  }
}
