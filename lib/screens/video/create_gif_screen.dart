import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class CreateGifScreen extends StatefulWidget {
  final File selectedFile;
  const CreateGifScreen({required this.selectedFile, super.key});

  @override
  State<CreateGifScreen> createState() => _CreateGifScreenState();
}

class _CreateGifScreenState extends State<CreateGifScreen> {
  TextEditingController _startController = TextEditingController(
    text: "00:00:00",
  );
  TextEditingController _durationController = TextEditingController(
    text: "5",
  ); // seconds
  bool _isProcessing = false;

  Future<void> _createGif() async {
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final String outPath = path.join(
      '/storage/emulated/0/Download',
      'gif_${DateTime.now().millisecondsSinceEpoch}.gif',
    );

    final command = [
      "-ss",
      _startController.text,
      "-t",
      _durationController.text,
      "-i",
      widget.selectedFile.path,
      "-vf",
      "fps=10,scale=320:-1:flags=lanczos",
      "-loop",
      "0",
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('GIF Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('GIF saved to: $outPath')));
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
      appBar: AppBar(title: const Text('Create GIF')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _startController,
              decoration: const InputDecoration(
                labelText: 'Start Time (HH:MM:SS)',
              ),
            ),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (seconds)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _createGif,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.gif),
              label: Text(_isProcessing ? 'Creating...' : 'Create GIF'),
            ),
          ],
        ),
      ),
    );
  }
}
