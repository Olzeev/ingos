import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

DateTime selectedDate = DateTime(2000);

class Login extends StatefulWidget {
  const Login({Key, key}): super(key: key);

  @override
  _Login createState() => _Login();
}

class _Login extends State {

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    var number_insurance = "";
    var birthday = "";
    var name = user!.displayName?.split(' ')[0];
    var surname = user!.displayName?.split(' ')[1];
    var thirdname = '';



    return Scaffold(
      resizeToAvoidBottomInset: false,
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


          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
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
              width: MediaQuery.of(context).size.width * 0.75,
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
              width: MediaQuery.of(context).size.width * 0.75,
              height: 50,
              child:
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Отчество (при наличии)",
                ),
                initialValue: thirdname,
                onChanged: (String value) {
                  thirdname = value;
                },
              ),
            ),
            SizedBox(height: 25,),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 50,
              child:
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Номер страхования",
                  hintText: 'ABC-0000000000',
                ),
                initialValue: number_insurance,
                onChanged: (String value) {
                  number_insurance = value;
                },
              ),
            ),
            SizedBox(height: 25,),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: CustomDateField(),
            ),
            SizedBox(height: 30,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38, // Цвет тени
                    spreadRadius: 0, // Радиус рассеивания
                    blurRadius: 10, // Радиус размытия
                    offset: Offset(0, 5), // Смещение тени
                  ),
                ],
              ),
              child:
              TextButton(
              onPressed: () {
                String uid = user!.uid;
                String? mail = user!.email;
                FirebaseFirestore.instance
                    .collection("Users")
                    .doc(uid)
                    .set({
                  "Имя": name,
                  "Фамилия": surname,
                  "Отчество": thirdname,
                  "mail": mail,
                  "number_insurance": number_insurance,
                  "Дата рождения": selectedDate,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, color: Colors.white),
                  Text("Зарегистрироваться", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),),
                ],
              ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF1946B9)), // Цвет фона кнопки
                  overlayColor: MaterialStateProperty.all<Color>(Color(0xFF617aba)),
                  minimumSize: MaterialStateProperty.all<Size>(Size(MediaQuery.of(context).size.width * 0.75, 50)),
                  maximumSize: MaterialStateProperty.all<Size>(Size(MediaQuery.of(context).size.width * 0.75, 50)),

                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Радиус скругления углов
                    ),
                  ),
                ),
            ),
            ),
          ],
        )
      ),
    );
  }
}


class CustomDateField extends StatefulWidget {
  @override
  _CustomDateFieldState createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1930),
      lastDate: DateTime(2006),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _selectDate(context);
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
              '${selectedDate.toLocal()}'.split(' ')[0],
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}