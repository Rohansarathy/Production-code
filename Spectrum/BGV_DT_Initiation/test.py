from PIL import Image
import os
from pdf2image import convert_from_path

def compress_image(input_path, output_path, quality=70):
    """Compress the image and save as JPG."""
    try:
        with Image.open(input_path) as img:
            # Convert image to RGB if it's not already
            if img.mode in ("RGBA", "P", "LA"):
                img = img.convert("RGB")
            
            # Save the image in JPEG format with the given compression quality
            img.save(output_path, "JPEG", quality=quality)
            print(f"Image compressed and saved to {output_path}.")
    except Exception as e:
        print(f"Error compressing image: {e}")

def get_file_size_kb(file_path):
    """Return the file size in KB."""
    return os.path.getsize(file_path) / 1024

def check_and_compress_image(file_path, output_path, size_limit_kb=10000, quality=70):
    """Convert the image to JPG if needed and compress if size exceeds the limit."""
    try:
        # Check file size in KB
        file_size_kb = get_file_size_kb(file_path)
        
        # Determine the output path and convert if not a JPG
        file_ext = os.path.splitext(file_path)[1].lower()
        
        if file_ext == '.pdf':
            print(f"File is a PDF. Converting to image...")
            # Convert PDF to image
            images = convert_from_path(file_path)
            # Save the first page as an image (or you could loop through all pages)
            temp_image_path = output_path.replace('.jpg', '_page_1.jpg')
            images[0].save(temp_image_path, 'JPEG')
            file_path = temp_image_path  # Update the file path to the converted image
            file_ext = '.jpg'  # Update extension to jpg
        
        if file_ext not in ['.jpg', '.jpeg']:
            print(f"File is not in JPG format (detected {file_ext}), converting to JPG...")
            output_path = os.path.splitext(output_path)[0] + '.jpg'

        # Compress the image if it's larger than the size limit
        if file_size_kb > size_limit_kb:
            print(f"File size ({file_size_kb:.2f} KB) exceeds {size_limit_kb} KB. Compressing...")
            compress_image(file_path, output_path, quality=quality)
        else:
            print(f"File size ({file_size_kb:.2f} KB) is within the limit. No compression needed.")
            # If the file is already in JPG and within the limit, just copy it as is
            if file_ext in ['.jpg', '.jpeg']:
                with Image.open(file_path) as img:
                    img.save(output_path)
                print(f"File copied as is to {output_path}.")
    except Exception as e:
        print(f"Error processing the image: {e}")

if __name__ == "__main__":
    file_path = r'C:\Users\Administrator\Downloads\DL_back.jpg'  # This is actually a PDF
    output_path = r'C:\Users\Administrator\Downloads\back.jpg'
    check_and_compress_image(file_path, output_path, size_limit_kb=10000, quality=70)
