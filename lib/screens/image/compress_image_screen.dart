import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class CompressImageScreen extends StatefulWidget {
  final File selectedFile;
  const CompressImageScreen({required this.selectedFile, super.key});

  @override
  State<CompressImageScreen> createState() => _CompressImageScreenState();
}

class _CompressImageScreenState extends State<CompressImageScreen> {
  double _quality = 75;
  bool _isProcessing = false;

  Future<void> _compressImage() async {
    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outputPath = path.join(
      '/storage/emulated/0/Download',
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final command = [
      '-i', widget.selectedFile.path,
      '-q:v', (_quality / 10).toStringAsFixed(1), // Lower = better quality
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Compress Image Result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compressed image saved to: $outputPath')),
      );
    } catch (e) {
      developer.log('Compression Error: $e');
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
      appBar: AppBar(title: const Text('Compress Image')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Compression Quality: ${_quality.toInt()}%'),
            Slider(
              value: _quality,
              min: 10,
              max: 100,
              divisions: 90,
              label: '${_quality.toInt()}%',
              onChanged: (val) => setState(() => _quality = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _compressImage,
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
