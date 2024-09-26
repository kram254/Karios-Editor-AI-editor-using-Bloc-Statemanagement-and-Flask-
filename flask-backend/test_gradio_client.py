from gradio_client import Client
import os

HF_API_KEY = os.getenv("HF_API_KEY")

def test_gradio():
    client = Client("https://huggingface.co/spaces/ByteDance/Hyper-FLUX-8Steps-LoRA")
    result = client.predict(
           prompt="A beautiful landscape painting",
           height=512,
           width=512,
           steps=50,
           scales=7.5,
           seed=42,
           api_name="/process_image"
    )
    print(result)

if __name__ == "__main__":
    test_gradio()