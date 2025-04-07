import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class RotateFlipScreen extends StatefulWidget {
  final File selectedFile;
  const RotateFlipScreen({required this.selectedFile, super.key});

  @override
  State<RotateFlipScreen> createState() => _RotateFlipScreenState();
}

class _RotateFlipScreenState extends State<RotateFlipScreen> {
  String? _selectedAction;
  bool _isProcessing = false;

  final Map<String, String> _actionFilters = {
    'Rotate 90°': 'transpose=1',
    'Rotate 180°': 'transpose=1,transpose=1',
    'Rotate 270°': 'transpose=2',
    'Flip Horizontal': 'hflip',
    'Flip Vertical': 'vflip',
  };

  Future<void> _applyTransform() async {
    if (_selectedAction == null) return;
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final String outPath = path.join(
      '/storage/emulated/0/Download',
      'transformed_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-vf',
      _actionFilters[_selectedAction]!,
      '-c:a',
      'copy',
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Rotate/Flip Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to: $outPath')));
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
      appBar: AppBar(title: const Text('Rotate / Flip Video')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Action'),
              value: _selectedAction,
              items:
                  _actionFilters.keys
                      .map(
                        (action) => DropdownMenuItem(
                          value: action,
                          child: Text(action),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedAction = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _applyTransform,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.rotate_90_degrees_ccw),
              label: Text(_isProcessing ? 'Processing...' : 'Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
