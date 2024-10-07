from flask import Blueprint, request, jsonify, current_app, url_for
from werkzeug.utils import secure_filename
import os

from services.object_removal_service import (
    process_image_with_prompt,
    save_processed_image,
)

object_cutter_bp = Blueprint('object_cutter', __name__)

# Define allowed file extensions for image uploads
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

def allowed_file(filename):
    """
    Check if the uploaded file has an allowed extension.
    
    Args:
        filename (str): The name of the file.
    
    Returns:
        bool: True if the file extension is allowed, False otherwise.
    """
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@object_cutter_bp.route('/api/object_cutter', methods=['POST'])
def object_cutter():
    """
    Handle the Object Cutter API endpoint. Accepts an image and an optional prompt.
    If a prompt is provided, it processes the image to remove the background based on the prompt.
    Returns URLs for both the original and edited images.
    
    Returns:
        Response: JSON response containing the URLs of the original and edited images or error messages.
    """
    try:
        if 'image' not in request.files:
            print("No image part in the request")
            return jsonify({"error": "No image part in the request"}), 400
        
        file = request.files['image']
        
        if file.filename == '':
            print("No selected file")
            return jsonify({"error": "No selected file"}), 400
        
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            upload_dir = os.path.join(current_app.root_path, 'static', 'uploaded_images')
            os.makedirs(upload_dir, exist_ok=True)
            original_image_path = os.path.join(upload_dir, filename)
            file.save(original_image_path)
            original_image_url = url_for('serve_image', filename=f'uploaded_images/{filename}', _external=True)
           
            prompt = request.form.get('prompt', '').strip()
            
            # Add debug print statements
            print(f"Received request. Prompt: {prompt}")
            print(f"Original image URL: {original_image_url}")
            
            if prompt:
                # Process the image with the provided prompt
                edited_image_path = process_image_with_prompt(original_image_path, prompt)
                print(f"Edited image path: {edited_image_path}")
                if edited_image_path and os.path.exists(edited_image_path):
                    edited_filename = os.path.basename(edited_image_path)
                    edited_image_url = url_for('serve_image', filename=f'processed_images/{edited_filename}', _external=True)
                    print(f"Edited image URL: {edited_image_url}")
                    return jsonify({
                        "original_image": original_image_url,
                        "edited_image": edited_image_url
                    }), 200
                else:
                    print("Image processing failed")
                    return jsonify({"error": "Image processing failed"}), 500
            else:
                # No prompt provided, return only the original image URL
                print("No prompt provided. Returning original image URL.")
                return jsonify({
                    "original_image": original_image_url
                }), 200
        else:
            print("Invalid file type")
            return jsonify({"error": "Invalid file type"}), 400
    except Exception as e:
        print(f"Exception occurred in /api/object_cutter: {e}")
        return jsonify({"error": "Image processing failed"}), 500


