import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class PhoneEpgInfo extends StatelessWidget {
  // In the constructor, require a Todo.
  const PhoneEpgInfo({Key? key, required this.epg}) : super(key: key);
  // Step 2 <-- SEE HERE
  final EPG epg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000).withOpacity(0.50),
      body: Center(
        child: Card(
          child: SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                ),
                Text(epg.title),
                Text("${epg.startdt} - ${epg.enddt}"),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    epg.description.toLowerCase(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
