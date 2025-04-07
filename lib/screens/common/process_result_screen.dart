import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';

class ProcessResultScreen extends StatelessWidget {
  final String outputPath;

  const ProcessResultScreen({required this.outputPath, super.key});

  @override
  Widget build(BuildContext context) {
    final filename = outputPath.split('/').last;

    return Scaffold(
      appBar: AppBar(title: const Text('Operation Complete')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 70, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'File Saved Successfully!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              filename,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open File'),
              onPressed: () => OpenFilex.open(outputPath),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder),
              label: const Text('Open in File Explorer'),
              onPressed: () => OpenFilex.open(File(outputPath).parent.path),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              onPressed: () => Share.shareXFiles([XFile(outputPath)]),
            ),
          ],
        ),
      ),
    );
  }
}
