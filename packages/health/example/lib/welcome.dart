import 'package:flutter/material.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'color_schemes.dart';
import 'redirect.dart';


void main2() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
          child: Container(
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
              final user = FirebaseAuth.instance.currentUser;
              signInWithGoogle().whenComplete(() {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Redirect(),
                    transitionDuration: Duration(milliseconds: 300),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, color: Colors.white,),
                Text("Войти / Зарегистрироваться", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),),
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
        )
      ),);
  }
}
