from PIL import Image
import argparse
import os

def compress_image(input_path, output_path, quality=70):
    with Image.open(input_path) as img:
        img.save(output_path, "JPEG", quality=quality)

def check_and_compress_image(file_path, output_path, size_limit_kb=9000):
    file_size_kb = os.path.getsize(file_path) / 1024
    
    if file_size_kb > size_limit_kb:
        print(f"File size ({file_size_kb:.2f} KB) exceeds {size_limit_kb} KB. Compressing...")
        compress_image(file_path, output_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Compress an image if it exceeds a specified size limit.')
    parser.add_argument('input_image_path', help='Path to the input image')
    parser.add_argument('output_image_path', help='Path to save the compressed image')
    
    args = parser.parse_args()
    check_and_compress_image(args.input_image_path, args.output_image_path)
