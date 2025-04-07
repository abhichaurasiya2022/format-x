import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class RotateFlipImageScreen extends StatefulWidget {
  final File selectedFile;
  const RotateFlipImageScreen({required this.selectedFile, super.key});

  @override
  State<RotateFlipImageScreen> createState() => _RotateFlipImageScreenState();
}

class _RotateFlipImageScreenState extends State<RotateFlipImageScreen> {
  String? _selectedAction;
  bool _isProcessing = false;

  final Map<String, String> _actions = {
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

    final outputPath = path.join(
      '/storage/emulated/0/Download',
      'image_transformed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-vf',
      _actions[_selectedAction]!,
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Image Rotate/Flip Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image saved to: $outputPath')));
    } catch (e) {
      developer.log('Rotate/Flip Error: $e');
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
      appBar: AppBar(title: const Text('Rotate / Flip Image')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Action'),
              value: _selectedAction,
              items:
                  _actions.keys
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
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
