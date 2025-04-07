import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;
import './screens/common/process_result_screen.dart';


class CompressionScreen extends StatefulWidget {
  final File selectedFile;
  const CompressionScreen({required this.selectedFile, super.key});

  @override
  State<CompressionScreen> createState() => _CompressionScreenState();
}

class _CompressionScreenState extends State<CompressionScreen> {
  double _compressionLevel = 50.0;
  bool _isProcessing = false;

  Future<void> _compress() async {
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final dir = Directory('/storage/emulated/0/Download/FormatX');
    final String outPath = path.join(
      dir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    List<String> command = [
      "-i",
      widget.selectedFile.path,
      "-q:v",
      _compressionLevel.toString(),
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Compression Result: $result');
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => ProcessResultScreen(outputPath: outPath)),
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
      appBar: AppBar(title: const Text('Compression Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compression Level: ${_compressionLevel.toInt()}%'),
            Slider(
              value: _compressionLevel,
              min: 0,
              max: 100,
              divisions: 100,
              label: _compressionLevel.toInt().toString(),
              onChanged: (val) => setState(() => _compressionLevel = val),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _compress,
                icon:
                    _isProcessing
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.compress),
                label: Text(
                  _isProcessing ? 'Compressing...' : 'Start Compression',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
