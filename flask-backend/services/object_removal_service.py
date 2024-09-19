from gradio_client import Client
import os

def remove_object(input_path):
    client = Client("YourUsername/Finegrain-Object-Cutter")  # Replace with actual model
    result = client.predict(
        file=input_path,
        api_name="/remove_object"  # Adjust based on actual API
    )
    output_filename = os.path.basename(result)
    output_path = os.path.join('static', 'processed_images', output_filename)
    os.rename(result, output_path)
    return output_path