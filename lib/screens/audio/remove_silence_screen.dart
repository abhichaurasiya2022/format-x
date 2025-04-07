import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';

class RemoveSilenceScreen extends StatefulWidget {
  final File selectedFile;
  const RemoveSilenceScreen({required this.selectedFile, super.key});

  @override
  State<RemoveSilenceScreen> createState() => _RemoveSilenceScreenState();
}

class _RemoveSilenceScreenState extends State<RemoveSilenceScreen> {
  bool _isProcessing = false;

  Future<void> _removeSilence() async {
    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'nosilence_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-af',
      'silenceremove=start_periods=1:start_duration=0.5:start_threshold=-40dB:'
          'detection=peak',
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Remove Silence Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audio saved to: $outPath')));
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
      appBar: AppBar(title: const Text('Remove Silence')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _removeSilence,
            icon:
                _isProcessing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.volume_off),
            label: Text(_isProcessing ? 'Processing...' : 'Remove Silence'),
          ),
        ),
      ),
    );
  }
}
