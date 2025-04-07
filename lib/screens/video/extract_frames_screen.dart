import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class ExtractFramesScreen extends StatefulWidget {
  final File selectedFile;
  const ExtractFramesScreen({required this.selectedFile, super.key});

  @override
  State<ExtractFramesScreen> createState() => _ExtractFramesScreenState();
}

class _ExtractFramesScreenState extends State<ExtractFramesScreen> {
  double _fps = 1.0;
  bool _isProcessing = false;

  Future<void> _extractFrames() async {
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final Directory outputDir = Directory(
      '/storage/emulated/0/Download/frames_${DateTime.now().millisecondsSinceEpoch}',
    );
    await outputDir.create(recursive: true);

    final String outputPath = path.join(outputDir.path, 'frame_%03d.jpg');

    final command = [
      "-i",
      widget.selectedFile.path,
      "-vf",
      "fps=$_fps",
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Extract Frames Result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Frames saved to: ${outputDir.path}')),
      );
    } catch (e) {
      developer.log('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extract Frames')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Frames per Second (fps): ${_fps.toStringAsFixed(1)}'),
            Slider(
              value: _fps,
              min: 0.1,
              max: 30.0,
              divisions: 299,
              label: _fps.toStringAsFixed(1),
              onChanged: (value) => setState(() => _fps = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _extractFrames,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.image_outlined),
              label: Text(_isProcessing ? 'Extracting...' : 'Extract Frames'),
            ),
          ],
        ),
      ),
    );
  }
}
