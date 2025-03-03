import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
        title: const Text('My App'),
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

// Convert Screen with File Picker
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
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Here you would add your conversion logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Starting conversion...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.transform),
                      label: const Text('Convert'),
                    ),
                  ],
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

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Saved Items'));
  }
}
