import 'package:flutter/material.dart';
import 'package:flutter_mlkit_video/model/mlkit_video_converter.dart';
import 'package:flutter_mlkit_video/utility/utilities.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class VideoConvertView extends StatefulWidget {
  const VideoConvertView({super.key, this.videoXFile});
  final XFile? videoXFile;

  @override
  State<VideoConvertView> createState() => _VideoConvertViewState();
}

class _VideoConvertViewState extends State<VideoConvertView> {
  late Future<void> _future;

  var _busy = false;
  var _progress = 0.0;

  Future<void> _convertVideo() async {
    if (!_busy) {
      _busy = true;

      final videoFilePath = widget.videoXFile?.path;
      if (videoFilePath == null) return;

      final localPath = await getLocalPath();

      await removeFFmpegFiles();

      final mlkitVideoConverter = MlkitVideoConverter();
      await mlkitVideoConverter.initialize(
        localPath: localPath,
        videoFilePath: videoFilePath,
      );
      final frameImageFiles = await mlkitVideoConverter.convertVideoToFrames();
      if (frameImageFiles != null) {
        for (var index = 0; index < frameImageFiles.length; index++) {
          final file = frameImageFiles[index];
          await mlkitVideoConverter.paintLandmarks(frameFileDirPath: file.path);
          setState(() => _progress = index / frameImageFiles.length);
        }
      }
      final exportFilePath = await mlkitVideoConverter.createVideoFromFrames();
      if (exportFilePath != null) {
        await ImageGallerySaver.saveFile(exportFilePath);
      }
      await removeFFmpegFiles();

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: const Text('Saved to camera roll'),
            actions: [
              TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context)),
            ],
          );
        },
      );

      _busy = false;
    }
  }

  Widget _progressView(double value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Exporting'),
        const SizedBox(height: 16),
        CircularProgressIndicator(
          value: value,
          backgroundColor: Colors.black12,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _convertVideo();
  }

  @override
  Widget build(BuildContext context) {
    return widget.videoXFile == null
        ? Container(
            alignment: Alignment.center,
            child: const Text('Please choose a file'),
          )
        : FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  alignment: Alignment.center,
                  child: _progressView(_progress),
                );
              } else if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: const Text('Saved to camera roll'),
                );
              }
            },
          );
  }
}
