
from flask import Flask, request, jsonify
from flask_cors import CORS
import openai

app = Flask(__name__)

openai.api_key = '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'  # Replace with your OpenAI API key

class ModelService:
    def get_response(self, user_message):
        try:
            response = openai.Completion.create(
                engine="text-davinci-003",  # or use "text-davinci-003" for GPT-3.5 Turbo
                prompt=user_message,
            )

            return response['choices'][0]['text'].strip()
        except Exception as e:
            return f"Failed to fetch response: {str(e)}"


service = ModelService()

@app.route('/send_message', methods=['POST'])
def send_message():
    data = request.get_json()
    user_message = data['message']

    # Use the OpenAI language model to generate a response
    response = service.get_response(user_message)

    # You can store the message and response in a database or file if needed
    # For demonstration purposes, let's print the message and response
    print(f"User Message: {user_message}")
    print(f"AI Response: {response}")

    # You can also send a response to the Flutter app
    response_data = {'status': 'success', 'message': 'Message received', 'response': response}
    return jsonify(response_data)

if __name__ == '__main__':
    app.run(port=5001, debug=True)
