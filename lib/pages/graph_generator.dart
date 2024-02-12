// graph_generator.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphData {
  final List<String> labels;
  final List<double> values;

  GraphData(this.labels, this.values);
}

Future<GraphData> generateGraph(String sessionId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    print("Fetching Data from Firestore... ");
    QuerySnapshot querySnapshot = await firestore
        .collection('chat_messages')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('timestamp', descending: false)
        .get();
    print("Data fetched successfully!");

    List<Map<String, dynamic>> conversationData = querySnapshot.docs
        .map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>)
        .toList();
    print("Conversation data: $conversationData");

    List<Map<String, dynamic>> userMessages =
        conversationData.where((msg) => msg['role'] == 'user').toList();
    print("User messages: $userMessages");

    bool validSessionData = conversationData.every(
        (msg) => msg.containsKey('sessionId') && msg.containsKey('timestamp'));

    if (validSessionData) {
      Map<String, dynamic> dangerRates = analyzeUserMessages(userMessages);

      List<String> labels = dangerRates.keys.toList();
      List<double>? values = dangerRates.values
          .map((concern) => concern['intensity'])
          .cast<double>()
          .toList();

      return GraphData(labels, values!);
    } else {
      throw Exception("Missing required fields.");
    }
  } catch (e) {
    throw Exception("Error generating graph: $e");
  }
}

Map<String, dynamic> analyzeUserMessages(
    List<Map<String, dynamic>> userMessages) {
  Map<String, dynamic> dangerRates = {
    "depression": {"count": 0, "intensity": 0.0},
    "anxiety": {"count": 0, "intensity": 0.0},
    "bipolar": {"count": 0, "intensity": 0.0},
    "stress": {"count": 0, "intensity": 0.0},
    "loneliness": {"count": 0, "intensity": 0.0},
    "frustration": {"count": 0, "intensity": 0.0}
  };

  for (Map<String, dynamic> message in userMessages) {
    if (message['content'].contains("distracted") ||
        message['content'].contains("play games")) {
      dangerRates["frustration"]["count"] += 1;
      dangerRates["frustration"]["intensity"] += 1.0;
    }

    // Add similar conditions for other messages

    // Adjustments for other mental health concerns
    if (message['content'].contains("bipolar")) {
      dangerRates["bipolar"]["count"] += 1;
      dangerRates["bipolar"]["intensity"] += 1.0;
    }

    // Add similar conditions for other concerns
  }

  // Calculate average intensity for each mental health concern
  for (String concern in dangerRates.keys) {
    if (dangerRates[concern]["count"] > 0) {
      dangerRates[concern]["intensity"] /= dangerRates[concern]["count"];
    }
  }

  return dangerRates;
}

void _showGraph(
    BuildContext context, List<String> labels, List<dynamic> values) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("User Mental Health Analysis"),
        content: Container(
          height: 300,
          child: BarChart(
            BarChartData(
              groupsSpace: 12,
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: SideTitles(showTitles: false),
              ),
              barGroups: labels
                  .asMap()
                  .entries
                  .map(
                    (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          y: values[entry.key].toDouble(),
                          colors: [Colors.blue],
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}
