from flask import Flask, jsonify
import matplotlib.pyplot as plt
from datetime import datetime
from google.cloud import firestore

# Initialize Firestore client with your service account key file
db = firestore.Client.from_service_account_json('firecredentials.json')
app = Flask(__name__)

@app.route('/generate_graph/<session_id>', methods=['GET'])
def generate_graph(session_id):
    # Function to fetch conversation data from Firestore
    def fetch_conversation_data():
        # Replace 'your_collection_name' with the actual name of your Firestore collection
        collection_ref = db.collection('chat_messages')

        # Query the Firestore collection
        query = collection_ref.order_by('timestamp', direction=firestore.Query.ASCENDING)
        documents = query.stream()

        # Convert Firestore documents to a list of dictionaries
        conversation_data = [doc.to_dict() for doc in documents]

        return conversation_data

    # Sample function to analyze user messages
    def analyze_user_messages(user_messages):
        danger_rates = {
            "depression": {"count": 0, "intensity": 0.0},
            "anxiety": {"count": 0, "intensity": 0.0},
            "bipolar": {"count": 0, "intensity": 0.0},
            "stress": {"count": 0, "intensity": 0.0},
            "loneliness": {"count": 0, "intensity": 0.0},
            "frustration": {"count": 0, "intensity": 0.0}
        }

        for message in user_messages:
            if "distracted" in message.get("content", "") or "play games" in message.get("content", ""):
                danger_rates["frustration"]["count"] += 1
                danger_rates["frustration"]["intensity"] += 1.0
            if "scolds" in message.get("content", "") or "angry" in message.get("content", "") or "sad" in message.get("content", ""):
                danger_rates["frustration"]["count"] += 1
                danger_rates["frustration"]["intensity"] += 1.5

            # Adjustments for other mental health concerns
            if "bipolar" in message.get("content", ""):
                danger_rates["bipolar"]["count"] += 1
                danger_rates["bipolar"]["intensity"] += 1.0
            if "stress" in message.get("content", ""):
                danger_rates["stress"]["count"] += 1
                danger_rates["stress"]["intensity"] += 1.0
            if "anxiety" in message.get("content", ""):
                danger_rates["anxiety"]["count"] += 1
                danger_rates["anxiety"]["intensity"] += 1.0
            if "loneliness" in message.get("content", ""):
                danger_rates["loneliness"]["count"] += 1
                danger_rates["loneliness"]["intensity"] += 1.0
            if "depression" in message.get("content", ""):
                danger_rates["depression"]["count"] += 1
                danger_rates["depression"]["intensity"] += 1.0

        # Calculate average intensity for each mental health concern
        for concern in danger_rates:
            if danger_rates[concern]["count"] > 0:
                danger_rates[concern]["intensity"] /= danger_rates[concern]["count"]

        return danger_rates

    # Fetch conversation data from Firestore
    conversation_data = fetch_conversation_data()

    # Extract relevant user messages for analysis
    user_messages = [msg for msg in conversation_data if msg.get("role") == "user"]

    # Check if the required fields are present before using them
    valid_session_data = all("sessionId" in msg and "timestamp" in msg for msg in conversation_data)

    if valid_session_data:
        # Analyze user messages
        danger_rates = analyze_user_messages(user_messages)

        session_id = conversation_data[0]["sessionId"]
        timestamp = conversation_data[0]["timestamp"]

        # Plotting the bar graph
        labels = list(danger_rates.keys())
        values = [concern["intensity"] for concern in danger_rates.values()]

        plt.bar(labels, values, color='skyblue')
        plt.xlabel('Mental Health Concerns')
        plt.ylabel('Average Intensity (out of 10)')
        plt.title(f'Average Intensity for Different Mental Health Concerns - Session {session_id} ({datetime.strptime(timestamp, "%d-%m-%y %H:%M").strftime("%d-%m-%y %H:%M")})')
        plt.savefig('mental_health_graph.png')  # Save the plot as an image file
        plt.close()  # Close the plot to avoid display issues

        return jsonify({"status": "success", "message": "Graph generated successfully."})
    else:
        return jsonify({"status": "error", "message": "Missing required fields."})

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
