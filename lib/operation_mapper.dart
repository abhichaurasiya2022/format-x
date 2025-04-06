enum FileTypeCategory { image, video, audio }

/// Map extensions to file type categories
Map<String, FileTypeCategory> extensionMap = {
  // Image formats
  '.jpg': FileTypeCategory.image,
  '.jpeg': FileTypeCategory.image,
  '.png': FileTypeCategory.image,
  '.bmp': FileTypeCategory.image,
  '.webp': FileTypeCategory.image,

  // Video formats
  '.mp4': FileTypeCategory.video,
  '.mov': FileTypeCategory.video,
  '.avi': FileTypeCategory.video,
  '.mkv': FileTypeCategory.video,
  '.flv': FileTypeCategory.video,

  // Audio formats
  '.mp3': FileTypeCategory.audio,
  '.aac': FileTypeCategory.audio,
  '.wav': FileTypeCategory.audio,
  '.ogg': FileTypeCategory.audio,
};

/// Map operations supported for each file type category
Map<FileTypeCategory, List<String>> operationMap = {
  FileTypeCategory.image: ['Compress Image', 'Convert to PDF'],
  FileTypeCategory.video: [
    'Compress Video',
    'Convert to MP3',
    'Convert to AAC',
    'Convert Format',
  ],
  FileTypeCategory.audio: ['Convert Format'],
};

/// Return the category for a given file extension
FileTypeCategory? getFileCategory(String extension) {
  return extensionMap[extension.toLowerCase()];
}

/// Return supported operations for a file category
List<String> getAvailableOperations(FileTypeCategory category) {
  return operationMap[category] ?? [];
}
