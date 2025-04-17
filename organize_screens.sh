#!/bin/bash

# Create destination directories
mkdir -p lib/screens/video
mkdir -p lib/screens/audio
mkdir -p lib/screens/image

# Move video-related screens
mv lib/*trim_video_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*extract_audio_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*create_gif_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*extract_frames_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*change_resolution_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*change_framerate_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*add_watermark_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*rotate_flip_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*change_aspect_ratio_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*merge_videos_screen.dart lib/screens/video/ 2>/dev/null
mv lib/*add_subtitles_screen.dart lib/screens/video/ 2>/dev/null

# Move audio-related screens
mv lib/*convert_audio_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*compress_audio_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*trim_audio_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*merge_audios_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*extract_audio_segment_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*normalize_audio_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*change_sample_rate_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*remove_silence_screen.dart lib/screens/audio/ 2>/dev/null
mv lib/*change_channels_screen.dart lib/screens/audio/ 2>/dev/null

# Move image-related screens
mv lib/*convert_image_screen.dart lib/screens/image/ 2>/dev/null
mv lib/*resize_image_screen.dart lib/screens/image/ 2>/dev/null
mv lib/*compress_image_screen.dart lib/screens/image/ 2>/dev/null
mv lib/*convert_to_pdf_screen.dart lib/screens/image/ 2>/dev/null
mv lib/*create_gif_from_images_screen.dart lib/screens/image/ 2>/dev/null
mv lib/*rotate_flip_image_screen.dart lib/screens/image/ 2>/dev/null
mv lib/*add_watermark_to_image_screen.dart lib/screens/image/ 2>/dev/null

echo "✅ Screens organized into lib/screens/{video,audio,image}/"
