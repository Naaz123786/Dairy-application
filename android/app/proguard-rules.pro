# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_quill native bridge (R8 was stripping this)
-keep class dev.flutterquill.quill_native_bridge.QuillNativeBridgePlugin { *; }
-dontwarn dev.flutterquill.quill_native_bridge.QuillNativeBridgePlugin
