import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/pages/newPages/chanelpage.dart';
import 'package:odtvprojectfiles/pages/newPages/newSettingPage.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String formattedDate = "";
  Widget currentPage = ChannelsPage();

  @override
  void initState() {
    // TODO: implement initState
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);

    setState(() {
      formattedDate = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy \n hh:mm:ss').format(dateTime);
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: 100,
                ),
                color: Colors.black,
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        selected: 0 == _selectedIndex,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 0;
                            currentPage = ChannelsPage();
                          });
                        },
                        title: Image.asset(
                          "assets/images/channels-icon.png",
                          height: 30,
                          color: 0 == _selectedIndex
                              ? MyPaints.selectedColor
                              : null,
                        ),
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        selected: 1 == _selectedIndex,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                            currentPage = SettingPage();
                          });
                        },
                        title: Image.asset(
                          "assets/images/settings-icon.png",
                          height: 30,
                          color: 1 == _selectedIndex
                              ? MyPaints.selectedColor
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: currentPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
