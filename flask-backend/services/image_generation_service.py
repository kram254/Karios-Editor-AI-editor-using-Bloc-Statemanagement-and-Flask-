from gradio_client import Client
import os
import uuid
from flask import url_for
import requests
from huggingface_hub import HfApi
import shutil  

# Load the Hugging Face API key from an environment variable
HF_API_KEY = os.getenv("HF_API_KEY")


def get_next_image_filename(output_dir, base_name="image", extension=".png"):
    """
    Determines the next available filename in the specified directory following a sequential pattern.
    
    Args:
        output_dir (str): Path to the directory where images are stored.
        base_name (str): Base name for the images.
        extension (str): File extension for the images.
        
    Returns:
        str: The next available filename.
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
    
    # Start with base_name + extension
    filename = f"{base_name}{extension}"
    filepath = os.path.join(output_dir, filename)
    
    if not os.path.exists(filepath):
        return filename
    
    # If base_name.png exists, start appending numbers
    counter = 1
    while True:
        filename = f"{base_name}{counter}{extension}"
        filepath = os.path.join(output_dir, filename)
        if not os.path.exists(filepath):
            return filename
        counter += 1


def process_image(height, width, steps, scales, prompt, seed):
    try:
        client = Client("ByteDance/Hyper-FLUX-8Steps-LoRA")

        # Predict using the Flux model
        result = client.predict(
            prompt=prompt,
            height=height,
            width=width,
            steps=steps,
            scales=scales,
            seed=seed,
            api_name="/process_image" 
        )

        output_dir = os.path.join('static', 'generated_images')
        filename = get_next_image_filename(output_dir)
        output_path = os.path.join(output_dir, filename)

        # Check if 'result' is a URL
        if isinstance(result, str) and (result.startswith("http://") or result.startswith("https://")):
            response = requests.get(result)
            if response.status_code == 200:
                with open(output_path, 'wb') as f:
                    f.write(response.content)
            else:
                raise Exception("Failed to download the generated image.")
        else:
            # If 'result' is a local path, move it with the new sequential filename
            output_filename = os.path.basename(result)
            new_output_path = os.path.join(output_dir, filename)
            shutil.move(result, new_output_path)
            output_path = new_output_path

        # Generate the URL for the generated image
        image_url = url_for('serve_image', filename=f'generated_images/{filename}', _external=True)
        return image_url

    except Exception as e:
        print(f"Error in process_image: {e}")
        raise




























    #     # Assuming 'result' is the URL or path to the generated image
    #     if isinstance(result, str) and (result.startswith("http://") or result.startswith("https://")):
    #         response = requests.get(result)
    #         if response.status_code == 200:
    #             filename = f"{uuid.uuid4()}.png"  # Generate a unique filename
    #             output_dir = os.path.join('static', 'generated_images')
    #             os.makedirs(output_dir, exist_ok=True)
    #             output_path = os.path.join(output_dir, filename)
    #             with open(output_path, 'wb') as f:
    #                 f.write(response.content)
    #         else:
    #             raise Exception("Failed to download the generated image.")
    #     else:
    #         # If 'result' is a local path
    #         output_filename = os.path.basename(result)
    #         output_dir = os.path.join('static', 'generated_images')
    #         os.makedirs(output_dir, exist_ok=True)
    #         output_path = os.path.join(output_dir, output_filename)
    #         shutil.move(result, output_path)  # Use shutil.move instead of os.rename

    #     # Return the path relative to the 'static' directory
    #     return output_path

    # except Exception as e:
    #     print(f"Error in process_image: {e}")
    #     raise









































# from gradio_client import Client
# import os
# import uuid
# import requests
# from huggingface_hub import HfApi

# # Load the Hugging Face API key from an environment variable
# HF_API_KEY = os.getenv("HF_API_KEY")

# def process_image(height, width, steps, scales, prompt, seed):
#     # Initialize the Gradio client for Hyper-FLUX-8Steps-LoRA with the API key
#     client = Client("ByteDance/Hyper-FLUX-8Steps-LoRA")

#     # Predict using the Flux model
#     result = client.predict(
#         prompt=prompt,
#         height=height,
#         width=width,
#         steps=steps,
#         scales=scales,
#         seed=seed,
#         api_name="/process_image" 
#     )

#     # Assuming 'result' is the URL or path to the generated image
#     # If it's a URL, download the image first
#     if isinstance(result, str) and (result.startswith("http://") or result.startswith("https://")):
#         response = requests.get(result)
#         if response.status_code == 200:
#             filename = f"{uuid.uuid4()}.png"
#             output_dir = os.path.join('static', 'generated_images')
#             os.makedirs(output_dir, exist_ok=True)
#             output_path = os.path.join(output_dir, filename)
#             with open(output_path, 'wb') as f:
#                 f.write(response.content)
#         else:
#             raise Exception("Failed to download the generated image.")
#     else:
#         # If 'result' is a local path
#         output_filename = os.path.basename(result)
#         output_dir = os.path.join('static', 'generated_images')
#         os.makedirs(output_dir, exist_ok=True)
#         output_path = os.path.join(output_dir, output_filename)
#         os.rename(result, output_path)

#     # Return the path relative to the 'static' directory
#     return output_path

