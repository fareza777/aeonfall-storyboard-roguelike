# Flutter engine + embedding
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# audioplayers uses reflection through ExoPlayer/MediaPlayer wrappers
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Google Mobile Ads 25.x brings WorkManager 2.7.0. Its generated Room
# database is discovered by reflection during the provider startup path.
# Keep the generated implementation and its constructor through R8.
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.WorkDatabase_Impl$* { *; }
