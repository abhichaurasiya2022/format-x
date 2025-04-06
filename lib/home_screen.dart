import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'operation_mapper.dart';
import 'compression_screen.dart';
import 'conversion_screen.dart';

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

  void _startOperation() {
    if (_selectedFile == null || _selectedOperation == null) return;

    if (_selectedOperation!.contains('Compress')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompressionScreen(selectedFile: _selectedFile!),
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
