import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';

class ExtractAudioSegmentScreen extends StatefulWidget {
  final File selectedFile;
  const ExtractAudioSegmentScreen({required this.selectedFile, super.key});

  @override
  State<ExtractAudioSegmentScreen> createState() =>
      _ExtractAudioSegmentScreenState();
}

class _ExtractAudioSegmentScreenState extends State<ExtractAudioSegmentScreen> {
  TextEditingController _startController = TextEditingController(
    text: "00:00:00",
  );
  TextEditingController _durationController = TextEditingController(
    text: "10",
  ); // seconds
  bool _isProcessing = false;

  Future<void> _extractSegment() async {
    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outputPath = path.join(
      '/storage/emulated/0/Download',
      'audio_segment_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command = [
      '-ss',
      _startController.text,
      '-t',
      _durationController.text,
      '-i',
      widget.selectedFile.path,
      '-acodec',
      'copy',
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Audio Segment Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Segment saved to: $outputPath')));
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
      appBar: AppBar(title: const Text('Extract Audio Segment')),
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
              decoration: const InputDecoration(
                labelText: 'Duration (seconds)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _extractSegment,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.music_note),
              label: Text(_isProcessing ? 'Extracting...' : 'Extract Segment'),
            ),
          ],
        ),
      ),
    );
  }
}
