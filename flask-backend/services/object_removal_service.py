from gradio_client import Client, handle_file
import os
import shutil
from flask import url_for

def initialize_client():
    return Client("finegrain/finegrain-object-cutter")

def process_image_with_prompt(img_path, prompt):
    client = initialize_client()
    try:
        result = client.predict(
            img=handle_file(img_path),
            prompt=prompt,
            api_name="/on_change_prompt"
        )
        # Assuming 'result' is the path to the processed image
        return result
    except Exception as e:
        print(f"Error in process_image_with_prompt: {e}")
        return None

def process_image_with_bbox(prompts):
    client = initialize_client()
    try:
        result = client.predict(
            prompts=prompts,
            api_name="/on_change_bbox"
        )
        # Assuming 'result' is the path to the processed image
        return result
    except Exception as e:
        print(f"Error in process_image_with_bbox: {e}")
        return None

def save_processed_image(result_path, output_dir='static/processed_images'):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
    output_filename = os.path.basename(result_path)
    output_path = os.path.join(output_dir, output_filename)
    shutil.move(result_path, output_path)
    return output_path

def get_processed_image_url(filename):
    return url_for('static', filename=f'processed_images/{filename}', _external=True)