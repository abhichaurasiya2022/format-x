import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class AddSubtitlesScreen extends StatefulWidget {
  final File selectedFile;
  const AddSubtitlesScreen({required this.selectedFile, super.key});

  @override
  State<AddSubtitlesScreen> createState() => _AddSubtitlesScreenState();
}

class _AddSubtitlesScreenState extends State<AddSubtitlesScreen> {
  File? _subtitleFile;
  bool _isProcessing = false;

  Future<void> _pickSubtitle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _subtitleFile = File(result.files.single.path!));
    }
  }

  Future<void> _addSubtitles() async {
    if (_subtitleFile == null) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'subtitled_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-vf',
      "subtitles='${_subtitleFile!.path}'",
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Subtitles Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video saved to: $outPath')));
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
      appBar: AppBar(title: const Text('Add Subtitles')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickSubtitle,
              icon: const Icon(Icons.subtitles),
              label: const Text('Select SRT File'),
            ),
            const SizedBox(height: 10),
            if (_subtitleFile != null) Text(path.basename(_subtitleFile!.path)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _addSubtitles,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.closed_caption),
              label: Text(_isProcessing ? 'Processing...' : 'Add Subtitles'),
            ),
          ],
        ),
      ),
    );
  }
}
