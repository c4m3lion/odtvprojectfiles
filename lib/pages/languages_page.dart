import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguagesPage extends StatelessWidget {
  const LanguagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Language").tr(),
        ),
        body: ListView(
          children: [
            InkWell(
              onTap: () => {
                context.setLocale(Locale('ar')),
                Navigator.pop(context),
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Image.asset(
                        'icons/flags/png/sa.png',
                        package: 'country_icons',
                        width: 60,
                      ),
                      title: Text('عربي'),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => {
                context.setLocale(Locale('az')),
                Navigator.pop(context),
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Image.asset(
                        'icons/flags/png/az.png',
                        package: 'country_icons',
                        width: 60,
                      ),
                      title: Text('Azərbaycan'),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => {
                context.setLocale(Locale('en')),
                Navigator.pop(context),
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Image.asset(
                        'icons/flags/png/us.png',
                        package: 'country_icons',
                        width: 60,
                      ),
                      title: Text('English'),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => {
                context.setLocale(Locale('uk')),
                Navigator.pop(context),
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Image.asset(
                        'icons/flags/png/ua.png',
                        package: 'country_icons',
                        width: 60,
                      ),
                      title: Text('Україна'),
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
