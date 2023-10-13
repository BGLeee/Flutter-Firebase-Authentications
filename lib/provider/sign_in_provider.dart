import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool? _isSignedIn = false;

  String? _errorCode;
  String? get errorCode => _errorCode;

  bool? _hasError;
  bool? get hasError => _hasError;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  bool? get isSignedIn => _isSignedIn;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    log("its running");
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    log("the isSignedIn value ${_isSignedIn}");
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSinInAccount = await googleSignIn.signIn();
    if (googleSinInAccount != null) {
      try {
        final GoogleSignInAuthentication gSA =
            await googleSinInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: gSA.accessToken, idToken: gSA.idToken);

        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = "GOOGLE";
        _uid = userDetails.uid;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-us. Use correct provider":
            _errorCode =
                "You already have an account with us. Use correct Provider";
            _hasError = true;
            notifyListeners();
            break;
          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _uid = snapshot['uid'];
      _name = snapshot['name'];
      _email = snapshot['email'];
      _imageUrl = snapshot['imageUrl'];
      _provider = snapshot['provider'];
    });
  }

  Future saveDataToFirestore() async {
    final DocumentReference r =
        FirebaseFirestore.instance.collection("user").doc(uid);
    await r.set({
      'uid': _uid,
      'name': _name,
      'email': _email,
      'imageUrl': _imageUrl,
      'provider': _provider
    });
  }

  Future saveDataToSharedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", _name!);
    await prefs.setString("email", _email!);
    await prefs.setString("uid", _uid!);
    await prefs.setString("provider", _provider!);
    await prefs.setString("image_url", _imageUrl!);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString("name");
    _email = prefs.getString("email");
    _imageUrl = prefs.getString("image_url");
    _provider = prefs.getString("provider");
    _uid = prefs.getString("uid");
    notifyListeners();
  }

  Future<bool> checkUserExists() async {
    DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection("user").doc(_uid).get();
    if (userData.exists) {
      print("User Exist");
      return true;
    } else {
      print("New User");
      return false;
    }
  }

  Future signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    _isSignedIn = false;
    notifyListeners();
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }
}
