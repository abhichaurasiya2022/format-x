import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';

class MergeVideosScreen extends StatefulWidget {
  const MergeVideosScreen({super.key});

  @override
  State<MergeVideosScreen> createState() => _MergeVideosScreenState();
}

class _MergeVideosScreenState extends State<MergeVideosScreen> {
  List<File> _selectedFiles = [];
  bool _isProcessing = false;

  Future<void> _pickVideos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result != null) {
      final files = result.paths.map((path) => File(path!)).toList();
      setState(() => _selectedFiles = files);
    }
  }

  Future<void> _mergeVideos() async {
    if (_selectedFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 videos to merge')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final tempDir = Directory('/storage/emulated/0/Download');
    final listFile = File('${tempDir.path}/file_list.txt');

    final listContent = _selectedFiles
        .map((file) => "file '${file.path.replaceAll("'", "'\\''")}'")
        .join('\n');
    await listFile.writeAsString(listContent);

    final outputPath = path.join(
      tempDir.path,
      'merged_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final command = [
      '-f',
      'concat',
      '-safe',
      '0',
      '-i',
      listFile.path,
      '-c',
      'copy',
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Merge Result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merged video saved to: $outputPath')),
      );
    } catch (e) {
      developer.log('Merge Error: $e');
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
      appBar: AppBar(title: const Text('Merge Videos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickVideos,
              icon: const Icon(Icons.video_collection),
              label: const Text('Select Videos to Merge'),
            ),
            const SizedBox(height: 10),
            if (_selectedFiles.isNotEmpty)
              Text('${_selectedFiles.length} files selected'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _mergeVideos,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.merge_type),
              label: Text(_isProcessing ? 'Merging...' : 'Merge Videos'),
            ),
          ],
        ),
      ),
    );
  }
}
