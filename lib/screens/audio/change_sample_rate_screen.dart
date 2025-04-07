import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';

class ChangeSampleRateScreen extends StatefulWidget {
  final File selectedFile;
  const ChangeSampleRateScreen({required this.selectedFile, super.key});

  @override
  State<ChangeSampleRateScreen> createState() => _ChangeSampleRateScreenState();
}

class _ChangeSampleRateScreenState extends State<ChangeSampleRateScreen> {
  String? _selectedRate;
  bool _isProcessing = false;

  final List<String> _rates = ['8000', '16000', '22050', '44100', '48000'];

  Future<void> _changeSampleRate() async {
    if (_selectedRate == null) return;
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'sampled_${_selectedRate}_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-ar',
      _selectedRate!,
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Sample Rate Change Result: $result');
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
      appBar: AppBar(title: const Text('Change Sample Rate')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Sample Rate (Hz)',
              ),
              value: _selectedRate,
              items:
                  _rates
                      .map(
                        (r) => DropdownMenuItem(value: r, child: Text('$r Hz')),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedRate = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _changeSampleRate,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.speed),
              label: Text(
                _isProcessing ? 'Processing...' : 'Change Sample Rate',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
