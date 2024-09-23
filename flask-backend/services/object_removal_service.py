from gradio_client import Client
import os

def remove_object(input_path):
    # Initialize the Gradio client for Finegrain Object Cutter
    client = Client("YourUsername/Finegrain-Object-Cutter")  # Replace with the actual model name

    # Predict using the model
    result = client.predict(
        file=input_path,
        api_name="/remove_object"  # Adjust based on the actual API endpoint
    )

    # Assuming 'result' is the path to the processed image
    output_filename = os.path.basename(result)
    output_dir = os.path.join('static', 'processed_images')
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, output_filename)

    # Move the processed image to the 'processed_images' directory
    os.rename(result, output_path)

    # Return the path relative to the 'static' directory
    return output_path