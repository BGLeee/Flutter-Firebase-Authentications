import "dart:async";

import "package:fire_auths/firebase_options.dart";
import "package:fire_auths/provider/internet_provider.dart";
import "package:fire_auths/provider/sign_in_provider.dart";
import "package:fire_auths/screens/home_page.dart";
import "package:fire_auths/screens/sign_in_page.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: SignInProvider(),
        ),
        ChangeNotifierProvider.value(
          value: InternetProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false
          ? Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SignInPage()))
          : Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Hero(
          tag: "Logo",
          child: Stack(
            children: [
              const Image(
                image: AssetImage("assets/firebase.png"),
              ),
              Positioned(
                bottom: -1,
                right: 3,
                child: SvgPicture.asset(
                  "assets/lock.svg",
                  // height: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
