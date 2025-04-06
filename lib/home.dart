import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:permission_handler/permission_handler.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ConvertScreen(),
    const SavedScreen(),
    const ProfileScreen(appBar: null, actions: [], children: []),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormatX'),
        automaticallyImplyLeading: false,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.transform),
            label: 'Convert',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Convert Screen with File Picker and Operation Selection
class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  File? _selectedFile;
  String? _fileType;
  bool _isLoading = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _operation;

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
    });

    // Dispose any existing video controllers
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileExtension = path.extension(file.path).toLowerCase();

        setState(() {
          _selectedFile = file;
          _fileType = fileExtension;
          _operation = null; // Reset operation selection
        });

        // Initialize video player if it's a video file
        if (fileExtension == '.mp4' ||
            fileExtension == '.mov' ||
            fileExtension == '.avi' ||
            fileExtension == '.mkv') {
          await _initializeVideoPlayer(file);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoPlayer(File videoFile) async {
    _videoController = VideoPlayerController.file(videoFile);

    try {
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
      );

      // Need to call setState to rebuild the UI with the video player
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error initializing video: $e')));
    }
  }

  void _openFile() {
    if (_selectedFile != null) {
      OpenFile.open(_selectedFile!.path).then((result) {
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening file: ${result.message}')),
          );
        }
      });
    }
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    final fileName = path.basename(_selectedFile!.path);

    if (_fileType == '.jpg' ||
        _fileType == '.jpeg' ||
        _fileType == '.png' ||
        _fileType == '.gif') {
      return Column(
        children: [
          Text(
            'Selected image: $fileName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_selectedFile!, fit: BoxFit.contain),
            ),
          ),
        ],
      );
    } else if (_fileType == '.mp4' ||
        _fileType == '.mov' ||
        _fileType == '.avi' ||
        _fileType == '.mkv') {
      return Column(
        children: [
          Text(
            'Selected video: $fileName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_chewieController != null)
            Container(
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Chewie(controller: _chewieController!),
              ),
            )
          else
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Preparing video preview...'),
                ],
              ),
            ),
        ],
      );
    } else if (_fileType == '.pdf') {
      return Column(
        children: [
          const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
          Text('Selected PDF: $fileName'),
        ],
      );
    } else if (_fileType == '.doc' || _fileType == '.docx') {
      return Column(
        children: [
          const Icon(Icons.description, size: 50, color: Colors.blue),
          Text('Selected Document: $fileName'),
        ],
      );
    } else {
      return Column(
        children: [
          const Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
          Text('Selected File: $fileName'),
        ],
      );
    }
  }

  void _selectOperation(String operation) {
    setState(() {
      _operation = operation;
    });
  }

  void _startProcessing() {
    if (_operation == 'Compress') {
      // Navigate to Compression Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompressionScreen(selectedFile: _selectedFile!),
        ),
      );
    } else if (_operation == 'Convert') {
      // Navigate to Conversion Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversionScreen(selectedFile: _selectedFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/home_logo.png', height: 50),
              Text('Welcome!', style: Theme.of(context).textTheme.displaySmall),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.file_upload),
                label: Text(_isLoading ? 'Loading...' : 'Select File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_selectedFile != null) ...[
                _buildFilePreview(),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openFile,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open File'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Select Operation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ListTile(
                  title: const Text('Compress'),
                  leading: Radio<String>(
                    value: 'Compress',
                    groupValue: _operation,
                    onChanged: (value) => _selectOperation(value!),
                  ),
                ),
                ListTile(
                  title: const Text('Convert'),
                  leading: Radio<String>(
                    value: 'Convert',
                    groupValue: _operation,
                    onChanged: (value) => _selectOperation(value!),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _operation == null ? null : _startProcessing,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Processing'),
                ),
              ],

              const SizedBox(height: 30),
              // const SignOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}





class CompressionScreen extends StatefulWidget {
  final File selectedFile;

  CompressionScreen({required this.selectedFile});

  @override
  _CompressionScreenState createState() => _CompressionScreenState();
}

class _CompressionScreenState extends State<CompressionScreen> {
  double _compressionLevel = 50.0;
  bool _losslessCompression = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compression Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Selected File: ${widget.selectedFile.path.split('/').last}'),
            SizedBox(height: 20),
            Text('Compression Level: ${_compressionLevel.toStringAsFixed(0)}%'),
            Slider(
              value: _compressionLevel,
              min: 0.0,
              max: 100.0,
              onChanged: (value) {
                setState(() {
                  _compressionLevel = value;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Lossless Compression'),
              value: _losslessCompression,
              onChanged: (value) {
                setState(() {
                  _losslessCompression = value!;
                });
              },
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Start compression process
              },
              icon: Icon(Icons.compress),
              label: Text('Start Compression'),
            ),
          ],
        ),
      ),
    );
  }
}
class ConversionScreen extends StatefulWidget {
  final File selectedFile;

  ConversionScreen({required this.selectedFile});

  @override
  _ConversionScreenState createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  String? _selectedFormat;
  bool _isProcessing = false;


Future<void> convertVideo(File inputFile, String targetFormat, String outputPath) async {
  try {
    // Define the FFmpeg command based on the target format
    List<String> command = [
      "-i",
      inputFile.path,
      "-q:a",
      "0", // Best quality for audio
      "-q:v",
      "0", // Best quality for video
    ];

    // Add format-specific options
    switch (targetFormat.toLowerCase()) {
      case 'mp4':
        command.addAll(["-codec:v", "libx264", "-codec:a", "aac"]);
        break;
      case 'avi':
        command.addAll(["-codec:v", "mpeg4", "-codec:a", "mp3"]);
        break;
      case 'mkv':
        command.addAll(["-codec:v", "libx264", "-codec:a", "aac"]);
        break;
      case 'mp3':
        command.addAll(["-vn", "-codec:a", "libmp3lame"]);
        break;
      case 'aac':
        command.addAll(["-vn", "-codec:a", "aac"]);
        break;
      default:
        throw Exception('Unsupported format: $targetFormat');
    }

    // Add the output path
    command.add(outputPath);

    // Execute the FFmpeg command
    final String result = await FlutterFfmpegUtils().executeFFmpeg(command);
    developer.log('FFmpeg Result: $result', name: 'convertVideo');
  } catch (e) {
    developer.log('Error in conversion: $e', name: 'convertVideo');
    throw Exception('Error during conversion: $e');
  }
}


  Future<void> _startConversion() async {
    if (_selectedFormat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target format')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
        return;
      }

      // Use the public Downloads directory
      final Directory downloadsDir = Directory('/storage/emulated/0/Download');

      // Check if the directory exists
      if (!await downloadsDir.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloads directory does not exist')),
        );
        return;
      }

      // Create a unique filename based on timestamp
      final String outputFileName =
          'converted_${DateTime.now().millisecondsSinceEpoch}.$_selectedFormat';
      final String outputPath = '${downloadsDir.path}/$outputFileName';

      // Debug log
      developer.log('Saving to: $outputPath', name: 'ConversionScreen');

      // Perform the conversion
      await convertVideo(widget.selectedFile, _selectedFormat!, outputPath);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File saved to: $outputPath')));
    } catch (e) {
      developer.log('Error in conversion: $e', name: 'ConversionScreen');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during conversion: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Target Format')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Selected File: ${widget.selectedFile.path.split('/').last}'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Target Format'),
              value: _selectedFormat,
              items:
                  ['MP4', 'AVI', 'MKV', 'MP3', 'AAC'].map((format) {
                    return DropdownMenuItem<String>(
                      value: format,
                      child: Text(format),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _startConversion,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.swap_horiz),
              label: Text(_isProcessing ? 'Converting...' : 'Start Conversion'),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Saved Items'));
  }
}
