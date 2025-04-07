import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;
import '../common/process_result_screen.dart';
class ConvertAudioScreen extends StatefulWidget {
  final File selectedFile;
  const ConvertAudioScreen({required this.selectedFile, super.key});

  @override
  State<ConvertAudioScreen> createState() => _ConvertAudioScreenState();
}

class _ConvertAudioScreenState extends State<ConvertAudioScreen> {
  String? _selectedFormat;
  bool _isProcessing = false;

  final List<String> _formats = ['mp3', 'aac', 'wav', 'ogg', 'flac', 'm4a'];

  Future<void> _convertAudio() async {
    if (_selectedFormat == null) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'converted_${DateTime.now().millisecondsSinceEpoch}.$_selectedFormat',
    );

    List<String> command = ['-i', widget.selectedFile.path];

    switch (_selectedFormat) {
      case 'mp3':
        command.addAll(['-codec:a', 'libmp3lame']);
        break;
      case 'aac':
        command.addAll(['-codec:a', 'aac']);
        break;
      case 'wav':
        command.addAll(['-codec:a', 'pcm_s16le']);
        break;
      case 'ogg':
        command.addAll(['-codec:a', 'libvorbis']);
        break;
      case 'flac':
        command.addAll(['-codec:a', 'flac']);
        break;
      case 'm4a':
        command.addAll(['-codec:a', 'aac']);
        break;
    }

    command.add(outPath);

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Convert Audio Result: $result');
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
      appBar: AppBar(title: const Text('Convert Audio Format')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Target Format'),
              value: _selectedFormat,
              items:
                  _formats
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
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _convertAudio,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.audiotrack),
              label: Text(_isProcessing ? 'Converting...' : 'Convert'),
            ),
          ],
        ),
      ),
    );
  }
}
