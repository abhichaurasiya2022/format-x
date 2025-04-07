import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:path/path.dart' as path;

class ConvertToPdfScreen extends StatefulWidget {
  const ConvertToPdfScreen({super.key});

  @override
  State<ConvertToPdfScreen> createState() => _ConvertToPdfScreenState();
}

class _ConvertToPdfScreenState extends State<ConvertToPdfScreen> {
  List<File> _selectedImages = [];
  bool _isProcessing = false;

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      final files = result.paths.map((e) => File(e!)).toList();
      setState(() => _selectedImages = files);
    }
  }

  Future<void> _convertToPdf() async {
    if (_selectedImages.isEmpty) return;

    setState(() => _isProcessing = true);
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final pdf = pw.Document();

    for (final imageFile in _selectedImages) {
      final imageBytes = await imageFile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    final dir = Directory('/storage/emulated/0/Download');
    final outFile = File(
      path.join(
        dir.path,
        'converted_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
    );

    await outFile.writeAsBytes(await pdf.save());

    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to: ${outFile.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convert Image to PDF')),
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
              Text('${_selectedImages.length} image(s) selected'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _convertToPdf,
              icon:
                  _isProcessing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.picture_as_pdf),
              label: Text(_isProcessing ? 'Converting...' : 'Convert to PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
