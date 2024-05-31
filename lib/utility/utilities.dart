import 'dart:io';

import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getLocalPath() async {
  Directory tmpDocDir = await getTemporaryDirectory();
  print(tmpDocDir.path);
  return tmpDocDir.path;
}

Future<Map<String, dynamic>?> getVideoMetadata(String videoFilePath) async {
  final videoInfo =
      await FlutterVideoInfo().getVideoInfo(videoFilePath) as VideoData;
  if ((videoInfo.orientation! ~/ 90) % 2 == 1) {
    return {
      'width': videoInfo.height,
      'height': videoInfo.width,
      'fps': videoInfo.framerate,
    };
  } else {
    return {
      'width': videoInfo.width,
      'height': videoInfo.height,
      'fps': videoInfo.framerate,
    };
  }
}

Future<void> removeFFmpegFiles() async {
  final localDirectory = await getTemporaryDirectory();
  for (var entry
      in localDirectory.listSync(recursive: true, followLinks: false)) {
    final fileName = entry.path.split('/').last;
    if (fileName.startsWith(CommonValue.filePrefix)) {
      entry.deleteSync();
    }
  }
}

class CommonValue {
  static String filePrefix = 'ffmpeg_';
}
