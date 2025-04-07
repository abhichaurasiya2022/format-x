import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;
import '../common/process_result_screen.dart';

class CompressAudioScreen extends StatefulWidget {
  final File selectedFile;
  const CompressAudioScreen({required this.selectedFile, super.key});

  @override
  State<CompressAudioScreen> createState() => _CompressAudioScreenState();
}

class _CompressAudioScreenState extends State<CompressAudioScreen> {
  String _selectedBitrate = '128k';
  bool _isProcessing = false;

  final List<String> _bitrates = ['320k', '192k', '128k', '96k', '64k'];

  Future<void> _compressAudio() async {
    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'compressed_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-b:a',
      _selectedBitrate,
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Compress Audio Result: $result');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProcessResultScreen(outputPath: outPath),
        ),
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
      appBar: AppBar(title: const Text('Compress Audio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Bitrate'),
              value: _selectedBitrate,
              items:
                  _bitrates
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
              onChanged: (val) => setState(() => _selectedBitrate = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _compressAudio,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.compress),
              label: Text(_isProcessing ? 'Compressing...' : 'Compress'),
            ),
          ],
        ),
      ),
    );
  }
}
