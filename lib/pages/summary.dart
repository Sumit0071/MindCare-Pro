// summary.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryAnalyzer {
  static Future<void> analyzePatientConditionAndAdvice() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String collectionName = 'chat_messages';

    CollectionReference collection = firestore.collection(collectionName);

    try {
      // Fetch all documents from the collection
      QuerySnapshot<Object?> querySnapshot = await collection.get();

      // Filter user messages
      List<QueryDocumentSnapshot<Object?>> userMessages = querySnapshot.docs
          .where((doc) =>
              doc['role'] == 'user' &&
              doc['content'] != null &&
              doc['role'] != null)
          .toList();
      // Extract user messages content
      List<String> userMessageContents =
          userMessages.map((doc) => doc['content'] as String).toList();

      // Keywords for mental health disorders
      List<String> anxietyKeywords = ['anxiety', 'worried', 'nervous'];
      List<String> depressionKeywords = ['depression', 'sad', 'hopeless'];
      List<String> bipolarKeywords = ['bipolar', 'mood swings', 'mania'];
      List<String> frustrationKeywords = ['frustration', 'angry', 'irritated'];
      List<String> stressKeywords = ['stress', 'overwhelmed', 'pressure'];
      List<String> lonelinessKeywords = ['loneliness', 'isolated', 'alone'];

      // Check if any mental health disorder keywords are present in user messages
      bool hasAnxiety = anxietyKeywords.any((keyword) =>
          userMessageContents.any((content) => content.contains(keyword)));
      bool hasDepression = depressionKeywords.any((keyword) =>
          userMessageContents.any((content) => content.contains(keyword)));
      bool hasBipolar = bipolarKeywords.any((keyword) =>
          userMessageContents.any((content) => content.contains(keyword)));
      bool hasFrustration = frustrationKeywords.any((keyword) =>
          userMessageContents.any((content) => content.contains(keyword)));
      bool hasStress = stressKeywords.any((keyword) =>
          userMessageContents.any((content) => content.contains(keyword)));
      bool hasLoneliness = lonelinessKeywords.any((keyword) =>
          userMessageContents.any((content) => content.contains(keyword)));

      // Provide advice based on the analysis
      if (hasAnxiety ||
          hasDepression ||
          hasBipolar ||
          hasFrustration ||
          hasStress ||
          hasLoneliness) {
        print('User may be experiencing mental health challenges.');
        print(
            'Advice: Encourage the user to seek professional help and consider talking to a mental health expert.');
      } else {
        print('User seems to be in good mental health.');
        print(
            'Advice: Encourage the user to maintain a healthy lifestyle and reach out to friends or family for support.');
      }
    } catch (e) {
      print('Error analyzing user condition and providing advice: $e');
    }
  }

  static getOverallSummary() {}
}
