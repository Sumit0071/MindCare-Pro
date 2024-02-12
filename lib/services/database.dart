import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('chat_messages');

  // Singleton instance of the DatabaseService class
  static final DatabaseService _singleton = DatabaseService._();

  // Private constructor to create a singleton instance
  DatabaseService._();

  // Public method to get the singleton instance
  factory DatabaseService() => _singleton;

  // Store a message in Firestore
  Future<void> storeMessage(String message, bool isUserMessage) async {
    await _messagesCollection.add({
      'message': message,
      'isUserMessage': isUserMessage,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Message stored in Firestore: $message');
  }

  // Retrieve all messages from Firestore
  Future<List<Map<String, dynamic>>> getAllMessages() async {
    final QuerySnapshot messageSnapshot = await _messagesCollection.get();

    return messageSnapshot.docs
        .map<Map<String, dynamic>>((doc) => {
              'message': doc['message'] as String,
              'isUserMessage': doc['isUserMessage'] as bool,
              'timestamp': doc['timestamp'] as Timestamp,
            })
        .toList();
  }
}
