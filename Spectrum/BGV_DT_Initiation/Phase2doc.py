import pypdf

def split_pdf(input_pdf_path, output_pdf_path):
    with open(input_pdf_path, 'rb') as pdf_file:
        reader = pypdf.PdfReader(pdf_file)
        num_pages = len(reader.pages)

        # Set the range to extract pages 10 to 13 (inclusive)
        start_page = 9 
        end_page = 13

        # Check if the range of pages is available
        if num_pages < end_page:
            print(f"Error: The PDF only has {num_pages} pages. Cannot extract pages {start_page + 1} to {end_page}.")
            return

        # Create a writer object
        writer = pypdf.PdfWriter()

        # Add pages 10 to 13 (0-indexed, so 9 to 12) to the writer
        for i in range(start_page, end_page):
            writer.add_page(reader.pages[i])

        # Write the pages to a new PDF file
        with open(output_pdf_path, 'wb') as output_pdf_file:
            writer.write(output_pdf_file)

# # Example usage
# split_pdf(input_pdf_path, output_pdf_path)



# def split_pdf(input_pdf_path, output_pdf_path):
#     with open(input_pdf_path, 'rb') as pdf_file:
#         reader = pypdf.PdfReader(pdf_file)
#         num_pages = len(reader.pages)

#         # Create a writer object
#         writer = pypdf.PdfWriter()

#         # Add pages 10 to 14 to the writer (0-indexed, so 9 to 13)
#         for i in range(9, 14):
#             writer.add_page(reader.pages[i])

#         # Write the pages to a new PDF file
#         with open(output_pdf_path, 'wb') as output_pdf_file:
#             writer.write(output_pdf_file)


# import PyPDF2

# def split_pdf(input_pdf_path, output_pdf_path):
#     print(f"{input_pdf_path}")

#     with open(input_pdf_path, 'rb') as pdf_file:
#         reader = PyPDF2.PdfReader(pdf_file)
#         num_pages = len(reader.pages)

#         # Create a writer object
#         writer = PyPDF2.PdfWriter()

#         # Add the last three pages to the writer
#         for i in range(num_pages - 5, num_pages):
#             writer.add_page(reader.pages[i])

#         # Write the pages to a new PDF file
#         with open(output_pdf_path, 'wb') as output_pdf_file:
#             writer.write(output_pdf_file)
            

