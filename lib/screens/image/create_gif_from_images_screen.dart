import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';

class CreateGifFromImagesScreen extends StatefulWidget {
  const CreateGifFromImagesScreen({super.key});

  @override
  State<CreateGifFromImagesScreen> createState() =>
      _CreateGifFromImagesScreenState();
}

class _CreateGifFromImagesScreenState extends State<CreateGifFromImagesScreen> {
  List<File> _selectedImages = [];
  double _fps = 1;
  bool _isProcessing = false;

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final files = result.paths.map((e) => File(e!)).toList();
      setState(() => _selectedImages = files);
    }
  }

  Future<void> _createGif() async {
    if (_selectedImages.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select at least 2 images')));
      return;
    }

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final tempDir = Directory(
      '/storage/emulated/0/Download/gif_temp_${DateTime.now().millisecondsSinceEpoch}',
    );
    await tempDir.create(recursive: true);

    // Copy images to numbered files like img001.jpg
    for (int i = 0; i < _selectedImages.length; i++) {
      final targetPath = path.join(
        tempDir.path,
        'img${i.toString().padLeft(3, '0')}.jpg',
      );
      await _selectedImages[i].copy(targetPath);
    }

    final outputPath = path.join(
      '/storage/emulated/0/Download',
      'gif_from_images_${DateTime.now().millisecondsSinceEpoch}.gif',
    );

    final command = [
      '-framerate',
      _fps.toStringAsFixed(0),
      '-i',
      '${tempDir.path}/img%03d.jpg',
      '-loop',
      '0',
      outputPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('GIF from Images Result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('GIF saved to: $outputPath')));
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
      appBar: AppBar(title: const Text('Create GIF from Images')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Select Images'),
            ),
            const SizedBox(height: 10),
            if (_selectedImages.isNotEmpty)
              Text('${_selectedImages.length} images selected'),
            const SizedBox(height: 20),
            Text('Frames per second: ${_fps.toStringAsFixed(0)}'),
            Slider(
              value: _fps,
              min: 1,
              max: 30,
              divisions: 29,
              label: _fps.toStringAsFixed(0),
              onChanged: (val) => setState(() => _fps = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _createGif,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.gif),
              label: Text(_isProcessing ? 'Creating...' : 'Create GIF'),
            ),
          ],
        ),
      ),
    );
  }
}
