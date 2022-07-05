import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff4A4A4A).withOpacity(0.70),
      child: Scrollbar(
        //controller: _controller,
        child: ListView(
          /// You can add a padding to the view to avoid having the scrollbar over the UI elements
          padding: const EdgeInsets.only(right: 16.0),
          children: [
            Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () => {},
                leading: const Icon(
                  Icons.verified_user,
                  size: 30,
                ),
                title: const Text('User').tr(),
                subtitle: Text(MyNetwork.userInfo),
                isThreeLine: true,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () => {},
                leading: const Icon(
                  Icons.app_registration,
                  size: 30,
                ),
                title: const Text('Version').tr(),
                subtitle: const Text('v0.0.1'),
                isThreeLine: true,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () async {
                  await Navigator.pushNamed(context, '/language');
                  setState(() {});
                },
                leading: const Icon(
                  Icons.language,
                  size: 30,
                ),
                title: const Text('Language').tr(),
                subtitle: const Text('Change app language').tr(),
                isThreeLine: true,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/device', (Route<dynamic> route) => false);
                },
                leading: const Icon(
                  Icons.devices,
                  size: 30,
                ),
                title: const Text('Change device').tr(),
                subtitle: const Text(""),
                isThreeLine: true,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () async {
                  FlutterSecureStorage storage = FlutterSecureStorage();
                  await storage.deleteAll();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false);
                },
                leading: const Icon(
                  Icons.logout,
                  size: 30,
                ),
                title: const Text('Log out').tr(),
                subtitle: const Text(""),
                isThreeLine: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
