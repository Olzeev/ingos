import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'home.dart';
import 'settings.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'dart:async';
import 'package:health/health.dart';
import 'package:health_example/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';


class Data extends StatefulWidget {
  const Data({Key, key}): super(key: key);

  @override
  _Data createState() => _Data();
}

class _Data extends State {
  final user = FirebaseAuth.instance.currentUser;


  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int nofSteps = 0;

  double linePulsePosition = 0.0;
  List<double> data_pulse = [];
  List<DateTime> date_pulse = [];
  List<String> text_pulse = [" ", " ", " "];

  double lineStepsPosition = 0.0;
  List<double> data_steps = [];
  List<DateTime> date_steps = [];
  List<String> text_steps = [" ", " "];

  double lineCalPosition = 0.0;
  List<double> data_cal = [];
  List<DateTime> date_cal = [];
  List<String> text_cal = [" ", " "];

  double lineBloodPosition = 0.0;
  List<double> data_blood = [];
  List<DateTime> date_blood = [];
  List<String> text_blood = [" ", " ", " "];

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


  Future getCal() async {
    final now = DateTime.now();
    DateTime startdata = DateTime(now.year, now.month, now.day).subtract(Duration(days: 14));

    for (int i = 0; i < 14; i++) {
      DateTime endSteps = startdata.add(Duration(days: 1)).isBefore(now) ? startdata.add(Duration(days: 1)) : now;
      List<HealthDataPoint> healthDataCal = await health.getHealthDataFromTypes(startdata, endSteps, [HealthDataType.WORKOUT]);
      double data_cal_delta = 0.0;
      for (int j = 0; j < healthDataCal.length; j++) {
        data_cal_delta += double.parse((healthDataCal[j].value as WorkoutHealthValue).totalEnergyBurned.toString());
      }
      if (data_cal_delta != 0.0) {
        data_cal.add(data_cal_delta);
        date_cal.add(startdata);
      }
      startdata = startdata.add(Duration(days: 1));
    }
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
    for (int i = 0; i < _healthDataList.length; i++) {
      if (_healthDataList[i].typeString == "HEART_RATE") {
        data_pulse.add(double.parse(_healthDataList[i].value.toString()));
        date_pulse.add(_healthDataList[i].dateFrom);
      }
      if (_healthDataList[i].typeString == "BLOOD_OXYGEN") {
        data_blood.add(double.parse(_healthDataList[i].value.toString()));
        date_blood.add(_healthDataList[i].dateFrom);
      }
    }
  }


  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    DateTime startdata = DateTime(now.year, now.month, now.day).subtract(Duration(days: 14));
    bool stepsPermission =
        await health.hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission =
      await health.requestAuthorization([HealthDataType.STEPS]);
    }
    if (stepsPermission) {
      for (int i = 0; i < 14; i++) {
        DateTime endSteps = startdata.add(Duration(days: 1)).isBefore(now) ? startdata.add(Duration(days: 1)) : now;
        int? steps_delta = await health.getTotalStepsInInterval(startdata, endSteps);
        if (steps_delta!.toDouble() != 0.0) {
          data_steps.add(steps_delta!.toDouble());
          date_steps.add(startdata);
        }
        startdata = startdata.add(Duration(days: 1));
      }
    }
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

  void clear_all(){
    data_steps.clear();
    date_steps.clear();
    data_pulse.clear();
    date_pulse.clear();
    data_blood.clear();
    date_blood.clear();
    data_cal.clear();
    date_cal.clear();
  }

  Future<void> _refreshData() async {
    clear_all();
    fetchData();
    fetchStepData();
    getCal();
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
      child:
      ListView(
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
                    child: data_pulse.length != 0 ?
                        Column(
                          children: [
                            GestureDetector(
                              onTapDown: (details){
                                setState(() {
                                  // Позиция линии будет устанавливаться на середину контейнера по оси X
                                  double cont_size = MediaQuery.of(context).size.width * 0.9 - 15;
                                  double delta = data_pulse.length == 1 ? cont_size : (cont_size / (data_pulse.length - 1));
                                  linePulsePosition = data_pulse.length != 1 ? ((details.localPosition.dx / cont_size * (data_pulse.length - 1)).round() * delta).toDouble() : MediaQuery.of(context).size.width * 0.5 - 30;
                                  int ind = data_pulse.length == 1 ? 0 : (details.localPosition.dx / cont_size * (data_pulse.length - 1)).round();
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
                                        left: linePulsePosition - 34 >= 0 ? (linePulsePosition - 34 < MediaQuery.of(context).size.width * 0.9 - 80 ? linePulsePosition - 34 : MediaQuery.of(context).size.width * 0.9 - 80) : 0,
                                        top: 0,
                                        child:
                                            Column(
                                            children: [
                                              Text(
                                                  text_pulse[0].toString() + (text_pulse[0].length > 1 ? ' уд/мин' : ''),
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
                        ) :
                    Stack(
                        children: [
                          Sparkline(
                            lineWidth: 0.0,

                            data: [],

                            //useCubicSmoothing: true,
                            //cubicSmoothingFactor: 0.1,
                            //gridLineLabelPrecision: 3,
                            enableGridLines: true,

                          ),
                          Center(
                              child:
                              Padding(
                                padding: EdgeInsets.only(top: 17),
                                child:
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10), // Радиус углов
                                    border: Border.all( // Обводка
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  width: 120,
                                  height: 40,

                                  child: Center(

                                    child: Text(
                                      'Нет данных',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          )

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
                        child: data_steps.length != 0 ?
                        Column(
                            children: [
                              GestureDetector(
                                onTapDown: (details){
                                  setState(() {
                                    double cont_size = MediaQuery.of(context).size.width * 0.9 - 28;
                                    double delta = data_steps.length == 1 ? cont_size : (cont_size / (data_steps.length - 1));
                                    lineStepsPosition = data_steps.length != 1 ? ((details.localPosition.dx / cont_size * (data_steps.length - 1)).round() * delta).toDouble() :  MediaQuery.of(context).size.width * 0.5 - 56;

                                    int ind = data_steps.length == 1 ? 0 : (details.localPosition.dx / cont_size * (data_steps.length - 1)).round();
                                    text_steps = [
                                      data_steps[ind].toInt().toString(),
                                      date_steps[ind].day.toString().padLeft(2, '0') + '.' + date_steps[ind].month.toString().padLeft(2, '0'),
                                    ];
                                  });
                                },
                                child:
                                Stack(
                                    children: [
                                      Sparkline(
                                        data: data_steps,
                                        lineWidth: 3.0,
                                        lineColor: Color(0xff4F7DF2),
                                        fillMode: FillMode.below,
                                        fillGradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0x964F7DF2),
                                            Color(0x96ffffff)],
                                        ),
                                        //useCubicSmoothing: true,
                                        //cubicSmoothingFactor: 0.1,
                                        gridLineLabelPrecision: 5,
                                        enableGridLines: true,

                                      ),

                                      AnimatedPositioned(
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        left: lineStepsPosition,

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
                                          left: (lineStepsPosition - 34 >= 0) ? (( lineStepsPosition - 34 < MediaQuery.of(context).size.width * 0.9 - 100) ? lineStepsPosition - 34 : MediaQuery.of(context).size.width * 0.9 - 100) : 0,
                                          top: 0,
                                          child:
                                          Column(
                                            children: [
                                              Text(
                                                  text_steps[0].toString() + (text_steps[0].length > 1 ? ' шагов' : ""),
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold ,

                                                  )
                                              ),
                                              Text(
                                                  text_steps[1],
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  )
                                              ),
                                            ],
                                          )

                                      ),
                                    ]
                                ),

                              ),


                            ]
                        ) :
                        Stack(
                          children: [
                          Sparkline(
                          lineWidth: 0.0,

                          data: [],

                          //useCubicSmoothing: true,
                          //cubicSmoothingFactor: 0.1,
                          //gridLineLabelPrecision: 3,
                          enableGridLines: true,

                        ),
                        Center(
                            child:
                            Padding(
                              padding: EdgeInsets.only(top: 17),
                              child:
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10), // Радиус углов
                                  border: Border.all( // Обводка
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                width: 120,
                                height: 40,

                                child: Center(

                                  child: Text(
                                    'Нет данных',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            )
                        )

                      ]
                      )
                    )
                  ]
              ),
              SizedBox(height: 15,),
              Padding(
                padding: EdgeInsets.only(left:25),
                child: Text("Калории", style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold), ),
              ),
              SizedBox(height: 15,),
              Row(

                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child:
                            data_cal.length != 0 ?
                        Column(
                            children: [
                              GestureDetector(
                                onTapDown: (details){
                                  setState(() {
                                    // Позиция линии будет устанавливаться на середину контейнера по оси X
                                    print("oiahwfioajwfiojawf${data_cal.length}");
                                    double cont_size = MediaQuery.of(context).size.width * 0.9 - 15;
                                    double delta = data_cal.length == 1 ? cont_size : (cont_size / (data_cal.length - 1));
                                    lineCalPosition = data_cal.length != 1 ? ((details.localPosition.dx / cont_size * (data_cal.length - 1)).round() * delta).toDouble() : MediaQuery.of(context).size.width * 0.9 - 30;
                                    int ind = data_cal.length == 1 ? 0 : (details.localPosition.dx / cont_size * (data_cal.length - 1)).round();
                                    text_cal = [
                                      data_cal[ind].toInt().toString(),
                                      date_cal[ind].day.toString().padLeft(2, '0') + '.' + date_cal[ind].month.toString().padLeft(2, '0'),
                                      date_cal[ind].hour.toString() + ':' + date_cal[ind].minute.toString().padLeft(2, '0')
                                    ];
                                  });
                                },
                                child:
                                Stack(
                                    children: [
                                      Sparkline(
                                        data: data_cal,
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
                                        left: lineCalPosition,

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
                                          left: lineCalPosition - 34,
                                          top: 0,
                                          child:
                                          Column(
                                            children: [
                                              Text(
                                                  text_cal[0].toString() + ' ккал',
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold ,

                                                  )
                                              ),
                                              Text(
                                                  text_cal[1],
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  )
                                              ),
                                            ],
                                          )

                                      ),
                                    ]
                                ),

                              ),

                            ]
                        ) :
                                Stack(
                                  children: [
                                    Sparkline(
                                      lineWidth: 0.0,

                                      data: [],

                                      //useCubicSmoothing: true,
                                      //cubicSmoothingFactor: 0.1,
                                      //gridLineLabelPrecision: 3,
                                      enableGridLines: true,

                                    ),
                                    Center(
                                      child:
                                        Padding(
                                          padding: EdgeInsets.only(top: 17),
                                          child:
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10), // Радиус углов
                                                border: Border.all( // Обводка
                                                  color: Colors.grey,
                                                  width: 2,
                                                ),
                                              ),
                                              width: 120,
                                              height: 40,

                                              child: Center(

                                                child: Text(
                                                  'Нет данных',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      )
                                    )

                                  ]
                                )
                    )
                  ]
              ),
              SizedBox(height: 15,),
              Padding(
                padding: EdgeInsets.only(left:25),
                child: Text("Содержание кислорода в крови", style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold), ),
              ),
              SizedBox(height: 15,),
              Row(

                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: data_blood.length != 0 ?
                        Column(
                            children: [
                              GestureDetector(
                                onTapDown: (details){
                                  setState(() {
                                    // Позиция линии будет устанавливаться на середину контейнера по оси X
                                    double cont_size = MediaQuery.of(context).size.width * 0.9 - 20;
                                    double delta = (cont_size / (data_blood.length - 1));
                                    lineBloodPosition = ((details.localPosition.dx / cont_size * (data_blood.length - 1)).round() * delta).toDouble();
                                    int ind = (details.localPosition.dx / cont_size * (data_blood.length - 1)).round();
                                    text_blood = [
                                      data_blood[ind].toInt().toString(),
                                      date_blood[ind].day.toString().padLeft(2, '0') + '.' + date_blood[ind].month.toString().padLeft(2, '0'),
                                      date_blood[ind].hour.toString() + ':' + date_blood[ind].minute.toString().padLeft(2, '0')
                                    ];
                                  });
                                },
                                child:
                                Stack(
                                    children: [
                                      Sparkline(
                                        data: data_blood,
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
                                        left: lineBloodPosition,

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
                                          left: lineBloodPosition - 20 >= 0 ? (lineBloodPosition - 20 < MediaQuery.of(context).size.width * 0.9 - 50 ? lineBloodPosition - 20 : MediaQuery.of(context).size.width * 0.9 - 50) : 0,
                                          top: 0,
                                          child:
                                          Column(
                                            children: [
                                              Text(
                                                  text_blood[0].toString() + (text_blood[0].length > 1 ? ' %' : ''),
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold ,

                                                  )
                                              ),
                                              Text(
                                                  text_blood[1],
                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  )
                                              ),
                                              Text(
                                                  text_blood[2],
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
                        ) :
                        Stack(
                          children: [
                            Sparkline(
                              lineWidth: 0.0,

                              data: [],

                              //useCubicSmoothing: true,
                              //cubicSmoothingFactor: 0.1,
                              //gridLineLabelPrecision: 3,
                              enableGridLines: true,

                            ),
                            Center(
                                child:
                                Padding(
                                  padding: EdgeInsets.only(top: 17),
                                  child:
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10), // Радиус углов
                                      border: Border.all( // Обводка
                                        color: Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    width: 120,
                                    height: 40,

                                    child: Center(

                                      child: Text(
                                        'Нет данных',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            )
                          ]
                        )
                    )
                  ]
              ),
              SizedBox(height: 50),
            ],
      ),
    )
    );
  }
}