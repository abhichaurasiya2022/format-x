import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;
import './screens/common/process_result_screen.dart';

class ConversionScreen extends StatefulWidget {
  final File selectedFile;
  final String operation;

  const ConversionScreen({
    super.key,
    required this.selectedFile,
    required this.operation,
  });

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  String? _selectedFormat;
  bool _isProcessing = false;

  List<String> _getFormats() {
    switch (widget.operation) {
      case 'Convert to MP3':
      case 'Convert to AAC':
        return ['mp3', 'aac'];
      case 'Convert Format':
        return ['mp4', 'avi', 'mkv'];
      case 'Convert to PDF':
        return ['pdf'];
      default:
        return [];
    }
  }

  Future<void> _convert() async {
    if (_selectedFormat == null) return;
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final Directory dir = Directory('/storage/emulated/0/Download/FormatX');
    final String outPath = path.join(
      dir.path,
      'converted_${DateTime.now().millisecondsSinceEpoch}.$_selectedFormat',
    );

    List<String> command = ["-i", widget.selectedFile.path];

    if (widget.operation.contains('MP3')) {
      command.addAll(["-vn", "-codec:a", "libmp3lame"]);
    } else if (widget.operation.contains('AAC')) {
      command.addAll(["-vn", "-codec:a", "aac"]);
    } else if (widget.operation == 'Convert Format') {
      if (_selectedFormat == 'mp4') {
        command.addAll(["-codec:v", "libx264", "-codec:a", "aac"]);
      } else if (_selectedFormat == 'avi') {
        command.addAll(["-codec:v", "mpeg4", "-codec:a", "mp3"]);
      } else if (_selectedFormat == 'mkv') {
        command.addAll(["-codec:v", "libx264", "-codec:a", "aac"]);
      }
    }

    command.add(outPath);

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Conversion result: $result');
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
      appBar: AppBar(title: const Text('Conversion Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              decoration: const InputDecoration(labelText: 'Target Format'),
              items:
                  _getFormats()
                      .map(
                        (f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.toUpperCase()),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedFormat = val),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _convert,
                icon:
                    _isProcessing
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.swap_horiz),
                label: Text(
                  _isProcessing ? 'Converting...' : 'Start Conversion',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
