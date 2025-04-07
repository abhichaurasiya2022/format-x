import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';

class NormalizeAudioScreen extends StatefulWidget {
  final File selectedFile;
  const NormalizeAudioScreen({required this.selectedFile, super.key});

  @override
  State<NormalizeAudioScreen> createState() => _NormalizeAudioScreenState();
}

class _NormalizeAudioScreenState extends State<NormalizeAudioScreen> {
  bool _isProcessing = false;

  Future<void> _normalizeAudio() async {
    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'normalized_audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-af',
      'loudnorm',
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Normalize Result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Normalized audio saved to: $outPath')),
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
      appBar: AppBar(title: const Text('Normalize Volume')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _normalizeAudio,
            icon:
                _isProcessing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.volume_up),
            label: Text(_isProcessing ? 'Normalizing...' : 'Normalize'),
          ),
        ),
      ),
    );
  }
}
