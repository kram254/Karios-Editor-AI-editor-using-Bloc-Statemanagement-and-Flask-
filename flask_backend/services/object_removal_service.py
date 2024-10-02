# flask_backend/services/object_removal_service.py
from gradio_client import Client, handle_file
import os
import shutil
from flask import current_app

def initialize_client():
    return Client("finegrain/finegrain-object-cutter")

def process_image_with_prompt(img_path, prompt):
    """
    Processes the image to remove background based on the provided prompt.
    
    Args:
        img_path (str): Path to the original image.
        prompt (str): Prompt describing how to process the image.
    
    Returns:
        str: Path to the processed image, or None if processing fails.
    """
    client = initialize_client()
    try:
        result = client.predict(
            img=handle_file(img_path),
            prompt=prompt,
            api_name="/on_change_prompt"
        )
        # Assuming 'result' is the path to the processed image
        processed_image_path = result
        # Save the processed image to the 'processed_images' directory
        return save_processed_image(processed_image_path)
    except Exception as e:
        print(f"Error in process_image_with_prompt: {e}")
        return None

def save_processed_image(result_path, output_dir='flask_backend/static/processed_images'):
    """
    Saves the processed image to the specified output directory.
    
    Args:
        result_path (str): Path to the processed image.
        output_dir (str): Directory where the processed image will be saved.
    
    Returns:
        str: Path to the saved processed image.
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
    output_filename = os.path.basename(result_path)
    output_path = os.path.join(output_dir, output_filename)
    shutil.move(result_path, output_path)
    return output_path













































# from gradio_client import Client, handle_file
# import os
# import shutil
# from flask import url_for

# def initialize_client():
#     return Client("finegrain/finegrain-object-cutter")

# def process_image_with_prompt(img_path, prompt):
#     client = initialize_client()
#     try:
#         result = client.predict(
#             img=handle_file(img_path),
#             prompt=prompt,
#             api_name="/on_change_prompt"
#         )
#         # Assuming 'result' is the path to the processed image
#         return result
#     except Exception as e:
#         print(f"Error in process_image_with_prompt: {e}")
#         return None

# def process_image_with_bbox(prompts):
#     client = initialize_client()
#     try:
#         result = client.predict(
#             prompts=prompts,
#             api_name="/on_change_bbox"
#         )
#         # Assuming 'result' is the path to the processed image
#         return result
#     except Exception as e:
#         print(f"Error in process_image_with_bbox: {e}")
#         return None

# def save_processed_image(result_path, output_dir='static/processed_images'):
#     if not os.path.exists(output_dir):
#         os.makedirs(output_dir, exist_ok=True)
#     output_filename = os.path.basename(result_path)
#     output_path = os.path.join(output_dir, output_filename)
#     shutil.move(result_path, output_path)
#     return output_path

# def get_processed_image_url(filename):
#     return url_for('static', filename=f'processed_images/{filename}', _external=True)