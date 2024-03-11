import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  double linePulsePosition = 0.0;
  List<double> data_pulse = [50, 65, 76, 45, 87, 67, 120, 34, 76, 87, 56, 43];
  List<DateTime> date_pulse = [
    DateTime(2024, 3, 11, 12, 25),
    DateTime(2024, 3, 11, 13, 12),
    DateTime(2024, 3, 11, 14, 32),
    DateTime(2024, 3, 11, 15, 54),
    DateTime(2024, 3, 11, 16, 25),
    DateTime(2024, 3, 11, 17, 23),
    DateTime(2024, 3, 11, 18, 25),
    DateTime(2024, 3, 11, 19, 54),
    DateTime(2024, 3, 11, 20, 23),
    DateTime(2024, 3, 11, 21, 25),
    DateTime(2024, 3, 11, 22, 25),
    DateTime(2024, 3, 11, 23, 25),
  ];
  List<String> text_pulse = [" ", " ", " "];

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
      body: ListView(

            children: [
              SizedBox(height: 15,),
              Padding(
                padding: EdgeInsets.only(left:25),
                child: Text("Пульс", style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold), ),
              ),
              SizedBox(height: 15,),
              Row(

                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child:
                        Column(
                          children: [
                            GestureDetector(
                              onTapDown: (details){
                                setState(() {
                                  // Позиция линии будет устанавливаться на середину контейнера по оси X
                                  double cont_size = MediaQuery.of(context).size.width * 0.9 - 15;
                                  double delta = (cont_size / (data_pulse.length - 1));
                                  linePulsePosition = ((details.localPosition.dx / cont_size * (data_pulse.length - 1)).round() * delta).toDouble();
                                  int ind = (details.localPosition.dx / cont_size * (data_pulse.length - 1)).round();
                                  text_pulse = [
                                    data_pulse[ind].toInt().toString(),
                                    date_pulse[ind].day.toString().padLeft(2, '0') + '.' + date_pulse[ind].month.toString().padLeft(2, '0'),
                                    date_pulse[ind].hour.toString() + ':' + date_pulse[ind].minute.toString().padLeft(2, '0')
                                  ];
                                });
                              },
                              child:
                                Stack(
                                  children: [
                                    Sparkline(
                                      data: data_pulse,
                                      lineWidth: 3.0,
                                      lineColor: Color(0xffff6666),

                                      fillMode: FillMode.below,
                                      fillGradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Color(0x96eb4034),
                                          Color(0x96ffffff)],
                                      ),
                                      //useCubicSmoothing: true,
                                      //cubicSmoothingFactor: 0.1,
                                      //gridLineLabelPrecision: 3,
                                      enableGridLines: true,

                                    ),

                                    AnimatedPositioned(
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      left: linePulsePosition,

                                      top: 0,
                                      bottom: 0,
                                      child:
                                      Container(
                                        width: 2,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ]
                                ),

                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 60,
                              child:
                                Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        left: linePulsePosition - 34,
                                        top: 0,
                                        child:
                                            Column(
                                            children: [
                                              Text(
                                                  text_pulse[0].toString() + ' уд/мин',
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold ,

                                                  )
                                              ),
                                              Text(
                                                  text_pulse[1],
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.bold,
                                                      height: 1.5,
                                                  )
                                              ),
                                              Text(
                                                  text_pulse[2],
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  )
                                              )
                                            ],
                                            )

                                      ),
                                    ]
                                ),

                            ),

                          ]
                        )
                  )
                ]
              ),
              SizedBox(height: 15,),
              Padding(
                padding: EdgeInsets.only(left:25),
                child: Text("Шаги", style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold), ),
              ),
              SizedBox(height: 15,),
              Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child:
                        Column(
                            children: [
                              GestureDetector(
                                onTapDown: (details){
                                  setState(() {
                                    double cont_size = MediaQuery.of(context).size.width * 0.9 - 15;
                                    double delta = (cont_size / (data_pulse.length - 1));
                                    linePulsePosition = ((details.localPosition.dx / cont_size * (data_pulse.length - 1)).round() * delta).toDouble();
                                    int ind = (details.localPosition.dx / cont_size * (data_pulse.length - 1)).round();
                                    text_pulse = [
                                      data_pulse[ind].toInt().toString(),
                                      date_pulse[ind].day.toString().padLeft(2, '0') + '.' + date_pulse[ind].month.toString().padLeft(2, '0'),
                                      date_pulse[ind].hour.toString() + ':' + date_pulse[ind].minute.toString().padLeft(2, '0')
                                    ];
                                  });
                                },
                                child:
                                Stack(
                                    children: [
                                      Sparkline(
                                        data: data_pulse,
                                        lineWidth: 3.0,
                                        lineColor: Color(0xffff6666),

                                        fillMode: FillMode.below,
                                        fillGradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0x96eb4034),
                                            Color(0x96ffffff)],
                                        ),
                                        //useCubicSmoothing: true,
                                        //cubicSmoothingFactor: 0.1,
                                        //gridLineLabelPrecision: 3,
                                        enableGridLines: true,

                                      ),

                                      AnimatedPositioned(
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        left: linePulsePosition,

                                        top: 0,
                                        bottom: 0,
                                        child:
                                        Container(
                                          width: 2,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ]
                                ),

                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 60,
                                child:
                                Stack(
                                    children: [
                                      AnimatedPositioned(
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          left: linePulsePosition - 34,
                                          top: 0,
                                          child:
                                          Column(
                                            children: [
                                              Text(
                                                  text_pulse[0].toString() + ' уд/мин',
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold ,

                                                  )
                                              ),
                                              Text(
                                                  text_pulse[1],
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  )
                                              ),
                                              Text(
                                                  text_pulse[2],
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  )
                                              )
                                            ],
                                          )

                                      ),
                                    ]
                                ),

                              ),


                            ]
                        )
                    )
                  ]
              ),


            ],
      ),
    );
  }
}