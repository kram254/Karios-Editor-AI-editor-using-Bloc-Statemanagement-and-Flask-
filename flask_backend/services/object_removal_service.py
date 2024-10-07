from gradio_client import Client, handle_file
import os
import shutil
from flask import current_app

def initialize_client():
    """
    Initializes and returns the Gradio client for the Object Cutter model.
    
    Returns:
        Client: Gradio client instance.
    """
    return Client("finegrain/finegrain-object-cutter")

def process_image_with_prompt(img_path, prompt):
    """
    Processes the image to remove the background based on the provided prompt.
    
    Args:
        img_path (str): Path to the original image.
        prompt (str): Prompt describing how to process the image.
    
    Returns:
        str: Path to the processed image, or None if processing fails.
    """
    client = initialize_client()
    api_endpoints = ["/on_change_prompt", "/on_change_prompt_1", "/on_change_bbox"]
    
    for api_name in api_endpoints:
        try:
            print(f"Attempting to process image with API endpoint: {api_name}")
            result = client.predict(
                img=handle_file(img_path),
                prompt=prompt,
                api_name=api_name
            )
            print(f"Received result from {api_name}: {result}")
            
            # Handle different possible response formats
            if isinstance(result, str):
                processed_image_path = result
            elif isinstance(result, (list, tuple)) and len(result) >= 1 and isinstance(result[0], str):
                processed_image_path = result[0]
            else:
                print(f"Unexpected result format from {api_name}: {result}")
                continue  # Try the next API endpoint
            
            if os.path.exists(processed_image_path):
                saved_path = save_processed_image(processed_image_path)
                print(f"Processed image saved at: {saved_path}")
                return saved_path
            else:
                print(f"Processed image does not exist at path: {processed_image_path}")
        except Exception as e:
            print(f"Error with API endpoint {api_name}: {e}")
            continue  # Try the next API endpoint
    
    print("All API endpoints failed to process the image.")
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
    print(f"Moved processed image from {result_path} to {output_path}")
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