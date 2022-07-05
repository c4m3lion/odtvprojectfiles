import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/main.dart';
import 'package:odtvprojectfiles/main_old.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class DeviceSelectionPageTv extends StatefulWidget {
  const DeviceSelectionPageTv({Key? key}) : super(key: key);

  @override
  State<DeviceSelectionPageTv> createState() => _DeviceSelectionPageState();
}

class _DeviceSelectionPageState extends State<DeviceSelectionPageTv> {
  void onInit() async {
    String dev = await MyFunctions().getStorage("device1");
    if (dev == "Android") {
      Navigator.pushReplacementNamed(context, "/login");
    }
    if (dev == "TV") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ));
    }
  }

  @override
  void initState() {
    onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
            ),
            Text(
              "Choose you device:",
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(
              height: 100,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth > 600) {
                    return buildRow();
                  } else {
                    return buildColumn();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 100,
          onPressed: () {
            MyFunctions().saveStorage("device", "TV");
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ));
          },
          icon: ImageIcon(
            AssetImage("assets/images/channels-icon.png"),
            color: Color(0xFF3A5A98),
          ),
        ),
        SizedBox(
          width: 100,
        ),
        IconButton(
          iconSize: 100,
          onPressed: () {
            MyFunctions().saveStorage("device", "Android");
            Navigator.pushReplacementNamed(context, "/login");
          },
          icon: ImageIcon(
            AssetImage("assets/images/telephone-image.png"),
            color: Color(0xFF3A5A98),
          ),
        )
      ],
    );
  }

  Widget buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          iconSize: 150,
          onPressed: () {
            MyFunctions().saveStorage("device", "Android");
            Navigator.pushReplacementNamed(context, "/login");
          },
          icon: ImageIcon(
            AssetImage("assets/images/telephone-image.png"),
            color: Color(0xFF3A5A98),
          ),
        ),
        SizedBox(
          height: 100,
        ),
        IconButton(
          iconSize: 100,
          onPressed: () {
            MyFunctions().saveStorage("device", "TV");
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ));
          },
          icon: ImageIcon(
            AssetImage("assets/images/channels-icon.png"),
            color: Color(0xFF3A5A98),
          ),
        ),
      ],
    );
  }
}
