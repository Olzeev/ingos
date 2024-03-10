import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'settings.dart';
import 'show_data.dart';
import 'data.dart';


class Home_page extends StatefulWidget {
  const Home_page({Key, key}): super(key: key);

  @override
  _Home_page createState() => _Home_page();
}

class _Home_page extends State {
  final user = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ингосздрав"),
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.notifications), onPressed: () { },),
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
                    },),
                  ],
                ),
              ],
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfffeeeff),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Color(0xffcac4d0),
                    width: 2.0,
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 85,
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    CircleAvatar(
                      radius: 22.0,
                      backgroundColor: Color(0xff6750a4),
                      child: Text(
                        'Ш',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Шаги", style: TextStyle(color: Colors.black, fontSize:16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 5),
                        Text("12345", style: TextStyle(color: Colors.black, fontSize:15, fontWeight: FontWeight.w500)),
                      ],
                    )
                  ],
                )
              ),
              SizedBox(height: 20,),
              Container(
                  decoration: BoxDecoration(
                    color: Color(0xfffeeeff),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Color(0xffcac4d0),
                      width: 2.0,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 85,
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 22.0,
                        backgroundColor: Color(0xff6750a4),
                        child: Text(
                          'П',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Пульс", style: TextStyle(color: Colors.black, fontSize:16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 5),
                          Text("80", style: TextStyle(color: Colors.black, fontSize:15, fontWeight: FontWeight.w500)),
                        ],
                      )
                    ],
                  )
              ),
              SizedBox(height: 20,),
              Container(
                  decoration: BoxDecoration(
                    color: Color(0xfffeeeff),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Color(0xffcac4d0),
                      width: 2.0,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 85,
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 22.0,
                        backgroundColor: Color(0xff6750a4),
                        child: Text(
                          'К',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Качество сна", style: TextStyle(color: Colors.black, fontSize:16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 5),
                          Text("60%", style: TextStyle(color: Colors.black, fontSize:15, fontWeight: FontWeight.w500)),
                        ],
                      )
                    ],
                  )
              )
            ],
          )
          ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user!.displayName.toString()),
              accountEmail: Text(user!.email.toString()),
              currentAccountPicture: CircleAvatar(
                child: Text(user!.displayName.toString()[0], style: TextStyle(color: Color(
                    0xff092360), fontWeight: FontWeight.w800, fontSize: 32),),
                backgroundColor: Colors.white,
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
    );
  }
}