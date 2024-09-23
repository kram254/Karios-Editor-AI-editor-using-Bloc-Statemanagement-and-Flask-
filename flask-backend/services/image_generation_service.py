from gradio_client import Client
import os
import uuid

def process_image(height, width, steps, scales, prompt, seed, input_path):
    # Initialize the Gradio client for Hyper-FLUX-8Steps-LoRA
    client = Client("ByteDance/Hyper-FLUX-8Steps-LoRA")

    # Predict using the Flux model
    result = client.predict(
        prompt=prompt,
        api_name="/generate"  # Adjust based on the Flux model's API endpoint
    )

    # Assuming 'result' is the URL or path to the generated image
    # If it's a URL, download the image first
    if result.startswith("http://") or result.startswith("https://"):
        import requests
        response = requests.get(result)
        if response.status_code == 200:
            filename = f"{uuid.uuid4()}.png"
            output_dir = os.path.join('static', 'generated_images')
            os.makedirs(output_dir, exist_ok=True)
            output_path = os.path.join(output_dir, filename)
            with open(output_path, 'wb') as f:
                f.write(response.content)
        else:
            raise Exception("Failed to download the generated image.")
    else:
        # If 'result' is a local path
        output_filename = os.path.basename(result)
        output_dir = os.path.join('static', 'generated_images')
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, output_filename)
        os.rename(result, output_path)

    # Return the path relative to the 'static' directory
    return output_path



