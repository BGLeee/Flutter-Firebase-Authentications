import 'dart:developer';

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
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage("${sp.imageUrl}"),
            radius: 50,
          ),
          ElevatedButton(
              onPressed: () {
                log("${sp.imageUrl}");
                log("${sp.name}");
                log("${sp.uid}");
                log("${sp.email}");
              },
              child: Text("Sign Out")),
          ElevatedButton(
              onPressed: () {
                sp.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignInPage()));
              },
              child: Text("Out")),
        ],
      )),
    );
  }
}
