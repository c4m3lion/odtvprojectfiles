// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userText = TextEditingController();
  final passText = TextEditingController();
  bool isSave = false;
  bool _validateUser = false;
  bool _validatePass = false;

  ///Functions///////////////////////////////

  void checkInput({bool canGo = false}) {
    _validateUser = false;
    _validatePass = false;
    if (userText.text.isEmpty) {
      _validateUser = true;
    }
    if (!canGo) {
      setState(() {});
      return;
    }
    if (passText.text.isEmpty) {
      _validatePass = true;
    }
    setState(() {});
    if (!_validatePass && !_validateUser) {
      getDatas();
    }
  }

  void getDatas() {}

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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: MyColors.orange)),
                          filled: true,
                          fillColor: MyColors.yellow,
                          focusColor: MyColors.cyan,
                          hintText: "Enter login",
                          //labelText: "User",
                          errorText:
                              _validateUser ? 'Value Can\'t Be Empty' : null,
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: MyColors.orange)),
                        filled: true,
                        fillColor: MyColors.yellow,
                        focusColor: MyColors.cyan,
                        hintText: "Enter password",
                        //labelText: "User",
                        errorText:
                            _validatePass ? 'Value Can\'t Be Empty' : null,
                      ),
                      controller: passText,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      onSubmitted: (value) {
                        checkInput(canGo: true);
                      },
                    ),
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
                        onPressed: () => {checkInput(canGo: true)},
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
