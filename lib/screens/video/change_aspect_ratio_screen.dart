import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class ChangeAspectRatioScreen extends StatefulWidget {
  final File selectedFile;
  const ChangeAspectRatioScreen({required this.selectedFile, super.key});

  @override
  State<ChangeAspectRatioScreen> createState() =>
      _ChangeAspectRatioScreenState();
}

class _ChangeAspectRatioScreenState extends State<ChangeAspectRatioScreen> {
  String? _selectedAspect;
  bool _isProcessing = false;

  final Map<String, String> _aspectFilters = {
    '16:9': 'pad=iw:iw*9/16:(ow-iw)/2:(oh-ih)/2',
    '1:1': 'pad=iw:max(iw\,ih):(ow-iw)/2:(oh-ih)/2',
    '9:16': 'pad=ih*9/16:ih:(ow-iw)/2:(oh-ih)/2',
  };

  Future<void> _changeAspectRatio() async {
    if (_selectedAspect == null) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outputPath = path.join(
      '/storage/emulated/0/Download',
      'aspect_${_selectedAspect!.replaceAll(':', '-')}_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-vf',
      _aspectFilters[_selectedAspect]!,
      '-c:a',
      'copy',
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Aspect Ratio Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to: $outputPath')));
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
      appBar: AppBar(title: const Text('Change Aspect Ratio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Aspect Ratio',
              ),
              value: _selectedAspect,
              items:
                  _aspectFilters.keys
                      .map(
                        (aspect) => DropdownMenuItem(
                          value: aspect,
                          child: Text(aspect),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedAspect = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _changeAspectRatio,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.aspect_ratio),
              label: Text(
                _isProcessing ? 'Processing...' : 'Change Aspect Ratio',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
