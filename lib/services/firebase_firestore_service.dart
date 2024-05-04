import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreService {
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chat_messages');

  Future<void> addUserInput({required String content}) async {
    try {
      await chatCollection.add({
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'user_text', // Indicate that the message is user text input
      });
    } catch (e) {
      print('Error adding user text input: $e');
      throw e; // You might want to handle this error in your UI
    }
  }

  Future<List<String>> getChatMessages() async {
    try {
      QuerySnapshot querySnapshot = await chatCollection.get();
      List<String> messages = [];

      querySnapshot.docs.forEach((doc) {
        messages.add(doc['content'].toString());
      });

      return messages;
    } catch (e) {
      print('Error getting chat messages: $e');
      throw e; // You might want to handle this error in your UI
    }
  }
}
