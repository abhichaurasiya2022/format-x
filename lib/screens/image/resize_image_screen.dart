import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class ResizeImageScreen extends StatefulWidget {
  final File selectedFile;
  const ResizeImageScreen({required this.selectedFile, super.key});

  @override
  State<ResizeImageScreen> createState() => _ResizeImageScreenState();
}

class _ResizeImageScreenState extends State<ResizeImageScreen> {
  TextEditingController _widthController = TextEditingController(text: "800");
  TextEditingController _heightController = TextEditingController(text: "600");
  bool _isProcessing = false;

  Future<void> _resizeImage() async {
    final width = _widthController.text;
    final height = _heightController.text;
    if (width.isEmpty || height.isEmpty) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'resized_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-vf',
      'scale=$width:$height',
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Resize Image Result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resized image saved to: $outPath')),
      );
    } catch (e) {
      developer.log('Resize Error: $e');
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
      appBar: AppBar(title: const Text('Resize Image')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _widthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Width'),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _resizeImage,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.photo_size_select_large),
              label: Text(_isProcessing ? 'Resizing...' : 'Resize Image'),
            ),
          ],
        ),
      ),
    );
  }
}
