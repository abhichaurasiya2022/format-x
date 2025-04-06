import 'dart:developer' as developer;
import 'package:flutter_ffmpeg_utils/flutter_ffmpeg_utils.dart';
import 'dart:io';

// Compress Image
Future<void> compressImage(
  File inputFile,
  String outputPath, {
  double quality = 50.0,
}) async {
  try {
    List<String> command = [
      "-i",
      inputFile.path,
      "-q:v",
      quality.toString(),
      outputPath,
    ];
    final String result = await FlutterFfmpegUtils().executeFFmpeg(command);
    developer.log('FFmpeg Compression Result: $result', name: 'compressImage');
  } catch (e) {
    developer.log('Error in compression: $e', name: 'compressImage');
    throw Exception('Error during compression: $e');
  }
}

// Convert Video to Audio
Future<void> convertVideoToAudio(
  File inputFile,
  String outputPath,
  String audioFormat,
) async {
  try {
    List<String> command = [
      "-i", inputFile.path,
      "-vn", // No video
    ];

    switch (audioFormat.toLowerCase()) {
      case 'mp3':
        command.addAll(["-codec:a", "libmp3lame"]);
        break;
      case 'aac':
        command.addAll(["-codec:a", "aac"]);
        break;
      default:
        throw Exception('Unsupported audio format: $audioFormat');
    }

    command.add(outputPath);
    final String result = await FlutterFfmpegUtils().executeFFmpeg(command);
    developer.log(
      'FFmpeg Conversion Result: $result',
      name: 'convertVideoToAudio',
    );
  } catch (e) {
    developer.log('Error in conversion: $e', name: 'convertVideoToAudio');
    throw Exception('Error during conversion: $e');
  }
}

// Convert Video Format
Future<void> convertVideoFormat(
  File inputFile,
  String outputPath,
  String videoFormat,
) async {
  try {
    List<String> command = ["-i", inputFile.path, "-q:a", "0", "-q:v", "0"];

    switch (videoFormat.toLowerCase()) {
      case 'mp4':
        command.addAll(["-codec:v", "libx264", "-codec:a", "aac"]);
        break;
      case 'avi':
        command.addAll(["-codec:v", "mpeg4", "-codec:a", "mp3"]);
        break;
      case 'mkv':
        command.addAll(["-codec:v", "libx264", "-codec:a", "aac"]);
        break;
      default:
        throw Exception('Unsupported video format: $videoFormat');
    }

    command.add(outputPath);
    final String result = await FlutterFfmpegUtils().executeFFmpeg(command);
    developer.log(
      'FFmpeg Conversion Result: $result',
      name: 'convertVideoFormat',
    );
  } catch (e) {
    developer.log('Error in conversion: $e', name: 'convertVideoFormat');
    throw Exception('Error during conversion: $e');
  }
}

// Convert Image to PDF
Future<void> convertImageToPdf(File inputFile, String outputPath) async {
  try {
    List<String> command = ["-i", inputFile.path, outputPath];
    final String result = await FlutterFfmpegUtils().executeFFmpeg(command);
    developer.log(
      'FFmpeg Conversion Result: $result',
      name: 'convertImageToPdf',
    );
  } catch (e) {
    developer.log('Error in conversion: $e', name: 'convertImageToPdf');
    throw Exception('Error during conversion: $e');
  }
}
