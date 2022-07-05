import 'package:better_player/better_player.dart';

class MyVideoFunctions {
  static late Function setVideo;
  static late Function openSettingVideo;
  static late Function setCategory;
  static late Function changeAspectRatio;

  static int currentCategoryIndex = 1;
  static int currentCategoryofChannelIndex = 1;
  static int currentChannelIndex = 0;

  static double aspectRatio = 16 / 9;
  static String bitrate = "Auto";

  static BetterPlayerController? videoController;
}
