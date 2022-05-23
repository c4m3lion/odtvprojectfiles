import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userText = TextEditingController();
  final passText = TextEditingController();
  final keyForm = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  bool facebokSelected = false;

  bool isSave = false;
  bool loading = false;
  String loadingStatus = "loading...";

  //Functions
  void processLogin() async {
    if (loading) return;

    setState(() {
      loading = true;
      loadingStatus = "Searching for User...";
    });

    if (!keyForm.currentState!.validate()) {
      setState(() {
        loading = false;
      });
      return;
    }

    var user = userText.text;
    var pass = passText.text;

    if (isSave) {
      await storage.write(key: "user", value: user);
      await storage.write(key: "pass", value: pass);
    } else {
      await storage.delete(key: "user");
      await storage.delete(key: "pass");
    }
    await storage.write(key: "isSave", value: isSave.toString());

    String _result = await MyNetwork().login(login: user, pass: pass);
    if (_result != "OK") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_result)),
      );
      setState(() {
        loading = false;
      });
      return;
    }

    loadingStatus = "Getting Channels...";
    setState(() {});

    _result = await MyNetwork().getChannels();
    if (_result != "OK") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_result)),
      );
      setState(() {
        loading = false;
      });
      return;
    }
    String crt = await storage.read(key: "currentChannel") ?? "0";
    MyNetwork().loadChannelById(crt);

    Navigator.pushReplacementNamed(context, '/TvVideoPage');
  }

  void _launchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) throw 'Could not launch $_url';
  }

  void onInit() async {
    loading = false;
    userText.text = "";
    passText.text = "";
    String _issave = await storage.read(key: "isSave") ?? "false";
    isSave = _issave == "true" ? true : false;

    if (isSave) {
      userText.text = (await storage.read(key: "user")) ?? "";
      passText.text = (await storage.read(key: "pass")) ?? "";
      setState(() {});
      processLogin();
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: keyForm,
        child: Center(
          child: SizedBox(
            width: 400,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Log in".tr(),
                        style: const TextStyle(fontSize: 30),
                      ),
                      const Divider(indent: 16),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: TextFormField(
                          enabled: !loading,
                          decoration: InputDecoration(
                            labelText: 'User'.tr(),
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Provide an user'.tr();
                            }
                            return null;
                          },
                          controller: userText,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: TextFormField(
                          enabled: !loading,
                          decoration: InputDecoration(
                            labelText: 'Password'.tr(),
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Provide an password'.tr();
                            }
                            return null;
                          },
                          controller: passText,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      loading
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 25),
                              child: Column(
                                children: [
                                  LinearProgressIndicator(),
                                  Text(loadingStatus),
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 60),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: isSave,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isSave = value!;
                                          });
                                        },
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: "Remember".tr(),
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
                                  ElevatedButton(
                                    onPressed: () => processLogin(),
                                    child: Text("Sign in").tr(),
                                  ),
                                ],
                              ),
                            ),
                      const Divider(indent: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onFocusChange: (value) {
                              setState(() {
                                facebokSelected = value;
                              });
                            },
                            child: CircleAvatar(
                              radius: facebokSelected ? 30 : 20,
                              backgroundImage: AssetImage(
                                'assets/icons/facebook_icon.png',
                              ),
                            ),
                            onTap: () {
                              _launchUrl(
                                  "https://www.facebook.com/Smartsystemstechnology");
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                              'assets/icons/telephone.png',
                            ),
                          ),
                          Text("012952"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
