import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class ChangeFramerateScreen extends StatefulWidget {
  final File selectedFile;
  const ChangeFramerateScreen({required this.selectedFile, super.key});

  @override
  State<ChangeFramerateScreen> createState() => _ChangeFramerateScreenState();
}

class _ChangeFramerateScreenState extends State<ChangeFramerateScreen> {
  String? _selectedFps;
  bool _isProcessing = false;

  final List<String> _fpsOptions = ['15', '24', '30', '60'];

  Future<void> _changeFramerate() async {
    if (_selectedFps == null) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final String outPath = path.join(
      '/storage/emulated/0/Download',
      'fps_${_selectedFps}_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-filter:v',
      'fps=fps=$_selectedFps',
      '-c:a',
      'copy',
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('FPS Change Result: $result');
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
      appBar: AppBar(title: const Text('Change Frame Rate')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select FPS'),
              value: _selectedFps,
              items:
                  _fpsOptions.map((fps) {
                    return DropdownMenuItem(
                      value: fps,
                      child: Text('$fps FPS'),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => _selectedFps = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _changeFramerate,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.slow_motion_video),
              label: Text(_isProcessing ? 'Changing...' : 'Change FPS'),
            ),
          ],
        ),
      ),
    );
  }
}
