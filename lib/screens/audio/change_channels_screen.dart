import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';

class ChangeChannelsScreen extends StatefulWidget {
  final File selectedFile;
  const ChangeChannelsScreen({required this.selectedFile, super.key});

  @override
  State<ChangeChannelsScreen> createState() => _ChangeChannelsScreenState();
}

class _ChangeChannelsScreenState extends State<ChangeChannelsScreen> {
  String? _selectedChannel;
  bool _isProcessing = false;

  final Map<String, String> _channelMap = {
    'Mono (1 channel)': '1',
    'Stereo (2 channels)': '2',
  };

  Future<void> _changeChannels() async {
    if (_selectedChannel == null) return;
    setState(() => _isProcessing = true);

    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final outPath = path.join(
      '/storage/emulated/0/Download',
      'channels_${_channelMap[_selectedChannel]}_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command = [
      '-i',
      widget.selectedFile.path,
      '-ac',
      _channelMap[_selectedChannel]!,
      outPath,
    ];

    try {
      final result = await FlutterFfmpegUtils().executeFFmpeg(command);
      developer.log('Channel Change Result: $result');
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
      appBar: AppBar(title: const Text('Change Audio Channels')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Channel Type',
              ),
              value: _selectedChannel,
              items:
                  _channelMap.keys
                      .map((ch) => DropdownMenuItem(value: ch, child: Text(ch)))
                      .toList(),
              onChanged: (val) => setState(() => _selectedChannel = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _changeChannels,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.surround_sound),
              label: Text(_isProcessing ? 'Converting...' : 'Change Channels'),
            ),
          ],
        ),
      ),
    );
  }
}
