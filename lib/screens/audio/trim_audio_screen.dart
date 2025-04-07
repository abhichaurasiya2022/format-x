import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class TrimAudioScreen extends StatefulWidget {
  final File selectedFile;
  const TrimAudioScreen({required this.selectedFile, super.key});

  @override
  State<TrimAudioScreen> createState() => _TrimAudioScreenState();
}

class _TrimAudioScreenState extends State<TrimAudioScreen> {
  TextEditingController _startController = TextEditingController(
    text: "00:00:00",
  );
  TextEditingController _endController = TextEditingController(
    text: "00:00:10",
  );
  bool _isProcessing = false;

  Future<void> _trimAudio() async {
    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outputPath = path.join(
      '/storage/emulated/0/Download',
      'trimmed_audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-ss',
      _startController.text,
      '-to',
      _endController.text,
      '-c',
      'copy',
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Trim Audio Result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trimmed audio saved to: $outputPath')),
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
      appBar: AppBar(title: const Text('Trim Audio')),
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
              controller: _endController,
              decoration: const InputDecoration(
                labelText: 'End Time (HH:MM:SS)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _trimAudio,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.cut),
              label: Text(_isProcessing ? 'Trimming...' : 'Trim Audio'),
            ),
          ],
        ),
      ),
    );
  }
}
