from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
from services.image_generation_service import process_image
from services.object_removal_service import remove_object

app = Flask(__name__)
CORS(app)

# Ensure directories exist
GENERATED_IMAGES_DIR = os.path.join('static', 'generated_images')
PROCESSED_IMAGES_DIR = os.path.join('static', 'processed_images')
os.makedirs(GENERATED_IMAGES_DIR, exist_ok=True)
os.makedirs(PROCESSED_IMAGES_DIR, exist_ok=True)

@app.route('/process_image', methods=['POST'])
def handle_process_image():
    height = request.form.get('height', 1024, type=int)
    width = request.form.get('width', 1024, type=int)
    steps = request.form.get('steps', 8, type=int)
    scales = request.form.get('scales', 3.5, type=float)
    prompt = request.form.get('prompt', '', type=str)
    seed = request.form.get('seed', 3413, type=int)
    image = request.files.get('file')

    if image:
        input_path = os.path.join(GENERATED_IMAGES_DIR, image.filename)
        image.save(input_path)
        output_path = process_image(height, width, steps, scales, prompt, seed, input_path)
        return jsonify({"filepath": output_path})
    return jsonify({"error": "No image provided"}), 400

@app.route('/remove_object', methods=['POST'])
def handle_remove_object():
    image = request.files.get('file')

    if image:
        input_path = os.path.join(PROCESSED_IMAGES_DIR, image.filename)
        image.save(input_path)
        output_path = remove_object(input_path)
        return jsonify({"filepath": output_path})
    return jsonify({"error": "No image provided"}), 400

@app.route('/static/<path:filename>', methods=['GET'])
def serve_image(filename):
    return send_from_directory('static', filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)