import json
import requests
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK (replace 'path/to/your/credentials.json' with your service account key file)
cred = credentials.Certificate('firestoredb-credentials.json')
firebase_admin.initialize_app(cred)

# Reference to Firestore database
db = firestore.client()

API_KEY = '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'

class ModelService:
    def get_response(self, user_message):
        headers = {
            'Authorization': f'Bearer {API_KEY}',
            'Content-Type': 'application/json'
        }

        body = json.dumps({
            'model': 'gpt-3.5-turbo',
            'messages': [{'role': 'user', 'content': user_message}],
        })

        try:
            response = requests.post(
                'https://api.openai.com/v1/chat/completions',
                headers=headers,
                data=body
            )

            if response.status_code == 200:
                data = response.json()
                return data['choices'][0]['message']['content']
            else:
                return f"Failed to fetch response: {response.status_code}"
        except Exception as e:
            return "Failed to fetch response"


def store_user_response(user_name, user_age, user_issues, user_input, responses):
    # Reference to the 'user_responses' collection
    user_responses_ref = db.collection('user_responses')

    # Add a new document with user responses
    user_responses_ref.add({
        'name': user_name,
        'age': user_age,
        'issues': user_issues,
        'user_input': user_input,
        'responses': responses,
        'timestamp': firestore.SERVER_TIMESTAMP
    })


def main():
    service = ModelService()

    user_name = input("What is your name: ")
    user_age = input("What is your age: ")
    user_issues = input("What issues are you facing: ")
    passed_input = f"Hi! My name is {user_name}. I am {user_age} years old and I have the following issues {user_issues}. Ask me a small question at a time like the first meeting with a psychologist and keep asking me questions related to it without mentioning that you are an AI model."

    check = 0
    lst = []

    while True:
        if check == 0:
            response = service.get_response(passed_input)
            check = 1
        else:
            lst.append(response)
            str_responses = ", ".join(lst)
            response = service.get_response(f"This is the response to the previous question that you asked '{passed_input}'. Now, ask me more questions one at a time to get to a conclusion about my mental status without mentioning that you are an AI model. You can also repeat your previous questions, which were: {str_responses}")

        # Store user responses in Firestore
        store_user_response(user_name, user_age, user_issues, passed_input, lst)

        passed_input = input(f"{response}\nInput: ")


if __name__ == "__main__":
    main()
