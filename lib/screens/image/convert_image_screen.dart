import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:developer' as developer;

class ConvertImageScreen extends StatefulWidget {
  final File selectedFile;
  const ConvertImageScreen({required this.selectedFile, super.key});

  @override
  State<ConvertImageScreen> createState() => _ConvertImageScreenState();
}

class _ConvertImageScreenState extends State<ConvertImageScreen> {
  String? _selectedFormat;
  bool _isProcessing = false;

  final List<String> _formats = ['jpg', 'png', 'webp', 'bmp', 'tiff'];

  Future<void> _convertImage() async {
    if (_selectedFormat == null) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'converted_image_${DateTime.now().millisecondsSinceEpoch}.$_selectedFormat',
    );

    final command = ['-i', widget.selectedFile.path, outPath];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Convert Image Result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Converted image saved to: $outPath')),
      );
    } catch (e) {
      developer.log('Image Conversion Error: $e');
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
      appBar: AppBar(title: const Text('Convert Image Format')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Target Format'),
              value: _selectedFormat,
              items:
                  _formats
                      .map(
                        (format) => DropdownMenuItem(
                          value: format,
                          child: Text(format.toUpperCase()),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedFormat = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _convertImage,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.image),
              label: Text(_isProcessing ? 'Converting...' : 'Convert'),
            ),
          ],
        ),
      ),
    );
  }
}
