# from pypdf import PdfReader
# import re


# output_pdf_path = "C:\\Users\\Administrator\\Desktop\\bucumi.pdf"
# def pdf_extract(output_pdf_path, desired_grade_level="1"):
#     grade_level = None
#     decision_date = None
#     date =[]
#     try:
#         reader = PdfReader(output_pdf_path)
#         for page in reader.pages:
#             text = page.extract_text()
#             if text:
                
#                 if grade_level is None:
#                     match = re.search(r'GRADE:\s*LEVEL\s*(\d+)', text, re.IGNORECASE)
#                     if match:
#                         grade_level = match.group(1)
#                         print(f"GRADE: LEVEL {grade_level}")

#                 date_match = re.search(r'\b\d{2}/\d{2}/\d{4}\b', text)
#                 if date_match:
#                     decision_date = date_match.group()
#                     print(f"Decision Date Found: {decision_date}")

#     except Exception as e:
#         print(f"An error occurred: {str(e)}")
        
#     return  grade_level, decision_date
# pdf_extract(output_pdf_path)

from pypdf import PdfReader
import re
# output_pdf_path= "C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Onboarding_COX\\Technicians\\Austin_Frazier01111994\\austin frazier_ProfileStatus.pdf"
def pdf_extract(output_pdf_path):

    try:
        reader = PdfReader(output_pdf_path)
        text = ''
     
        for page in reader.pages:
            text += page.extract_text()

       
        match = re.search(r'GRADE:\s*LEVEL\s*(\d+)', text, re.IGNORECASE)
        if match:
            grade_level = match.group(1)
            print(f"GRADE: LEVEL {grade_level}")

       
        # Extract dates in the format "Day, MM/DD/YYYY"
        date_pattern = r'\b\w+,\s(\d{2}/\d{2}/\d{4})\b'
        date = re.findall(date_pattern, text)
        
        if len(date) >= 3:
            date = date[2]
            print("Decision_date:", date)
    
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        
    return grade_level, date
# grade_level, date = pdf_extract(output_pdf_path)
