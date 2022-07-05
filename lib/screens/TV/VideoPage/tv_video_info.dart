import 'dart:io';
import 'dart:ui';

import 'package:better_player/better_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraction/fraction.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tvsetting/change_aspect_ratio.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:better_player/src/core/better_player_utils.dart';
import 'package:better_player/src/controls/better_player_clickable_widget.dart';

class TvVideoInfo extends StatefulWidget {
  const TvVideoInfo({Key? key}) : super(key: key);

  @override
  State<TvVideoInfo> createState() => _TvVideoInfoState();
}

class _TvVideoInfoState extends State<TvVideoInfo> {
  FocusNode focusNode = FocusNode();
  EPG currentActiveEPG = EPG();

  EPG getCurrentEPG() {
    for (int i = 0; i < MyNetwork.currectEPG.length; i++) {
      bool temp = DateTime.now().isAfter(MyNetwork.currectEPG[i].startDate) &&
          DateTime.now().isBefore(MyNetwork.currectEPG[i].endDate);

      if (temp) {
        currentActiveEPG = MyNetwork.currectEPG[i];
        return MyNetwork.currectEPG[i];
      }
    }
    currentActiveEPG = EPG();
    return EPG();
  }

  void addFav({required String id}) async {
    setState(() {});
    if (!MyNetwork.currentChanel.isFavorite) {
      MyNetwork.currentChanel.isFavorite = true;
      setState(() {});
      String k = await MyNetwork().addFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = true;
      }
    } else {
      MyNetwork.currentChanel.isFavorite = false;
      setState(() {});
      String k = await MyNetwork().removeFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = false;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
        canRequestFocus: false,
        onKey: (node, RawKeyEvent event) {
          if (event.runtimeType == RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.contextMenu ||
                event.logicalKey == LogicalKeyboardKey.keyS) {
              Navigator.pop(context);
              return KeyEventResult.handled;
            }
          }
          // if (event.logicalKey == LogicalKeyboardKey.contextMenu) {
          //   try {
          //     if (event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
          //       Navigator.pop(context);
          //     }
          //   } catch (e) {
          //     print(e);
          //   }
          //   if (event.physicalKey == PhysicalKeyboardKey.metaLeft) {
          //     print("sdasdas");
          //     Navigator.pop(context);
          //   }
          // }
          if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) ||
              event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000).withOpacity(0.50),
      body: Focus(
        focusNode: focusNode,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      ListTile(
                        leading: FadeInImage.assetNetwork(
                          placeholder: "assets/images/page.png",
                          image: MyNetwork.currentChanel.icon,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/page.png',
                                fit: BoxFit.fitWidth);
                          },
                        ),
                        title: Text(
                            (MyNetwork.currentChanel.pos + 1).toString() +
                                ". " +
                                MyNetwork.currentChanel.name),
                        subtitle: Text(getCurrentEPG().title != ""
                            ? getCurrentEPG().title
                            : "No EPG".tr()),
                        trailing: MyNetwork.currentChanel.isFavorite
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border_outlined),
                      ),
                      currentActiveEPG.title != ""
                          ? Text(currentActiveEPG.startdt +
                              " - " +
                              currentActiveEPG.enddt)
                          : SizedBox(),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          getCurrentEPG().description.toLowerCase(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        autofocus: true,
                        leading: MyNetwork.currentChanel.isFavorite
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border_outlined),
                        title: Text(MyNetwork.currentChanel.isFavorite
                                ? "Remove from favorites".tr()
                                : "Add to favorites".tr())
                            .tr(),
                        onTap: () {
                          addFav(id: MyNetwork.currentChanel.id);

                          setState(() {});
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.aspect_ratio),
                        title: Text("Aspect ratio").tr(),
                        subtitle: Text(MyVideoFunctions.aspectRatio
                            .toFraction()
                            .toString()),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                PageRouteBuilder(
                                  opaque: false, // set to false
                                  pageBuilder: (_, __, ___) =>
                                      TvChangeResolution(),
                                ),
                              )
                              .then((value) => setState(() {}));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.network_check_sharp),
                        title: Text("Bitrate").tr(),
                        subtitle: Text(
                          "${MyVideoFunctions.bitrate}",
                        ),
                        onTap: () {
                          _showQualitiesSelectionWidget();
                        },
                      ),
                      // ListTile(
                      //   leading: Icon(Icons.screenshot_monitor_rounded),
                      //   title: Text("Resolution").tr(),
                      //   subtitle: Text(
                      //       "${window.physicalSize.width.toString().replaceAll(('.0'), '')}x${window.physicalSize.height.toString().replaceAll(('.0'), '')}"),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Build both track and resolution selection
  ///Track selection is used for HLS / DASH videos
  ///Resolution selection is used for normal videos
  void _showQualitiesSelectionWidget() {
    // HLS / DASH
    final List<String> asmsTrackNames = MyVideoFunctions
            .videoController!.betterPlayerDataSource!.asmsTrackNames ??
        [];
    final List<BetterPlayerAsmsTrack> asmsTracks =
        MyVideoFunctions.videoController!.betterPlayerAsmsTracks;
    final List<Widget> children = [];
    for (var index = 0; index < asmsTracks.length; index++) {
      final track = asmsTracks[index];

      String? preferredName;
      if (track.height == 0 && track.width == 0 && track.bitrate == 0) {
        preferredName =
            MyVideoFunctions.videoController!.translations.qualityAuto;
      } else {
        preferredName =
            asmsTrackNames.length > index ? asmsTrackNames[index] : null;
      }
      children.add(_buildTrackRow(asmsTracks[index], preferredName));
    }

    // // normal videos
    // final resolutions =
    //     MyVideoFunctions.videoController!.betterPlayerDataSource!.resolutions;
    // resolutions?.forEach((key, value) {
    //   children.add(_buildResolutionSelectionRow(key, value));
    // });

    if (children.isEmpty) {
      children.add(
        _buildTrackRow(BetterPlayerAsmsTrack.defaultTrack(),
            MyVideoFunctions.videoController!.translations.qualityAuto),
      );
    }

    _showMaterialBottomSheet(children);
  }

  Widget _buildTrackRow(BetterPlayerAsmsTrack track, String? preferredName) {
    final int width = track.width ?? 0;
    final int height = track.height ?? 0;
    final int bitrate = track.bitrate ?? 0;
    final String mimeType = (track.mimeType ?? '').replaceAll('video/', '');
    final String trackName = preferredName ??
        "${width}x$height ${BetterPlayerUtils.formatBitrate(bitrate)} $mimeType";

    final BetterPlayerAsmsTrack? selectedTrack =
        MyVideoFunctions.videoController!.betterPlayerAsmsTrack;
    final bool isSelected = selectedTrack != null && selectedTrack == track;

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        MyVideoFunctions.bitrate = trackName;
        print(trackName);
        Navigator.of(context).pop();
        MyVideoFunctions.videoController!.setTrack(track);
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_outlined,
                  color: MyVideoFunctions.videoController!
                      .betterPlayerControlsConfiguration.overflowModalTextColor,
                )),
            const SizedBox(width: 16),
            Text(
              trackName,
              //style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialBottomSheet(List<Widget> children) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      useRootNavigator: MyVideoFunctions
              .videoController?.betterPlayerConfiguration.useRootNavigator ??
          false,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}
