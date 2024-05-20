import 'dart:convert';
import 'package:http/http.dart' as http;

const API_KEY = 'YOUR_API_KEY';

class OpenAIService {
  Future<String> getResponse(String userMessage) async {
    var headers = {
      'Authorization': 'Bearer $API_KEY',
      'Content-Type': 'application/json'
    };

    var body = json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': userMessage}
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
