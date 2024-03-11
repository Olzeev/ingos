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
  List<String> monthToString = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'декабря'];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    return Scaffold(
        backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color(0xFF1946B9),
            iconTheme: IconThemeData(
              color: Colors.white, // изменяем цвет иконки бургера на белый
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ингосздрав",
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25), // Цвет тени
                      spreadRadius: 0, // Радиус рассеивания
                      blurRadius: 15, // Радиус размытия
                      offset: Offset(0, 0), // Смещение тени
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 200,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0), // Добавляем отступ только слева
                          child:

                          Text("Общее состояние", style:
                            TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child:
                            Text(DateTime.now().day.toString() + ' ' + monthToString[DateTime.now().month - 1],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              )),
                        )

                      ],
                    ),
                    SizedBox(height: 10.0),

                    Row(
                        children: [
                          SizedBox(width: 15.0),
                          Text("20", style:
                          TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,

                          ))
                        ]
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      child:
                        LinearProgressIndicator(
                            value: 0.2,
                            backgroundColor: Color(0xFFFFDEDE),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7171)),
                            minHeight: 20.0,
                            borderRadius: BorderRadius.circular(7)
                        )
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("0", style:
                            TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            )),

                            Text("100",
                              style: TextStyle(
                                color: Colors.grey,
                              )),
                          ]
                        )
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Ваше состояние плохое",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )
                    )
                  ]
                )
              ),
              SizedBox(height: 16),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child:
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25), // Цвет тени
                                  spreadRadius: 0, // Радиус рассеивания
                                  blurRadius: 15, // Радиус размытия
                                  offset: Offset(0, 0), // Смещение тени
                                ),
                              ],
                            ),
                            width: MediaQuery.of(context).size.width * 0.5 - 28,
                            height: 130,
                            child:
                            Row(
                              children: [
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Image.asset('assets/images/Steps.png',
                                      width: 60,
                                    ),
                                    SizedBox(height: 15),
                                    Text("1043 шага",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ))

                                  ],
                                )
                              ]
                            )

                          ),
                          SizedBox(width: 16),
                          Container(
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.25), // Цвет тени
                                    spreadRadius: 0, // Радиус рассеивания
                                    blurRadius: 15, // Радиус размытия
                                    offset: Offset(0, 0), // Смещение тени
                                  ),
                                ],
                              ),
                              width: MediaQuery.of(context).size.width * 0.5 - 28,
                              height: 130,
                              child:
                              Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Image.asset('assets/images/HeartRate.png',
                                          width: 60,
                                        ),
                                        SizedBox(height: 15),
                                        Text("78 уд/мин",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        Container(
                                            alignment: Alignment.centerRight,
                                          width:  MediaQuery.of(context).size.width * 0.5 - 55,
                                          child:
                                          Text("15:37",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ))
                                        )

                                      ],
                                    )
                                  ]
                              )

                          ),
                        ]
                      ),
                      SizedBox(height: 15),
                      Row(
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.25), // Цвет тени
                                      spreadRadius: 0, // Радиус рассеивания
                                      blurRadius: 15, // Радиус размытия
                                      offset: Offset(0, 0), // Смещение тени
                                    ),
                                  ],
                                ),
                                width: MediaQuery.of(context).size.width * 0.5 - 28,
                                height: 130,
                                child:
                                Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Image.asset('assets/images/Calories.png',
                                            width: 60,
                                          ),
                                          SizedBox(height: 15),
                                          Text("789 Ккал",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ))

                                        ],
                                      )
                                    ]
                                )

                            ),
                            SizedBox(width: 16),
                            Container(
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.25), // Цвет тени
                                      spreadRadius: 0, // Радиус рассеивания
                                      blurRadius: 15, // Радиус размытия
                                      offset: Offset(0, 0), // Смещение тени
                                    ),
                                  ],
                                ),
                                width: MediaQuery.of(context).size.width * 0.5 - 28,
                                height: 130,
                                child:
                                Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Image.asset('assets/images/Spo2.png',
                                            width: 60,
                                          ),
                                          SizedBox(height: 15),
                                          Text("98%",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              )),
                                          Container(
                                              alignment: Alignment.centerRight,
                                              width:  MediaQuery.of(context).size.width * 0.5 - 55,
                                              child:
                                              Text("15:37",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ))
                                          )
                                        ],
                                      )
                                    ]
                                )

                            ),
                          ]
                      )
                    ]
                  ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25), // Цвет тени
                      spreadRadius: 0, // Распространение тени
                      blurRadius: 15, // Размытие тени
                      offset: Offset(0, 0), // Смещение тени
                    ),
                  ],
                ),
                child: TextButton(
                    onPressed: () {
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
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // Цвет фона кнопки
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // Цвет текста
                      minimumSize: MaterialStateProperty.all<Size>(Size(MediaQuery.of(context).size.width * 0.9, 45)),
                      overlayColor: MaterialStateProperty.all<Color>(Color(0xFFF0F0F0)),

                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Радиус скругления углов
                        ),
                      ),
                    ),
                    child:
                    Text("Показать все данные",
                        style: TextStyle(
                          color: Colors.black,

                        ))
                )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(

                    children: [
                      Image.asset('assets/images/logo.png',
                        width: 60,
                      ),
                      Text(
                        'Университетская гимназия МГУ им. М.В.Ломоносова',
                        style: TextStyle(fontSize: 15),
                      )
                    ]

                ),
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
    );
  }
}