import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:open_filex/open_filex.dart';

class SavedFilesScreen extends StatefulWidget {
  const SavedFilesScreen({super.key});

  @override
  State<SavedFilesScreen> createState() => _SavedFilesScreenState();
}

class _SavedFilesScreenState extends State<SavedFilesScreen> {
  List<FileSystemEntity> _files = [];
  bool _loading = true;

  final String downloadsPath = '/storage/emulated/0/Download';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);

    final dir = Directory(downloadsPath);
    if (await dir.exists()) {
      final files =
          dir
              .listSync()
              .where(
                (f) =>
                    f is File &&
                    p
                        .basename(f.path)
                        .startsWith(
                          RegExp(
                            r'(converted|compressed|trimmed|merged|resized|gif|pdf|audio|video)',
                          ),
                        ),
              )
              .toList()
            ..sort(
              (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
            );

      setState(() {
        _files = files;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Files')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _files.isEmpty
              ? const Center(child: Text('No processed files found yet.'))
              : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (ctx, i) {
                  final file = _files[i];
                  final name = p.basename(file.path);
                  final ext = p.extension(file.path).toLowerCase();

                  IconData icon;
                  if (['.mp4', '.avi', '.mkv'].contains(ext)) {
                    icon = Icons.video_file;
                  } else if (['.mp3', '.aac', '.wav'].contains(ext)) {
                    icon = Icons.audio_file;
                  } else if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
                    icon = Icons.image;
                  } else if (ext == '.pdf') {
                    icon = Icons.picture_as_pdf;
                  } else if (ext == '.gif') {
                    icon = Icons.gif;
                  } else {
                    icon = Icons.insert_drive_file;
                  }

                  return ListTile(
                    leading: Icon(icon),
                    title: Text(name),
                    subtitle: Text(
                      file.statSync().modified.toLocal().toString(),
                    ),
                    onTap: () => OpenFilex.open(file.path),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await File(file.path).delete();
                        _loadFiles();
                      },
                    ),
                  );
                },
              ),
    );
  }
}
