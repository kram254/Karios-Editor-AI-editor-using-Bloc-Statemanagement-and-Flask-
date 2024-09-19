from gradio_client import Client
import os

def process_image(height, width, steps, scales, prompt, seed, input_path):
    client = Client("ByteDance/Hyper-FLUX-8Steps-LoRA")
    result = client.predict(
        height=height,
        width=width,
        steps=steps,
        scales=scales,
        prompt=prompt,
        seed=seed,
        api_name="/process_image"
    )
    output_filename = os.path.basename(result)
    output_path = os.path.join('static', 'generated_images', output_filename)
    os.rename(result, output_path)
    return output_path