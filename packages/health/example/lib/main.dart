import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'show_data.dart';
import 'firebase_options.dart';
import 'color_schemes.dart';
import 'welcome.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MaterialApp(home: StartApp()));
}


class StartApp extends StatefulWidget {
  const StartApp({Key, key}): super(key: key);

  @override
  _StartApp createState() => _StartApp();
}

class _StartApp extends State {
  void check(context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Home_page(),
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    }
    else {
      Navigator.pushReplacement(context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => MyApp(),
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      check(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}
