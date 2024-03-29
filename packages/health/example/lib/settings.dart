import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'home.dart';
import 'show_data.dart';
import 'data.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart'; // Пакет для открытия ссылок

class SettingsApp extends StatefulWidget {
  const SettingsApp({Key, key}): super(key: key);

  @override
  _SettingsApp createState() => _SettingsApp();
}

class _SettingsApp extends State {
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
            Text("Настройки",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),),

            Row(
              children: [
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
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => HealthApp(),
                    transitionDuration: Duration(milliseconds: 300),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              },
              child: Text("Google Fit Page", textAlign: TextAlign.center, style: TextStyle(color: Color(
                  0xff000000), fontSize: 16, fontWeight: FontWeight.w700),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffeaddff),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                minimumSize: Size(MediaQuery.of(context).size.width * 0.85, 45),
                maximumSize: Size(MediaQuery.of(context).size.width * 0.85, 45),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                    color: Color(0xffeaddff),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                await canLaunchUrl(
                Uri.parse("market://launch?id=com.google.android.apps.fitness"),
                )
                //if we can launch the url then open the app
                    ? await launchUrl(
                  Uri.parse("market://launch?id=com.google.android.apps.fitness"),
                )
                //if we cannot, then open a link to the playstore so the user downloads the app
                    : await launchUrl(
                Uri.parse(
                "https://play.google.com/store/apps/details?id=com.google.android.apps.fitness"),
                );

              },
              child:Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white, // Цвет контейнера
                  borderRadius: BorderRadius.circular(20), // Радиус углов контейнера
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Цвет тени
                      spreadRadius: 0, // Радиус рассеивания тени
                      blurRadius: 15, // Радиус размытия тени
                      offset: Offset(0, 0), // Смещение тени
                    ),
                  ],
                ),
                child:
                Padding(
                  padding: EdgeInsets.all(10),
                  child:
                    Text(
                      textAlign: TextAlign.center,
                      'Google Fit',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                )
              )

            ),
            SizedBox(height: 20),
            GestureDetector(
                onTap: () async {
                  await canLaunchUrl(
                    Uri.parse("market://launch?id=com.google.android.apps.healthdata"),
                  )
                  //if we can launch the url then open the app
                      ? await launchUrl(
                    Uri.parse("market://launch?id=com.google.android.apps.healthdata"),
                  )
                  //if we cannot, then open a link to the playstore so the user downloads the app
                      : await launchUrl(
                    Uri.parse(
                        "https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata"),
                  );

                },
                child:Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white, // Цвет контейнера
                      borderRadius: BorderRadius.circular(20), // Радиус углов контейнера
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Цвет тени
                          spreadRadius: 0, // Радиус рассеивания тени
                          blurRadius: 15, // Радиус размытия тени
                          offset: Offset(0, 0), // Смещение тени
                        ),
                      ],
                    ),
                    child:
                    Padding(
                      padding: EdgeInsets.all(10),
                      child:
                      Text(
                        textAlign: TextAlign.center,
                        'Health Connect',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    )
                )

            ),
          ],
        )
      ),
    );
  }
}