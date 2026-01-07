# Add network-related rules to prevent stripping of HTTP classes
-keep class io.flutter.plugins.** { *; }
-keep class **.http.** { *; }
-keep class **.HttpClient { *; }
-keep class **.HttpClientRequest { *; }
-keep class **.HttpClientResponse { *; }
-keep class **.SocketException { *; }
-keep class **.ClientException { *; }

# Keep dart related classes
-keep class dart.** { *; }
-keep class dart.core.** { *; }
-keep class dart.io.** { *; }
-keep class dart.convert.** { *; }

# Keep JSON related classes
-keep class **.JsonEncoder { *; }
-keep class **.JsonDecoder { *; }