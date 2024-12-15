# import pypdf

# def split_pdf(input_pdf_path, output_pdf_path):
#     try:
#         with open(input_pdf_path, 'rb') as pdf_file:
#             reader = pypdf.PdfReader(pdf_file)
#             num_pages = len(reader.pages)

#             # Check if the range of pages is available
            
            
#             if num_pages == 0:
#                 print(f"Error: The PDF only has {num_pages} pages. Cannot extract pages {start_page + 1}")
#                 return False

#             # Create a writer object
#             start_page = 0
#             writer = pypdf.PdfWriter()

            
#             # for i in range(start_page):
#             writer.add_page(reader.pages[start_page])

#             # Write the pages to a new PDF file
#             with open(output_pdf_path, 'wb') as output_pdf_file:
#                 writer.write(output_pdf_file)
#     except FileNotFoundError:
#         print(f"Error: The file {input_pdf_path} was not found.")
#         return False
#     except Exception as e:
#         print(f"An error occurred: {e}")
#         return False


from pypdf import PdfReader, PdfWriter
import re

# input_pdf_path = "C:\\Users\\Rohansarathy\\OneDrive - Yitro Global\\Documents\\Angel_Ramirez.pdf"
# output_pdf_path = "C:\\Users\\Rohansarathy\\OneDrive - Yitro Global\\Documents\\angel.pdf"

def split_pdf(input_pdf_path, output_pdf_path, page_marker_regex=r"Page \d+/\d+"):
    try:
        reader = PdfReader(input_pdf_path)
        writer = PdfWriter()
        num_pages = len(reader.pages)

        # Compile the regular expression for matching the page marker
        page_marker_pattern = re.compile(page_marker_regex)

        # Iterate over each page
        for i in range(num_pages):
            page = reader.pages[i]
            text = page.extract_text()

            if text and page_marker_pattern.search(text):
                # Add the page to the writer if it matches the pattern
                writer.add_page(page)
                break  # Stop after finding the relevant page

        # Write the selected pages to a new PDF
        with open(output_pdf_path, 'wb') as output_pdf_file:
            writer.write(output_pdf_file)
        return True

    except Exception as e:
        print(f"An error occurred: {e}")
        return False

# Call the function to split the PDF
# split_pdf_by_page_number(input_pdf_path, output_pdf_path)
