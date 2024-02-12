import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'menu_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'summary.dart';

// import 'graph_generator.dart'; // Import the graph generator file

class OpenAIService {
  static const API_KEY = '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';

  Future<String> getResponse(String userMessage) async {
    var headers = {
      'Authorization': 'Bearer $API_KEY',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': userMessage},
      ],
    });

    try {
      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Failed to fetch response: ${response.statusCode}";
      }
    } catch (error) {
      return "Failed to fetch response";
    }
  }
}

Future<void> main() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String collectionName = 'chat_messages';

  CollectionReference collection = firestore.collection(collectionName);

  try {
    // Fetch all documents from the collection
    QuerySnapshot<Object?> querySnapshot = await collection.get();

    // Convert each document to JSON
    List<Map<String, dynamic>> jsonDataList = querySnapshot.docs
        .map((QueryDocumentSnapshot<Object?> document) =>
            document.data() as Map<String, dynamic>)
        .toList();

    // Convert JSON data to a formatted string
    String jsonString = json.encode(jsonDataList);
    String formattedJsonString =
        const JsonEncoder.withIndent('  ').convert(json.decode(jsonString));

    // Save JSON data to a file
    File file = File('output.json');
    await file.writeAsString(formattedJsonString);

    print('JSON data saved to ${file.path}');
    print(await file.readAsString());
  } catch (e) {
    print('Error: $e');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Widget> chatMessages = [];
  late OpenAIService openAIService;
  late ScrollController _scrollController;
  late CollectionReference chatMessagesCollection;
  String username = '';
  String? sessionId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    chatMessagesCollection =
        FirebaseFirestore.instance.collection('chat_messages');
    _scrollController = ScrollController();
    openAIService = OpenAIService();
    initChat();
  }

  void initChat() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        setState(() {
          username = userData.exists ? userData['username'] ?? 'User' : 'User';
          String initialMessage = "Hi $username! How can I help you today";
          chatMessages.add(_buildChatMessage(initialMessage, false));
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  void sendMessage() async {
    print('Sending message...');
    String userMessage = _controller.text.trim();
    print('User Message: $userMessage');
    setState(() {
      isLoading = true;
    });
    if (userMessage.isNotEmpty) {
      String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        await chatMessagesCollection.add({
          'content': userMessage,
          'timestamp': FieldValue.serverTimestamp(),
          'role': 'user',
          'username': username,
          'sessionId': sessionId,
        });
        print('User message added to Firestore');
      } catch (e) {
        print('Failed to add user message to Firestore: $e');
      }

      setState(() {
        chatMessages.add(_buildChatMessage('$userMessage', true));
        _controller.clear();
      });

      try {
        // Get OpenAI response
        String response = await openAIService.getResponse(userMessage);

        // Save OpenAI response to Firestore
        await chatMessagesCollection.add({
          'content': response,
          'timestamp': FieldValue.serverTimestamp(),
          'role': 'bot',
          'sessionId': sessionId,
        });
        print('OpenAI response added to Firestore');

        setState(() {
          chatMessages.add(_buildChatMessage('$response', false));
          isLoading = false;
        });
      } catch (e) {
        print('Failed to get OpenAI response: $e');
        setState(() {
          chatMessages.add(_buildChatMessage('Failed to get response', false));
          isLoading = false;
        });
      }

      // Scroll to the bottom of the chat
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void endSession() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('End Session'),
          content: Text('Are you sure you want to end the session?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Additional logic to clean up or end the session if needed
                setState(() {
                  chatMessages.clear();
                  sessionId = null;
                });

                // Navigate to MenuPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPage()),
                );

                // Start the analysis after ending the session
                await SummaryAnalyzer.analyzePatientConditionAndAdvice();
              },
              child: Text('End Session'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatMessage(String message, bool isUserMessage) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUserMessage ? Color(0xFFD1A9FF) : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            message,
            softWrap: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD1A9FF),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 500),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(-1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MenuPage(),
              ),
            );
          },
        ),
        actions: [
          // Add End Session button
          TextButton(
            onPressed: endSession,
            child: Text(
              'End Session',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            margin: EdgeInsets.only(bottom: 0),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/doc_bot.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHRIS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ONLINE',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDB99B), Color(0xFFCF8BF3), Color(0xFFA770EF)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return chatMessages[index];
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message',
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 50),
                      ),
                      onSubmitted: (String message) {
                        sendMessage();
                      },
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: isLoading
                            ? const Icon(Icons.pause)
                            : const Icon(Icons.send),
                        color: Colors.blue,
                        onPressed: isLoading ? null : sendMessage,
                      ),
                      if (isLoading)
                        const Positioned.fill(
                          child: Center(
                            child:
                                CupertinoActivityIndicator(), // Add a loading indicator
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
