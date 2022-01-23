// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userText = TextEditingController();
  final passText = TextEditingController();
  final storage = new FlutterSecureStorage();
  bool isSave = false;
  String? _validateUser = null;
  String? _validatePass = null;
  bool process = false;

  ///Functions///////////////////////////////

  void checkInput({bool canGo = false}) {
    if (process) {
      return;
    }
    _validateUser = null;
    _validatePass = null;
    if (userText.text.isEmpty) {
      _validateUser = "User name can not be empty";
    }
    if (!canGo) {
      setState(() {});
      return;
    }
    MyPrint.printWarning("userValidation is correct!");
    if (passText.text.isEmpty) {
      _validatePass = "Password can not be empty";
    }
    setState(() {});
    if (_validatePass == null && _validateUser == null) {
      startLogin(user: userText.text, pass: passText.text);
    }
  }

  Future<void> startLogin({required String user, required String pass}) async {
    setState(() {
      process = true;
    });
    if (isSave) {
      await storage.write(key: "user", value: user);
      await storage.write(key: "pass", value: pass);
      await storage.write(key: "isSave", value: isSave.toString());
    } else {
      await storage.delete(key: "user");
      await storage.delete(key: "pass");
      await storage.write(key: "isSave", value: isSave.toString());
    }
    MyPrint.printWarning("login started");
    String _res = await MyNetwork().login(login: user, pass: pass);
    if (_res == "OK") {
      MyPrint.printWarning(MyNetwork.token);
      Navigator.pushReplacementNamed(context, "/main");
    } else {
      MyPrint.printError(_res);
      if (_res == "not enough data") {
        _validateUser = "enter user correctly";
        _validatePass = "Enter password correctly!";
      } else {
        if (_res == "wrong login or password") {
          _validateUser = "wrong login or password";
          _validatePass = "wrong login or password";
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: MyColors.yellow,
                title: const Text('Error'),
                content: Text(_res),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
      setState(() {
        process = false;
      });
    }
  }

  void firstStart() async {
    String _issave = await storage.read(key: "isSave") ?? "false";
    isSave = _issave == "true" ? true : false;

    if (isSave) {
      userText.text = (await storage.read(key: "user")) ?? "";
      passText.text = (await storage.read(key: "pass")) ?? "";
    }
    setState(() {});
  }

  /////////////////
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userText.dispose();
    passText.dispose();
    super.dispose();
  }

  @override
  void initState() {
    MyPrint.printWarning("Welcome to Login Page");
    firstStart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.black,
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: double.infinity,
              ),
            ),
            SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: MyColors.white,
                          fontSize: 36,
                        ),
                      ),
                    ),
                    TextField(
                        //autofocus: true,
                        enabled: !process,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: MyColors.orange)),
                          filled: true,
                          fillColor: MyColors.yellow,
                          focusColor: MyColors.cyan,
                          hintText: "Enter login",
                          //labelText: "User",
                          errorText: _validateUser,
                        ),
                        controller: userText,
                        enableSuggestions: false,
                        autocorrect: false,
                        onSubmitted: (value) {
                          checkInput();
                        },
                        textInputAction: TextInputAction.next),
                    SizedBox(
                      height: 6,
                    ),
                    TextField(
                        enabled: !process,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: MyColors.orange)),
                          filled: true,
                          fillColor: MyColors.yellow,
                          focusColor: MyColors.cyan,
                          hintText: "Enter password",
                          //labelText: "User",
                          errorText: _validatePass,
                        ),
                        controller: passText,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        onSubmitted: (value) {
                          checkInput(canGo: false);
                        },
                        textInputAction: TextInputAction.next),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isSave,
                          fillColor: MaterialStateProperty.all(MyColors.yellow),
                          onChanged: (bool? value) {
                            setState(() {
                              isSave = value!;
                            });
                          },
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Remeber",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  isSave = !isSave;
                                });
                              },
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            process ? null : () => {checkInput(canGo: true)},
                        child: Text("Login"),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(MyColors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                width: 0.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                child: SizedBox(
              height: double.infinity,
            )),
          ],
        ),
      ),
    );
  }
}
