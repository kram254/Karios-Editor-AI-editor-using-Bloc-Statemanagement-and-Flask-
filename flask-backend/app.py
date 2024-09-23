from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
from services.image_generation_service import process_image
from services.object_removal_service import remove_object

app = Flask(__name__)
CORS(app)

# Configure directories
GENERATED_IMAGES_DIR = os.path.join('static', 'generated_images')
PROCESSED_IMAGES_DIR = os.path.join('static', 'processed_images')
os.makedirs(GENERATED_IMAGES_DIR, exist_ok=True)
os.makedirs(PROCESSED_IMAGES_DIR, exist_ok=True)

@app.route('/process_image', methods=['POST'])
def handle_process_image():
    try:
        prompt = request.form.get('prompt', '')
        if not prompt:
            return jsonify({"error": "No prompt provided"}), 400

        output_path = process_image(prompt)

        return jsonify({"filepath": output_path})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/remove_object', methods=['POST'])
def handle_remove_object():
    try:
        image = request.files.get('file')

        if not image:
            return jsonify({"error": "No image provided"}), 400

        input_path = os.path.join('static', 'input_images')
        os.makedirs(input_path, exist_ok=True)
        input_file_path = os.path.join(input_path, image.filename)
        image.save(input_file_path)

        output_path = remove_object(input_file_path)

        return jsonify({"filepath": output_path})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/static/<path:filename>', methods=['GET'])
def serve_image(filename):
    return send_from_directory('static', filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)


















# from flask import Flask, request, jsonify, send_from_directory
# from flask_cors import CORS
# import os
# from services.image_generation_service import process_image
# from services.object_removal_service import remove_object

# app = Flask(__name__)
# CORS(app)

# # Configure directories
# GENERATED_IMAGES_DIR = os.path.join('static', 'generated_images')
# PROCESSED_IMAGES_DIR = os.path.join('static', 'processed_images')
# os.makedirs(GENERATED_IMAGES_DIR, exist_ok=True)
# os.makedirs(PROCESSED_IMAGES_DIR, exist_ok=True)

# @app.route('/process_image', methods=['POST'])
# def handle_process_image():
#     try:
#         height = int(request.form.get('height', 1024))
#         width = int(request.form.get('width', 1024))
#         steps = int(request.form.get('steps', 8))
#         scales = float(request.form.get('scales', 3.5))
#         prompt = request.form.get('prompt', '')
#         seed = int(request.form.get('seed', 3413))
#         image = request.files.get('file')

#         if not image:
#             return jsonify({"error": "No image provided"}), 400

#         input_path = os.path.join('static', 'input_images')
#         os.makedirs(input_path, exist_ok=True)
#         input_file_path = os.path.join(input_path, image.filename)
#         image.save(input_file_path)

#         output_path = process_image(height, width, steps, scales, prompt, seed, input_file_path)

#         return jsonify({"filepath": output_path})
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500

# @app.route('/remove_object', methods=['POST'])
# def handle_remove_object():
#     try:
#         image = request.files.get('file')

#         if not image:
#             return jsonify({"error": "No image provided"}), 400

#         input_path = os.path.join('static', 'input_images')
#         os.makedirs(input_path, exist_ok=True)
#         input_file_path = os.path.join(input_path, image.filename)
#         image.save(input_file_path)

#         output_path = remove_object(input_file_path)

#         return jsonify({"filepath": output_path})
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500

# @app.route('/static/<path:filename>', methods=['GET'])
# def serve_image(filename):
#     return send_from_directory('static', filename)

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)