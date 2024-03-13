import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'settings.dart';
import 'data.dart';
import 'dart:async';
import 'package:health/health.dart';
import 'package:health_example/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'mat_model.dart';



class Home_page extends StatefulWidget {
  const Home_page({Key, key}): super(key: key);

  @override
  _Home_page createState() => _Home_page();
}


enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
}



class _Home_page extends State {
  final user = FirebaseAuth.instance.currentUser;
  List<String> monthToString = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'декабря'];

  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int nofSteps = 0;
  String heart_value = '-';
  int cal = 0;
  double blood = 0.0;
  String heart_value_time = '';
  String blood_time = '';
  double distance = 0;
  int _general_state = 0;

  static final types = dataTypesAndroid;


  final permissions = types.map((e) => HealthDataAccess.READ).toList();

  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  Future authorize() async {

    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Check if we have health permissions
    bool? hasPermissions =
    await health.hasPermissions(types, permissions: permissions);

    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {

      try {
        authorized =
        await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }

    setState(() => _state =
    (authorized) ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
  }

  Future fetchData() async {

    await authorize();

    setState(() => _state = AppState.FETCHING_DATA);

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    // Clear old data points
    _healthDataList.clear();

    try {
      // fetch health data
      List<HealthDataPoint> healthData =
      await health.getHealthDataFromTypes(midnight, now, types);

      _healthDataList.addAll(
          (healthData.length < 1000) ? healthData : healthData.sublist(0, 1000));
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    // filter out duplicates
    _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
    //print("oiawejfoiawjef" + _healthDataList[0].sourceName);
    // print the results
    //_healthDataList.forEach((x) => print(x));

    // update the UI to display the results
    setState(() {
      _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    });
    cal = 0;
    distance = 0;
    for (int i = 0; i < _healthDataList.length; i++) {
      if (_healthDataList[i].typeString == "HEART_RATE") {
        heart_value = _healthDataList[i].value.toString();
        heart_value_time = DateFormat('HH:mm').format(_healthDataList[i].dateFrom);
      }
      if (_healthDataList[i].typeString == "WORKOUT") {
        cal += int.parse((_healthDataList[i].value as WorkoutHealthValue).totalEnergyBurned.toString());
      }
      if (_healthDataList[i].typeString == "BLOOD_OXYGEN") {
        blood = double.parse(_healthDataList[i].value.toString());
        blood_time = DateFormat('HH:mm').format(_healthDataList[i].dateFrom);
      }
      if (_healthDataList[i].typeString == "DISTANCE_DELTA") {
        distance += double.parse(_healthDataList[i].value.toString());
      }
    }

  }


  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool stepsPermission =
        await health.hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission =
      await health.requestAuthorization([HealthDataType.STEPS]);
    }

    if (stepsPermission) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');

      setState(() {
        nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Future fetchGeneralState() async{
    List<List<double>> data = [];
    List<double> heart = [];
    List<double> sleep = [];
    List<double> steps = [];

    final now1 = DateTime.now();
    DateTime startdata1 = DateTime(now1.year, now1.month, now1.day).subtract(Duration(days: 30));

    for (int i = 0; i < 30; i++) {
      DateTime endSteps = startdata1.add(Duration(days: 1)).isBefore(now1) ? startdata1.add(Duration(days: 1)) : now1;
      List<HealthDataPoint> heartdata = await health.getHealthDataFromTypes(startdata1, endSteps, [HealthDataType.HEART_RATE]);
      for (int j = 0; j < heartdata.length; j++) {
        heart.add(double.parse(heartdata[j].value.toString()));
      }
      startdata1 = startdata1.add(Duration(days: 1));
    }

    final now3 = DateTime.now();
    DateTime startdata3 = DateTime(now3.year, now3.month, now3.day).subtract(Duration(days: 30));

    for (int i = 0; i < 30; i++) {
      DateTime endSteps = startdata3.add(Duration(days: 1)).isBefore(now3) ? startdata3.add(Duration(days: 1)) : now3;
      List<HealthDataPoint> sleepdata = await health.getHealthDataFromTypes(startdata3, endSteps, [HealthDataType.SLEEP_SESSION]);
      double sleep_delta = 0.0;
      for (int j = 0; j < sleepdata.length; j++) {
        sleep_delta += double.parse(sleepdata[j].value.toString());
      }
      if (sleep_delta != 0.0) {
        sleep.add(sleep_delta / 60.0);
      }
      startdata3 = startdata3.add(Duration(days: 1));
    }

    final now2 = DateTime.now();
    DateTime startdata2 = DateTime(now2.year, now2.month, now2.day).subtract(Duration(days: 30));
    bool stepsPermission =
        await health.hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission =
      await health.requestAuthorization([HealthDataType.STEPS]);
    }
    if (stepsPermission) {
      for (int i = 0; i < 30; i++) {
        DateTime endSteps = startdata2.add(Duration(days: 1)).isBefore(now2) ? startdata2.add(Duration(days: 1)) : now2;
        int? steps_delta = await health.getTotalStepsInInterval(startdata2, endSteps);
        if (steps_delta!.toDouble() != 0.0) {
          steps.add(steps_delta!.toDouble());
        }
        startdata2 = startdata2.add(Duration(days: 1));
      }
    }

    data.add(heart);
    data.add(sleep);
    data.add(steps);

    print(data);
    _general_state = get_general_state(data);
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Future<void> _refreshData() async {
    fetchData();
    fetchStepData();
    fetchGeneralState();
    // Future.delayed(Duration(milliseconds: 3000), () {
    //   setState(() {
    //
    //   });
    // });
  }



  @override
  void initState() {
    super.initState();
    _refreshData();
  }


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
          body:
            RefreshIndicator(
              onRefresh: _refreshData,
              child:
            Center(
            child: ListView(
              children: [
              Column(
              mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              _general_state != 0 ? Container(
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
                          Text(_general_state.toString(), style:
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
                            value: _general_state / 100.0,
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
              ) : Container(),
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
                                    SizedBox(height: 10),
                                    Text("$nofSteps шага",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    )),
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        width:  MediaQuery.of(context).size.width * 0.5 - 55,
                                        child:
                                        Text('${(distance / 1000.0).toStringAsFixed(2)} км',
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
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Image.asset('assets/images/HeartRate.png',
                                          width: 60,
                                        ),
                                        SizedBox(height: 10),
                                        Text("$heart_value уд/мин",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        Container(
                                            alignment: Alignment.centerRight,
                                          width:  MediaQuery.of(context).size.width * 0.5 - 55,
                                          child:
                                          Text(heart_value_time,
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
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Image.asset('assets/images/Calories.png',
                                            width: 60,
                                          ),
                                          SizedBox(height: 15),
                                          Text("$cal Ккал",
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
                                          Text("$blood%",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              )),
                                          Container(
                                              alignment: Alignment.centerRight,
                                              width:  MediaQuery.of(context).size.width * 0.5 - 55,
                                              child:
                                              Text(blood_time,
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
                    Text("Подробнее",
                        style: TextStyle(
                          color: Colors.black,

                        ))
                )
              ),

              SizedBox(height: 100,),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(

                    children: [
                      Image.asset('assets/images/logo.png',
                        width: 60,
                      ),
                      Text(
                        'Университетская гимназия МГУ им. М.В.Ломоносова',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ]

                ),
              )
            ],

          )]
            )
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
    );
  }
}