import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Settings").tr()),
        body: ListView(
          children: [
            InkWell(
              onTap: () => {},
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('User').tr(),
                      subtitle: Text(MyNetwork.userInfo),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => {},
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Package').tr(),
                      subtitle: Text("Sub1").tr(),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => {},
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Expires').tr(),
                      subtitle: Text(MyNetwork.userInfo),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/language');
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Language').tr(),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                FlutterSecureStorage storage = FlutterSecureStorage();

                await storage.deleteAll();
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", ModalRoute.withName('/'));
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Log out').tr(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
