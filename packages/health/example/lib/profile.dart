import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'settings.dart';
import 'show_data.dart';
import 'data.dart';
import 'welcome.dart';


DateTime selectedDate = DateTime(1999);

class Profile extends StatefulWidget {
  const Profile({Key, key}): super(key: key);

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => MyApp(),
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    String thirdname = '';
    var name = user.displayName?.split(' ')[0];
    var surname = user.displayName?.split(' ')[1];

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Личный кабинет"),
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
        body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
        return Center(child:
        Column (
          children: [
            Expanded(
              child: Column(
          children: [
            SizedBox(height: 110,),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 50,
              child:
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Имя",
                ),
                initialValue: name,
                onChanged: (String value) {
                  name = value;
                },
              ),
            ),
            SizedBox(height: 25,),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 50,
              child:
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Фамилия",
                ),
                initialValue: surname,
                onChanged: (String value) {
                  surname = value;
                },
              ),
            ),
            SizedBox(height: 25,),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 50,
              child:
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Отчество (при наличии)",
                ),
                initialValue: (snapshot
                    .data as DocumentSnapshot)['Отчество'],
                onChanged: (String value) {
                  thirdname = value;
                },
              ),
            ),
            SizedBox(height: 25,),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 50,
              child:
              TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Номер страхования",
                ),
                initialValue: (snapshot
                    .data as DocumentSnapshot)['number_insurance'],
              ),
            ),
            SizedBox(height: 25,),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              child: CustomDateField(date: (snapshot
                  .data as DocumentSnapshot)['Дата рождения'].toDate()),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () {
                String uid = user!.uid;
                String? mail = user!.email;
                FirebaseFirestore.instance
                    .collection("Users")
                    .doc(uid)
                    .set({
                  "Имя": name,
                  "Фамилия": surname,
                  "Отчество": thirdname != '' ? thirdname : (snapshot
                      .data as DocumentSnapshot)['Отчество'],
                  "mail": mail,
                  "number_insurance": (snapshot
                      .data as DocumentSnapshot)['number_insurance'],
                  "Дата рождения": selectedDate != DateTime(1999) ? selectedDate : (snapshot
                      .data as DocumentSnapshot)['Дата рождения'].toDate(),
                });
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Home_page(),
                    transitionDuration: Duration(milliseconds: 300),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              },
              child: Text("Сохранить", textAlign: TextAlign.center, style: TextStyle(color: Color(
                  0xff1d192b), fontSize: 16, fontWeight: FontWeight.w600),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xfff9dedc),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                minimumSize: Size(MediaQuery.of(context).size.width * 0.85, 45),
                maximumSize: Size(MediaQuery.of(context).size.width * 0.85, 45),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                    color: Color(0xfff9dedc),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ],),),
            ElevatedButton(
              onPressed: () {
                signOut();
              },
              child: Text("Выйти", textAlign: TextAlign.center, style: TextStyle(color: Color(
                  0xff1d192b), fontSize: 16, fontWeight: FontWeight.w600),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xfff9dedc),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                minimumSize: Size(MediaQuery.of(context).size.width * 0.85, 45),
                maximumSize: Size(MediaQuery.of(context).size.width * 0.85, 45),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                    color: Color(0xfff9dedc),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40,),
          ],
        ),
    );
    }
        else {
        return Center();
      }
    }));
  }
}


class CustomDateField extends StatefulWidget {

  DateTime date;

  CustomDateField({super.key, required this.date});

  @override
  _CustomDateFieldState createState() => _CustomDateFieldState(this.date);
}

class _CustomDateFieldState extends State<CustomDateField> {

  DateTime date;

  _CustomDateFieldState(this.date);

  Future<void> _selectDate(BuildContext context, date) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != DateTime(1999) ? selectedDate : date,
      firstDate: DateTime(1930),
      lastDate: DateTime(2006),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _selectDate(context, date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Дата рождения',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '${(selectedDate != DateTime(1999) ? selectedDate : date).toLocal()}'.split(' ')[0],
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}