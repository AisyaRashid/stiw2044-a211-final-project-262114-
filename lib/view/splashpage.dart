import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:panebakery/modul/config.dart';
import 'package:panebakery/modul/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'mainpage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late double screenHeight, screenWidth, resWidth;
  @override
  void initState() {
    super.initState();
    checkAndLogin();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/Pane.png'),
              fit: BoxFit.cover)),
    );
  }

  checkAndLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    late User user;
    if (email.length > 1 && password.length > 1) {
      http.post(Uri.parse(MyConfig.server + "/php/login_user.php"),
          body: {"email": email, "password": password}).then((response) {
        if (response.statusCode == 200 && response.body != "failed") {
          final jsonResponse = json.decode(response.body);
          user = User.fromJson(jsonResponse);
          Timer(
              const Duration(seconds: 5),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => MainPage(user: user))));
        } else {
          user = User(
              id: "na",
              name: "na",
              email: "na",
              phone: "na",
              address: "na",
              regdate: "na",
              otp: "na", credit: 'na');
          Timer(
              const Duration(seconds: 5),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => MainPage(user: user))));
        }
      }).timeout(const Duration(seconds: 5));
    } else {
      user = User(
          id: "na",
          name: "na",
          email: "na",
          phone: "na",
          address: "na",
          regdate: "na",
          otp: "na", credit: '');
      Timer(
          const Duration(seconds: 5),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (content) => MainPage(user: user))));
    }
  }
}