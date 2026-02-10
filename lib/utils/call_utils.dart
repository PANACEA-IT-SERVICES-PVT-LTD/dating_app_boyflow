import 'dart:math';

class CallUtils {
  /// Generate unique channel name for each call session
  static String generateChannelName(String maleUserId, String femaleUserId) {
    // Create unique channel name using user IDs and timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'call_${maleUserId}_${femaleUserId}_${timestamp}_$random';
  }

  /// Convert string user ID to integer for Agora
  static int stringIdToInt(String id) {
    // Use hash code and ensure it's positive
    return id.hashCode.abs();
  }

  /// Validate call parameters
  static bool validateCallParams(String maleUserId, String femaleUserId) {
    return maleUserId.isNotEmpty &&
        femaleUserId.isNotEmpty &&
        maleUserId != femaleUserId;
  }

  /// Generate secure token (placeholder - implement with your token server)
  static String generateToken(String channelName, int uid) {
    // For production, integrate with Agora token server
    // Return empty string for testing without token
    return "";
  }

  /// Format call duration
  static String formatCallDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
