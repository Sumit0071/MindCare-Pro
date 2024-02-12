import os
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime
from flask import Flask , send_file
import io
import base64

app = Flask(__name__)

def text_to_list_of_dicts(file_path):
    result_list = []
    with open(file_path, 'r') as file:
        for line in file:
            date_str, categories_str = line.strip().split(':')
            date = date_str.strip()
            categories = {}
            for category in categories_str.split(','):
                key, value = category.strip().split('=')
                categories[key.strip()] = float(value.strip())
            result_list.append({date: categories})
    return result_list

def plot_data(data):
    categories = set()
    date_values = []
    category_values = {}

    for entry in data:
        date, categories_dict = list(entry.items())[0]
        date_values.append(date)
        categories.update(categories_dict.keys())
        for category, value in categories_dict.items():
            if category not in category_values:
                category_values[category] = []
            category_values[category].append(value)

    colors = plt.cm.viridis(np.linspace(0, 1, len(categories)))

    fig, ax = plt.subplots(figsize=(10, 6))
    bar_width = 0.8 / len(date_values)

    for i, category in enumerate(categories):
        values = [category_values[category][j] for j in range(len(date_values))]
        positions = np.arange(len(date_values)) + i * bar_width
        ax.bar(positions, values, bar_width, label=category, color=colors[i])

    date_objects = [datetime.strptime(date, "%Y-%m-%d") for date in date_values]
    date_labels = [date.strftime("%Y-%m-%d\n%a") for date in date_objects]

    ax.set_xticks(np.arange(len(date_values)) + (0.8 / 2))
    ax.set_xticklabels(date_labels, rotation=0, ha="center")  
    ax.legend()
    ax.set_xlabel('Dates')
    ax.set_ylabel('Severity')
    ax.set_title('Mental Health Analysis over time')

    plt.tight_layout()
    img_buffer = io.BytesIO()
    plt.savefig(img_buffer, format='png')
    img_buffer.seek(0)
    plot_img = base64.b64encode(img_buffer.getvalue()).decode()

    plt.clf()

    return plot_img

file_path = 'dataset.txt'
data = text_to_list_of_dicts(file_path)

@app.route('/' , methods = ['GET'])
def graph():
    plot_img_str = plot_data(data)

    temp_img = io.BytesIO(base64.b64decode(plot_img_str.encode('utf-8')))
    temp_img.seek(0)

    return send_file(temp_img, mimetype='image/png')

if __name__ == '__main__':
    host = os.getenv('FLASK_HOST', '127.0.0.1')
    port = os.getenv('FLASK_PORT', '5000')
    app.run(host=host, port=int(port))
