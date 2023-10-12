import "package:fire_auths/firebase_options.dart";
import "package:fire_auths/provider/sign_in_provider.dart";
import "package:fire_auths/screens/home_page.dart";
import "package:fire_auths/screens/sign_in_page.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) {
            final sp = context.read<SignInProvider>();

            return sp.isSignedIn! ? const HomePage() : const SignInPage();
          }
        },
      ),
    );
  }
}
