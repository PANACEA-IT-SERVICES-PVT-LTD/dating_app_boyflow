import 'package:boy_flow/controllers/api_controller.dart';

/// Simple example demonstrating how to call the fetchChatMessages API
/// 
/// Usage Example:
/// ```dart
/// final apiController = ApiController();
/// final chatRoomId = '69843b3694ff5ec548ce7226';
/// 
/// try {
///   final result = await apiController.fetchChatMessages(chatRoomId);
///   
///   if (result['success'] == true) {
///     final messages = result['data'] as List;
///     print('Fetched ${messages.length} messages');
///     
///     for (var message in messages) {
///       print('---');
///       print('Message ID: ${message['_id']}');
///       print('Sender: ${message['senderType']}');
///       print('Content: ${message['content']}');
///       print('Created: ${message['createdAt']}');
///       print('Is Media: ${message['isMedia']}');
///     }
///   } else {
///     print('Failed to fetch messages: ${result['message']}');
///   }
/// } catch (e) {
///   print('Error: $e');
/// }
/// ```
/// 
/// Expected Response Format:
/// ```json
/// {
///   "success": true,
///   "data": [
///     {
///       "mediaMetadata": null,
///       "_id": "69843b4894ff5ec548ce72ec",
///       "chatRoomId": "69843b3694ff5ec548ce7226",
///       "senderId": "69832a96ef4bf760d5abc77c",
///       "senderType": "male",
///       "type": "text",
///       "content": "Hello How are you female 1c?",
///       "isMedia": false,
///       "isDeletedFor": [],
///       "expireAt": null,
///       "isDeletedForEveryone": false,
///       "readBy": [],
///       "deliveredTo": [],
///       "createdAt": "2026-02-05T06:40:08.209Z",
///       "updatedAt": "2026-02-05T06:40:08.209Z",
///       "__v": 0
///     }
///   ]
/// }
/// ```

void main() async {
  // Initialize the API controller
  final apiController = ApiController();
  
  // Example chat room ID from the user's request
  final chatRoomId = '69843b3694ff5ec548ce7226';
  
  print('Fetching messages for chat room: $chatRoomId');
  print('API Endpoint: GET {{BASE_URL}}/chat/$chatRoomId/messages');
  print('---');
  
  try {
    // Call the API to fetch chat messages
    final result = await apiController.fetchChatMessages(chatRoomId);
    
    // Check if the request was successful
    if (result['success'] == true) {
      final messages = result['data'] as List;
      print('✅ Successfully fetched ${messages.length} messages\n');
      
      // Display each message
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        print('Message ${i + 1}:');
        print('  ID: ${message['_id']}');
        print('  Sender: ${message['senderType']} (${message['senderId']})');
        print('  Type: ${message['type']}');
        print('  Content: ${message['content']}');
        print('  Is Media: ${message['isMedia']}');
        print('  Created: ${message['createdAt']}');
        print('  Read By: ${message['readBy']?.length ?? 0} users');
        print('  Delivered To: ${message['deliveredTo']?.length ?? 0} users');
        print('');
      }
    } else {
      print('❌ Failed to fetch messages');
      print('Message: ${result['message']}');
    }
  } catch (e) {
    print('❌ Error fetching messages: $e');
  }
}
