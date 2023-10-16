import 'package:country_code_picker/country_code_picker.dart';
import 'package:fire_auths/provider/internet_provider.dart';
import 'package:fire_auths/provider/sign_in_provider.dart';
import 'package:fire_auths/screens/home_page.dart';
import 'package:fire_auths/utils/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final RoundedLoadingButtonController phoneButtonController =
      RoundedLoadingButtonController();

  final TextEditingController phoneNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final TextEditingController otpCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: formKey,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 40, right: 40, top: 30, bottom: 30),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: "Logo",
                      child: Stack(
                        children: [
                          const Image(
                            image: AssetImage("assets/firebase.png"),
                            width: 100,
                          ),
                          Positioned(
                            bottom: -1,
                            right: 3,
                            child: SvgPicture.asset(
                              "assets/lock.svg",
                              width: 30,
                              // height: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter your Phone Number";
                        }
                        return null;
                      },
                      controller: phoneNumberController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: "912345678",
                        prefixIcon: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 70,
                            decoration: const BoxDecoration(
                              border: Border(
                                right:
                                    BorderSide(width: 2, color: Colors.black38),
                              ),
                            ),
                            child: const CountryCodePicker(
                              initialSelection: "ET",
                              showFlag: false,
                              favorite: ['+251', 'ET'],
                              textStyle: TextStyle(color: Colors.black),
                            )),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: RoundedLoadingButton(
                            onPressed: () {
                              print(phoneNumberController.text);
                              login(context, phoneNumberController.text);
                            },
                            color: Colors.black,
                            controller: phoneButtonController,
                            successColor: Colors.black,
                            width: MediaQuery.of(context).size.width * 0.35,
                            elevation: 0,
                            borderRadius: 10,
                            child: const Wrap(
                              alignment: WrapAlignment.end,
                              children: [
                                Text(
                                  "Sign in",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future login(BuildContext context, String phoneNumber) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();

    if (ip.isConnected == false) {
      openSnackbar(context, "No Connection", Colors.red);
    } else {
      if (formKey.currentState!.validate()) {
        FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          codeAutoRetrievalTimeout: (String verificationId) {},
          verificationCompleted: (AuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            openSnackbar(context, e.toString(), Colors.red);
          },
          codeSent: ((verificationId, forceResendingToken) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("Enter Code")]),
                  titleTextStyle: const TextStyle(color: Colors.white),
                  backgroundColor: Colors.black,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: otpCodeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final code = otpCodeController.text.trim();
                          AuthCredential authCredential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: code);
                          User user = (await FirebaseAuth.instance
                                  .signInWithCredential(authCredential))
                              .user!;
                          sp.phoneNumberUser(user);

                          sp.checkUserExists().then(
                            (value) async {
                              if (value == true) {
                                sp.getUserDataFromFirestore(sp.uid).then(
                                      (value) => sp
                                          .saveDataToSharedPreference()
                                          .then(
                                            (value) => sp.setSignIn().then(
                                              (value) {
                                                Navigator.pop(context);
                                                phoneButtonController.success();
                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomePage(),
                                                    ),
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                    );
                              } else {
                                sp.saveDataToFirestore().then(
                                      (value) => sp
                                          .saveDataToSharedPreference()
                                          .then(
                                            (value) => sp.setSignIn().then(
                                                  (value) => {
                                                    Navigator.pop(context),
                                                    phoneButtonController
                                                        .success(),
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 1), () {
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
                        },
                        child: const Text("Confirm"),
                      )
                    ],
                  ),
                );
              },
            );
          }),
        );
      }
    }
  }
}
