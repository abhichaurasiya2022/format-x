import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class AddWatermarkScreen extends StatefulWidget {
  final File selectedFile;
  const AddWatermarkScreen({required this.selectedFile, super.key});

  @override
  State<AddWatermarkScreen> createState() => _AddWatermarkScreenState();
}

class _AddWatermarkScreenState extends State<AddWatermarkScreen> {
  File? _watermarkFile;
  String _position = 'top-right';
  bool _isProcessing = false;

  final Map<String, String> _positionMap = {
    'top-left': '10:10',
    'top-right': 'main_w-overlay_w-10:10',
    'bottom-left': '10:main_h-overlay_h-10',
    'bottom-right': 'main_w-overlay_w-10:main_h-overlay_h-10',
  };

  Future<void> _pickWatermark() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _watermarkFile = File(result.files.single.path!));
    }
  }

  Future<void> _addWatermark() async {
    if (_watermarkFile == null) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outputPath = path.join(
      '/storage/emulated/0/Download',
      'watermarked_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-i',
      _watermarkFile!.path,
      '-filter_complex',
      'overlay=${_positionMap[_position]}',
      '-codec:a',
      'copy',
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Watermark Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video saved to: $outputPath')));
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
      appBar: AppBar(title: const Text('Add Watermark')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickWatermark,
              icon: const Icon(Icons.image),
              label: const Text('Select Watermark Image'),
            ),
            const SizedBox(height: 10),
            if (_watermarkFile != null)
              Text(path.basename(_watermarkFile!.path)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Watermark Position',
              ),
              value: _position,
              items:
                  _positionMap.keys
                      .map(
                        (pos) => DropdownMenuItem(value: pos, child: Text(pos)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _position = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _addWatermark,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.water),
              label: Text(_isProcessing ? 'Processing...' : 'Add Watermark'),
            ),
          ],
        ),
      ),
    );
  }
}
