// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:wakelock/wakelock.dart';

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
  String statusLogin = "";

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
    String _res = "OK";
    if (_res == "OK") {
      MyPrint.printWarning(MyNetwork.token);
      validateInput(context);
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
          _showDiolog(context, _res);
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
      checkInput(canGo: true);
    }
    setState(() {});
  }

  void _showDiolog(BuildContext context, String err) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors.yellow,
          title: const Text('Error'),
          content: Text(err),
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

  void validateInput(BuildContext context) async {
    setState(() {
      statusLogin = "Looking for user...";
      process = true;
    });
    String res =
        await MyNetwork().login(login: userText.text, pass: passText.text);
    if (res != "OK") {
      MyPrint.dialog(context, "Wrong credentials!",
          "Please enter right user informations!");
      setState(() {
        process = false;
      });
      return;
    }
    setState(() {
      statusLogin = "Getting Channels...";
    });
    res = await MyNetwork().getChannels();
    String crt = await storage.read(key: "currentChannel") ?? "0";
    MyNetwork.currentChanel = MyNetwork.channels[int.parse(crt)];
    if (res == "OK") {
      Navigator.pushReplacementNamed(context, '/video');
    } else {
      MyPrint.dialog(context, "Wrong credentials!",
          "Please enter right user informations!");
      setState(() {
        process = false;
      });
    }
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
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 400,
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: TextFormField(
                            enabled: !process,
                            decoration: const InputDecoration(
                              labelText: 'User',
                            ),
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Provide an user';
                              }
                              return null;
                            },
                            controller: userText,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            onEditingComplete: () =>
                                FocusScope.of(context).nextFocus()),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: TextFormField(
                          enabled: !process,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Provide an user';
                            }
                            return null;
                          },
                          controller: passText,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: isSave,
                            fillColor:
                                MaterialStateProperty.all(MyColors.yellow),
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
                        height: 100,
                        child: Center(
                          child: process
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const LinearProgressIndicator(),
                                    Text(statusLogin)
                                  ],
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    process ? null : checkInput(canGo: true);
                                  },
                                  child: const Text("Continue"),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
