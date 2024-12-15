import os
from PIL import Image
from pdf2image import convert_from_path

# Function to convert PDF to JPG
def convert_pdf_to_images(pdf_path, output_folder, poppler_path):
    images = convert_from_path(pdf_path, poppler_path=poppler_path)
    
    base_name = os.path.splitext(os.path.basename(pdf_path))[0]
    
    for index, image in enumerate(images):
        output_file = os.path.join(output_folder, f'{base_name}.jpg')
        if not os.path.exists(output_file):
            image.save(output_file, 'JPEG')
            print(f'Saved: {output_file}')

# Function to convert .jpeg to .jpg
def convert_jpeg_to_jpg(image_path):
    if image_path.lower().endswith('.jpeg'):
        with Image.open(image_path) as img:
            new_file_path = os.path.splitext(image_path)[0] + ".jpg"
            if not os.path.exists(new_file_path):
                img.save(new_file_path, "JPEG")
                print(f'Converted: {image_path} -> {new_file_path}')

# Function to convert .png to .jpg
def convert_png_to_jpg(png_path):
    if png_path.lower().endswith('.png'):
        with Image.open(png_path) as img:
            new_file_path = os.path.splitext(png_path)[0] + ".jpg"
            if not os.path.exists(new_file_path):
                img = img.convert('RGB')
                img.save(new_file_path, "JPEG")
                print(f'Converted: {png_path} -> {new_file_path}')






# import os
# from pdf2image import convert_from_path

# def convert_pdf_to_images(pdf_path, output_folder, poppler_path):
#     images = convert_from_path(pdf_path, poppler_path=poppler_path)
    
#     base_name = os.path.splitext(os.path.basename(pdf_path))[0]
    
#     for index, image in enumerate(images):
#         output_file = os.path.join(output_folder, f'{base_name}.jpg')
#         image.save(output_file, 'JPEG')
#         print(f'Saved: {output_file}')

# if __name__ == "__main__":
#     import sys
#     pdf_path = sys.argv[1]
#     output_folder = sys.argv[2]
#     poppler_path = sys.argv[3]
#     convert_pdf_to_images(pdf_path, output_folder, poppler_path)

