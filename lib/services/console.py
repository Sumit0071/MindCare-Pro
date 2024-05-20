import json
import requests

API_KEY = 'YOUR_API_KEY'

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

service = ModelService()

user_name = input("What is your name : ")
user_age = input("What is your age : ")
user_issues = input("What issues are you facing : ")
passed_input = f"Hi! My name is {user_name}. I am {user_age} years old and I have the following issues {user_issues}. Ask me a small question at a time like the first meeting with a psychologist and keep asking me questions related to it without mentioning that you are an AI model."
check = 0
lst = []

while True:
    # if check == 0:
    #     check_valid = service.get_response(f"Is this question '{user_issues}' related to mental health issues ? Answer in yes or no only")
    #     check = 1
    # else:
    #     check_valid = service.get_response(f"Is this question '{passed_input}' related to mental health issues ? Answer in yes or no only")

    # if check_valid[:2] == "No" or check_valid[:2] == "NO":
    #     print("Response not related , please stick to the point")
    #     passed_input = input("Input : ")
    # else:
        
        if check == 0:
             response = service.get_response(passed_input)
             check = 1
        else:
             lst.append(response)
             str = ""
             for res in lst:
                  str = f"{str} , {res}"
             response = service.get_response(f"This is the response to the previous question that you asked '{passed_input}' now ask me more questions one at a time to get to a conclusion of my mental status without mentioning you are an AI model and i know i seek professional help or repeating your previous questions which were {str}")
             
        
        passed_input = input(f"{response}\nInput : ")
