import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class ChangeResolutionScreen extends StatefulWidget {
  final File selectedFile;
  const ChangeResolutionScreen({required this.selectedFile, super.key});

  @override
  State<ChangeResolutionScreen> createState() => _ChangeResolutionScreenState();
}

class _ChangeResolutionScreenState extends State<ChangeResolutionScreen> {
  String? _selectedResolution;
  bool _isProcessing = false;

  final Map<String, String> resolutionMap = {
    '480p': '854x480',
    '720p': '1280x720',
    '1080p': '1920x1080',
    '4K': '3840x2160',
  };

  Future<void> _changeResolution() async {
    if (_selectedResolution == null) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final String outPath = path.join(
      '/storage/emulated/0/Download',
      'resized_${_selectedResolution}_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-vf',
      'scale=${resolutionMap[_selectedResolution]}',
      '-c:a',
      'copy',
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Resolution Change Result: $result');
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
      appBar: AppBar(title: const Text('Change Resolution')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Resolution'),
              value: _selectedResolution,
              items:
                  resolutionMap.keys.map((res) {
                    return DropdownMenuItem(value: res, child: Text(res));
                  }).toList(),
              onChanged: (val) => setState(() => _selectedResolution = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _changeResolution,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.high_quality),
              label: Text(
                _isProcessing ? 'Processing...' : 'Change Resolution',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
