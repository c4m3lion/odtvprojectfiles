// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void loadDatas() async {
    String _res = await MyNetwork().getChannels();
    if (_res == "OK") {
    } else {
      _showAlert(context, _res);
    }
    String _res2 = await MyNetwork().getFavorites();
    if (_res2 == "OK") {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      _showAlert(context, _res2);
    }
  }

  void loadVideo() async {
    MyNetwork.currentChanel.playBackUrl = await MyNetwork().getPlayBack();
    await MyNetwork().getEPG();
    if (MyNetwork.favorites
        .where(((element) =>
            element.id.toLowerCase().contains(MyNetwork.currentChanel.id)))
        .isNotEmpty) {
      MyNetwork.currentChanel.isFavorite = true;
    }
    await Navigator.pushReplacementNamed(context, '/video');
  }

  void _showAlert(BuildContext context, String err) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(err),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.repeat();
    if (MyNetwork.isVideoPlaying) {
      loadVideo();
    } else {
      loadDatas();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
        // RotationTransition(
        //   turns: Tween(begin: 1.0, end: 0.0).animate(_controller),
        //   child: Image(
        //     image: AssetImage("assets/icons/loadingicon.png"),
        //   ),
        // ),
      ),
    );
  }
}
