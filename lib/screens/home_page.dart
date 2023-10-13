import 'package:fire_auths/provider/sign_in_provider.dart';
import 'package:fire_auths/screens/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.read<SignInProvider>();
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                sp.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInPage()));
              },
              child: const Text("Sign Out")),
        ],
      )),
    );
  }
}
