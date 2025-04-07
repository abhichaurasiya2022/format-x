import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'operation_mapper.dart';

import 'conversion_screen.dart';

// Video screens
import '../screens/video/trim_video_screen.dart';
import '../screens/video/extract_audio_screen.dart';
import '../screens/video/create_gif_screen.dart';
import '../screens/video/extract_frames_screen.dart';
import '../screens/video/change_resolution_screen.dart';
import '../screens/video/change_framerate_screen.dart';
import '../screens/video/add_watermark_screen.dart';
import '../screens/video/rotate_flip_screen.dart';
import '../screens/video/change_aspect_ratio_screen.dart';
import '../screens/video/merge_videos_screen.dart';
import '../screens/video/add_subtitles_screen.dart';

// Audio screens
import '../screens/audio/convert_audio_screen.dart';
import '../screens/audio/compress_audio_screen.dart';
import '../screens/audio/trim_audio_screen.dart';
import '../screens/audio/merge_audios_screen.dart';
import '../screens/audio/extract_audio_segment_screen.dart';
import '../screens/audio/normalize_audio_screen.dart';
import '../screens/audio/change_sample_rate_screen.dart';
import '../screens/audio/remove_silence_screen.dart';
import '../screens/audio/change_channels_screen.dart';

// Image screens
import '../screens/image/convert_image_screen.dart';
import '../screens/image/resize_image_screen.dart';
import '../screens/image/compress_image_screen.dart';
import '../screens/image/convert_to_pdf_screen.dart';
import '../screens/image/create_gif_from_images_screen.dart';
import '../screens/image/rotate_flip_image_screen.dart';
import '../screens/image/add_watermark_to_image_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedFile;
  FileTypeCategory? _category;
  List<String> _availableOperations = [];
  String? _selectedOperation;


  Future<bool> _confirmOperation(String operation, File file) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Confirm Operation'),
                content: Text(
                  'You selected:\n\n'
                  '📁 File: ${path.basename(file.path)}\n'
                  '⚙️ Operation: $operation\n\nProceed?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _pickFile() async {
    setState(() {
      _selectedFile = null;
      _category = null;
      _availableOperations = [];
      _selectedOperation = null;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final ext = path.extension(file.path);
      final category = getFileCategory(ext);

      setState(() {
        _selectedFile = file;
        _category = category;
        if (category != null) {
          _availableOperations = getAvailableOperations(category);
        }
      });
    }
  }

  Future<void> _startOperation() async {
  if (_selectedFile == null || _selectedOperation == null) return;

  // 🛑 Confirm with user
  final confirmed = await _confirmOperation(_selectedOperation!, _selectedFile!);
  if (!confirmed) return;
  
    if (_selectedOperation == 'Trim Video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrimVideoScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Extract Audio (MP3)') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ExtractAudioScreen(
                selectedFile: _selectedFile!,
                audioFormat: 'mp3',
              ),
        ),
      );
    } else if (_selectedOperation == 'Extract Audio (AAC)') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ExtractAudioScreen(
                selectedFile: _selectedFile!,
                audioFormat: 'aac',
              ),
        ),
      );
    } else if (_selectedOperation == 'Extract Audio (WAV)') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ExtractAudioScreen(
                selectedFile: _selectedFile!,
                audioFormat: 'wav',
              ),
        ),
      );
    } else if (_selectedOperation == 'Create GIF') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateGifScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Extract Frames') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ExtractFramesScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Change Resolution') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChangeResolutionScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Change Frame Rate') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChangeFramerateScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Add Watermark') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AddWatermarkScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Rotate/Flip') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RotateFlipScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Change Aspect Ratio') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ChangeAspectRatioScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Merge Videos') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MergeVideosScreen()),
      );
    } else if (_selectedOperation == 'Add Subtitles') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AddSubtitlesScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Convert Format' &&
        _category == FileTypeCategory.audio) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConvertAudioScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Compress Audio') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CompressAudioScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Merge Audios') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MergeAudiosScreen()),
      );
    } else if (_selectedOperation == 'Trim Audio') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrimAudioScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Extract Segment') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ExtractAudioSegmentScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Normalize Volume') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => NormalizeAudioScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Change Sample Rate') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChangeSampleRateScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Remove Silence') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => RemoveSilenceScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Change Channels') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChangeChannelsScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Convert Format' &&
        _category == FileTypeCategory.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConvertImageScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Resize Image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResizeImageScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Compress Image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CompressImageScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Convert to PDF') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConvertToPdfScreen()),
      );
    } else if (_selectedOperation == 'Create GIF from Images') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateGifFromImagesScreen(),
        ),
      );
    } else if (_selectedOperation == 'Rotate/Flip') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => RotateFlipImageScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_selectedOperation == 'Add Watermark' &&
        _category == FileTypeCategory.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  AddWatermarkToImageScreen(selectedFile: _selectedFile!),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConversionScreen(
                selectedFile: _selectedFile!,
                operation: _selectedOperation!,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormatX'), centerTitle: true),
body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('assets/home_logo.png', height: 60),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome to FormatX!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Select File'),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedFile != null) ...[
              const Divider(),
              Text('Selected File: ${path.basename(_selectedFile!.path)}'),
              Text('Detected Type: ${_category?.name ?? 'Unknown'}'),
            ],
            const SizedBox(height: 20),
            if (_availableOperations.isNotEmpty) ...[
              const Divider(),
              Text(
                'Select Operation:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._availableOperations.map(
                (op) => RadioListTile<String>(
                  title: Text(op),
                  value: op,
                  groupValue: _selectedOperation,
                  onChanged: (val) {
                    setState(() => _selectedOperation = val);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed:
                      _selectedOperation != null ? _startOperation : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Operation'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
