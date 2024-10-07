from services.object_removal_service import process_image_with_prompt

def test_gradio_client():
    img_path = 'https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png'  # Use a URL as per documentation
    prompt = 'remove the background'
    result = process_image_with_prompt(img_path, prompt)
    if result:
        print(f"Processed image saved at: {result}")
    else:
        print("Image processing failed.")

if __name__ == '__main__':
    test_gradio_client()





