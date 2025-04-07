import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class ExtractAudioScreen extends StatefulWidget {
  final File selectedFile;
  final String audioFormat; // mp3, aac, wav, etc.
  const ExtractAudioScreen({
    required this.selectedFile,
    required this.audioFormat,
    super.key,
  });

  @override
  State<ExtractAudioScreen> createState() => _ExtractAudioScreenState();
}

class _ExtractAudioScreenState extends State<ExtractAudioScreen> {
  bool _isProcessing = false;

  Future<void> _extractAudio() async {
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final String outPath = path.join(
      '/storage/emulated/0/Download',
      'extracted_${DateTime.now().millisecondsSinceEpoch}.${widget.audioFormat}',
    );

    List<String> command = [
      "-i",
      widget.selectedFile.path,
      "-vn", // no video
    ];

    if (widget.audioFormat == "mp3") {
      command.addAll(["-codec:a", "libmp3lame"]);
    } else if (widget.audioFormat == "aac") {
      command.addAll(["-codec:a", "aac"]);
    } else if (widget.audioFormat == "wav") {
      command.addAll(["-codec:a", "pcm_s16le"]);
    }

    command.add(outPath);

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Extract Audio Result: $result');
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
      appBar: AppBar(
        title: Text('Extract Audio (${widget.audioFormat.toUpperCase()})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _extractAudio,
            icon:
                _isProcessing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.audio_file),
            label: Text(_isProcessing ? 'Extracting...' : 'Start Extraction'),
          ),
        ),
      ),
    );
  }
}
