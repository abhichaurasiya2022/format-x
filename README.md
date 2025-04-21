# FormatX

FormatX is a Flutter-based media processing app powered by FFmpeg and Firebase. It enables users to compress, convert, and manage media files with an intuitive interface. Supported file types include video, audio, and image files.

## Features

- 🔒 Firebase Authentication (Google & Email)
- 🎞 Media Conversion (MP3, AAC, MP4, AVI, MKV, PDF)
- 🗜 Image & Video Compression
- 📂 File Picker Integration
- 💾 Output Saved to Downloads Directory
- 👤 User Profile with Photo Upload
- 📱 Responsive UI with Bottom Navigation



<img src="assets/home_logo.png" width="150"/>

## Project Structure

```
lib/
│
├── main.dart                # Entry point, initializes Firebase
├── app.dart                 # Root widget
├── firebase_options.dart    # Firebase configuration
│
├── auth_gate.dart           # Auth handler (login/signup)
├── main_wrapper.dart        # App's bottom navigation wrapper
│
├── home_screen.dart         # File selection and operation interface
├── conversion_screen.dart   # Conversion logic (format, audio, PDF)
├── compression_screen.dart  # Compression UI and logic
├── saved_screen.dart        # Placeholder for saved file management
├── profile_screen.dart      # Profile management (photo, email, password)
│
└── operation_mapper.dart    # File type to operation mapping
```

## Supported Operations

| File Type | Operations                          |
|-----------|--------------------------------------|
| Video     | Compress, Convert to MP3, AAC, Format |
| Audio     | Convert Format                      |
| Image     | Compress, Convert to PDF            |

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase account & project setup
- FFmpeg binary support via `flutter_ffmpeg_utils`

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/formatx.git
   cd formatx
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   Ensure `firebase_options.dart` is generated using:

   ```bash
   flutterfire configure
   ```

4. Run the app:

   ```bash
   flutter run
   ```

## Notes

- Outputs are saved to the `Downloads` folder on Android.
- Make sure to grant file system access permissions when prompted.
- Firebase Storage is used for storing user profile images.

## Dependencies

- `flutter`
- `firebase_core`
- `firebase_auth`
- `firebase_ui_auth`
- `firebase_ui_oauth_google`
- `firebase_storage`
- `flutter_ffmpeg_utils`
- `permission_handler`
- `path`, `path_provider`
- `file_picker`
- `image_picker`

## License

This project is licensed under the MIT License.

---

### Developed by [Your Name] 🚀
