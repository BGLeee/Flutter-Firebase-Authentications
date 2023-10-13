import 'package:fire_auths/provider/internet_provider.dart';
import 'package:fire_auths/provider/sign_in_provider.dart';
import 'package:fire_auths/screens/home_page.dart';
import 'package:fire_auths/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
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
                  const SizedBox(height: 20),
                  const Text(
                    "Flutter Firebase",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Firebase Authentications",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedLoadingButton(
                  onPressed: handleGoogleSignIn,
                  color: Colors.red,
                  controller: googleController,
                  successColor: Colors.red,
                  width: MediaQuery.of(context).size.width * 10.80,
                  borderRadius: 25,
                  elevation: 0,
                  child: const Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      Icon(FontAwesomeIcons.google,
                          size: 20, color: Colors.white),
                      SizedBox(width: 15),
                      Text(
                        "Sign in with Google",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RoundedLoadingButton(
                  onPressed: () {},
                  color: Colors.blue,
                  controller: facebookController,
                  successColor: Colors.blue,
                  width: MediaQuery.of(context).size.width * 10.80,
                  elevation: 0,
                  borderRadius: 25,
                  child: const Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      Icon(FontAwesomeIcons.facebook,
                          size: 20, color: Colors.white),
                      SizedBox(width: 15),
                      Text(
                        "Sign in with Facebook",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RoundedLoadingButton(
                  onPressed: () {},
                  color: Colors.black,
                  controller: facebookController,
                  successColor: Colors.black,
                  width: MediaQuery.of(context).size.width * 10.80,
                  elevation: 0,
                  borderRadius: 25,
                  child: const Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      Icon(FontAwesomeIcons.phone,
                          size: 20, color: Colors.white),
                      SizedBox(width: 15),
                      Text(
                        "Sign in with Phone number",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }

  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    if (ip.isConnected == false) {
      openSnackbar(context, "Check you Internet Connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then(
        (value) {
          if (sp.hasError == true) {
            openSnackbar(context, sp.errorCode, Colors.red);
            googleController.reset();
          } else {
            sp.checkUserExists().then(
              (value) async {
                if (value == true) {
                  sp.getUserDataFromFirestore(sp.uid).then(
                        (value) => sp.saveDataToSharedPreference().then(
                              (value) => sp.setSignIn().then(
                                (value) {
                                  googleController.success();
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                      );
                } else {
                  sp.saveDataToFirestore().then(
                        (value) => sp.saveDataToSharedPreference().then(
                              (value) => sp.setSignIn().then(
                                    (value) => {
                                      googleController.success(),
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage(),
                                          ),
                                        );
                                      })
                                    },
                                  ),
                            ),
                      );
                }
                setState(() {});
              },
            );
          }
        },
      );
    }
  }
}
