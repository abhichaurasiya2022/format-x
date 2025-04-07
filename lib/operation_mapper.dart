enum FileTypeCategory { image, video, audio }

/// Map extensions to file type categories
Map<String, FileTypeCategory> extensionMap = {
  // Image formats
  '.jpg': FileTypeCategory.image,
  '.jpeg': FileTypeCategory.image,
  '.png': FileTypeCategory.image,
  '.bmp': FileTypeCategory.image,
  '.webp': FileTypeCategory.image,
  '.tiff': FileTypeCategory.image,

  // Video formats
  '.mp4': FileTypeCategory.video,
  '.mov': FileTypeCategory.video,
  '.avi': FileTypeCategory.video,
  '.mkv': FileTypeCategory.video,
  '.flv': FileTypeCategory.video,
  '.webm': FileTypeCategory.video,

  // Audio formats
  '.mp3': FileTypeCategory.audio,
  '.aac': FileTypeCategory.audio,
  '.wav': FileTypeCategory.audio,
  '.ogg': FileTypeCategory.audio,
  '.flac': FileTypeCategory.audio,
  '.m4a': FileTypeCategory.audio,
};

/// Map operations supported for each file type category
Map<FileTypeCategory, List<String>> operationMap = {
  FileTypeCategory.video: [
    'Convert Format',
    'Compress Video',
    'Trim Video',
    'Extract Audio (MP3)',
    'Extract Audio (AAC)',
    'Extract Audio (WAV)',
    'Create GIF',
    'Extract Frames',
    'Change Resolution',
    'Change Frame Rate',
    'Add Watermark',
    'Rotate/Flip',
    'Change Aspect Ratio',
    'Merge Videos',
    'Add Subtitles',
  ],
  FileTypeCategory.audio: [
    'Convert Format',
    'Compress Audio',
    'Trim Audio',
    'Merge Audios',
    'Extract Segment',
    'Normalize Volume',
    'Change Sample Rate',
    'Remove Silence',
    'Change Channels',
  ],
  FileTypeCategory.image: [
    'Convert Format',
    'Compress Image',
    'Resize Image',
    'Convert to PDF',
    'Create GIF from Images',
    'Change DPI',
    'Add Watermark',
    'Rotate/Flip',
    'Extract Metadata',
  ],
};

FileTypeCategory? getFileCategory(String extension) {
  return extensionMap[extension.toLowerCase()];
}

List<String> getAvailableOperations(FileTypeCategory category) {
  return operationMap[category] ?? [];
}
