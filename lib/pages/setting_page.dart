import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            InkWell(
              onTap: () => {},
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('İstifadəçi'),
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
                      title: Text('Package'),
                      subtitle: Text("Sub1"),
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
                      title: Text('Müddəti bitir'),
                      subtitle: Text(MyNetwork.userInfo),
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
                      title: Text('Çıxış'),
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
