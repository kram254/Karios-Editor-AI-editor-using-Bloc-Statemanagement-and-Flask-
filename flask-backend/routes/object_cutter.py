from flask import Blueprint, request, jsonify, url_for
from werkzeug.utils import secure_filename
import os
from flask_backend.services.object_cutter_service import (
    process_image_with_prompt,
    save_processed_image,
    get_processed_image_url
)

# Initialize the Blueprint for object cutter routes
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
    Handle the object cutter API endpoint. Accepts an image and a prompt, processes the image
    using the Finegrain Object Cutter model, and returns URLs for both the original and edited images.
    
    Returns:
        Response: JSON response containing the URLs of the original and edited images or error messages.
    """
    # Check if the 'image' part is present in the request
    if 'image' not in request.files:
        return jsonify({'error': 'No image part in the request'}), 400
    
    file = request.files['image']
    prompt = request.form.get('prompt', '')

    # Validate that a file was selected
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    # Validate the file extension
    if file and allowed_file(file.filename):
        # Secure the filename to prevent directory traversal attacks
        filename = secure_filename(file.filename)
        upload_dir = os.path.join('static', 'uploads')
        
        # Create the upload directory if it doesn't exist
        os.makedirs(upload_dir, exist_ok=True)
        image_path = os.path.join(upload_dir, filename)
        
        # Save the uploaded image to the server
        file.save(image_path)

        # Process the image with the provided prompt using the Object Cutter service
        result_path = process_image_with_prompt(image_path, prompt)
        
        if result_path and os.path.exists(result_path):
            # Move the processed image to the 'processed_images' directory
            saved_path = save_processed_image(result_path)
            
            # Generate URLs for the original and edited images
            edited_image_url = get_processed_image_url(os.path.basename(saved_path))
            original_image_url = url_for('static', filename=f'uploads/{filename}', _external=True)
            
            return jsonify({
                'original_image': original_image_url,
                'edited_image': edited_image_url
            }), 200
        else:
            # If image processing failed, return an error
            return jsonify({'error': 'Image processing failed'}), 500
    else:
        # If the file extension is not allowed, return an error
        return jsonify({'error': 'Allowed file types are png, jpg, jpeg'}), 400