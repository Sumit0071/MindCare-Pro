import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime
from matplotlib.widgets import Cursor

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

    average_values = [np.mean([category_values[category][i] for category in categories]) for i in range(len(date_values))]

    positions = np.arange(len(date_values))

    bars = ax.bar(positions, average_values, bar_width, color=colors, alpha=0.5, label='Average')

    date_objects = [datetime.strptime(date, "%Y-%m-%d") for date in date_values]
    date_labels = [date.strftime("%Y-%m-%d\n%a") for date in date_objects]
    ax.set_xticks(np.arange(len(date_labels)))
    ax.set_xticklabels(date_labels, rotation=45, ha="right")  
    ax.legend()
    ax.set_xlabel('Date')
    ax.set_ylabel('Average Severity')
    ax.set_title('Average Mental Health Analysis')

    cursor = Cursor(ax, useblit=True, color='white', linewidth=0)

    def on_bar_click(event):
        if event.inaxes == ax:
            index = int(round(event.xdata))
            subgraph_values = [category_values[category][index] for category in categories]
            create_subgraph(subgraph_values, list(categories), date_values[index])

    def create_subgraph(subgraph_values, subcategories, date):
        fig, ax = plt.subplots()
        bars = ax.bar(subcategories, subgraph_values, color=colors, alpha=0.7)
        ax.set_ylabel('Values')
        ax.set_title(f'Subgraph for {date}')
        ax.set_xticks(np.arange(len(subcategories)))
        ax.set_xticklabels(subcategories, rotation=45, ha="right")
        plt.tight_layout()
        plt.show()

    fig.canvas.mpl_connect('button_press_event', on_bar_click)

    plt.tight_layout()
    plt.show()

file_path = 'dataset.txt'  
data = text_to_list_of_dicts(file_path)
plot_data(data)
