import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'home.dart';
import 'settings.dart';
import 'package:flutter/material.dart';
import 'package:chart_sparkline/chart_sparkline.dart';


class Data extends StatefulWidget {
  const Data({Key, key}): super(key: key);

  @override
  _Data createState() => _Data();
}

class _Data extends State {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1946B9),
        iconTheme: IconThemeData(
          color: Colors.white, // изменяем цвет иконки бургера на белый
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Данные",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),),

            Row(
              children: [
                IconButton(icon: Icon(Icons.notifications), onPressed: () { }, color: Colors.white,),
                IconButton(icon: Icon(Icons.person), onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => Profile(),
                      transitionDuration: Duration(milliseconds: 200),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ),
                  );
                },
                  color: Colors.white,),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user!.displayName.toString()),
              accountEmail: Text(user!.email.toString()),
              currentAccountPicture: CircleAvatar(
                child: Text(user!.displayName.toString()[0], style: TextStyle(color: Color(
                    0xff1946B9), fontWeight: FontWeight.w800, fontSize: 32),),
                backgroundColor: Colors.white,
              ),
              decoration: BoxDecoration(
                color: Color(0xff1946B9), // Цвет заднего фона
              ),
            ),
            ListTile(
              title: Text('Главная'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Home_page(),
                    transitionDuration: Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Личный кабинет'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Profile(),
                    transitionDuration: Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Данные'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Data(),
                    transitionDuration: Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => SettingsApp(),
                    transitionDuration: Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15,),
              Padding(
                padding: EdgeInsets.only(left:25),
                child: Text("Пульс", style: TextStyle(fontSize: 35, color: Colors.black, fontWeight: FontWeight.w800), ),
              ),
              SizedBox(height: 15,),
              Row(

                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child:
                    Sparkline(
                      data: [60, 45, 65, 76, 45, 87, 67, 54, 34, 76, 87, 56, 43],
                      lineWidth: 5.0,
                      lineColor: Colors.red,
                      lineGradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.red, Colors.yellow],
                      ),
                      fillMode: FillMode.below,
                      fillGradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.red, Colors.yellow],
                      ),
                      useCubicSmoothing: true,
                      cubicSmoothingFactor: 0.2,
                      gridLineLabelPrecision: 2,
                      enableGridLines: true,

                    ),
                  )
                ]
              )
            ],
      ),
    );
  }
}