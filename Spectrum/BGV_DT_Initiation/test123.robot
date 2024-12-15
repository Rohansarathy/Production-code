*** Settings ***
Documentation       OnBoarding Process-Spectrum BGV_DT_Initiating

Library             OperatingSystem
Library             RPA.JSON
Resource            Crimshield_login.robot
Resource            Fuselogin.robot
Resource            Techsearch.robot
Resource            Killtask.robot
Resource            Techsearch.robot
Library             RPA.Excel.Files
Resource            Fusedocs_Download.robot
Library             Movefiles.py
Resource            BGV_Initiation.robot
Resource            DT_Renewal.robot
Resource            EpassportExtract.robot
Resource            DT&BGVFuseupdate.robot
Resource            DT_BGV_Renewal.robot
Library             DateTime

*** Variables ***
${Epass_Path}                   C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data
${Epass_name}                   ${EMPTY}
${OUTPUT_PDF_PATH}              ${EMPTY}
${SOURCE_FOLDER}                C:\\Users\\Administrator\\Downloads
${DESTINATION_FOLDER}           C:\\Users\\Administrator\\Documents
${STATE_ID_DOWNLOAD_XPATH}      (//a[contains(text(), 'Upload State Issued ID')]/following-sibling::a[contains(@class, 'download-link')])
${SSN_DOWNLOAD_XPATH}           (//a[contains(text(), 'Upload SSN')]/following-sibling::a[contains(@class, 'download-link')])
${AUTH_DOWNLOAD_XPATH}          (//a[contains(text(), 'Upload Authorization')]/following-sibling::a[contains(@class, 'download-link')])

${SAVE_PATH}     C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data
*** Tasks ***
Process
    Onboarding process


*** Keywords ***
Onboarding Process
    # Vault
    # ${credentials}    Load JSON from file    credentials.json
    # # DB Connect
    # Connect To Database
    # ...    psycopg2
    # ...    ${credentials}[DB_NAME]
    # ...    ${credentials}[DB_USERNAME]
    # ...    ${credentials}[DB_PASSWORD]
    # ...    ${credentials}[DB_HOST]
    # ...    ${credentials}[DB_PORT]
    # Log To Console    DB Connected
    # ${Time}    Get Time
    # ${year}    Set Variable    ${Time}[0:4]
    # ${month}    Set Variable    ${Time}[5:7]
    # ${day}    Set Variable    ${Time}[8:10]
    # ${mint}    Set Variable    ${Time}[11:13]
    # ${Sec}    Set Variable    ${Time}[14:16]
    # ${Log}    Set Variable    ${credentials}[Logfile]\\DT&BGV_${day}${month}${year}_${mint}_${Sec}.txt
    # Create File    ${Log}
    # # Get column names
    # ${columns}    Query
    # ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'spectrum_onboarding' AND table_schema = 'public'
    # @{column_names}    Create List
    # FOR    ${col}    IN    @{columns}
    #     Append To List    ${column_names}    ${col}[0]
    # END
    # # Get data rows
    # # ${result}    Query    SELECT * FROM public.spectrum_onboarding where status is Null OR status = '' LIMIT 1;
    # ${result}    Query    SELECT * FROM public.spectrum_onboarding where ssn = '400911425'
    # Combine headers and data rows
    # FOR    ${row}    IN    @{result}
    #     ${Alldatas}    Create Dictionary
    #     ${num_columns}    Get Length    ${column_names}
    #     FOR    ${i}    IN RANGE    ${num_columns}
    #         Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
    #     END
        # Open Available Browser    ${credentials}[CrimShieldURL]
        # Maximize Browser Window
        # ${FuseLogin}    Fuse Login    ${credentials}    ${Log}
        # ${Tech_found_flag}    Techsearch    ${Alldatas}    ${credentials}    ${Log}
        # ${Docflag}    ${flag4}    Fusedocs_Download    ${Alldatas}    ${Epass_Path}    ${Log}
        
        # TRY
            ${input_folder}    set Variable    C:\\Users\\Administrator\\Documents\\Testing
            ${output_folder}    set Variable    C:\\Users\\Administrator\\Documents\\Testing
            ${poppler_path}    set Variable
            ...    C:\\Users\\Administrator\\Downloads\\Release-24.08.0-0\\poppler-24.08.0\\Library\\bin
            ${files}    List Files In Directory    ${input_folder}
            FOR    ${file}    IN    @{files}
                ${full_path}    Join Path    ${input_folder}    ${file}
                ${is_pdf}    Evaluate    str(${file.lower().endswith(('ssn.pdf', 'dl_back.pdf', 'dl_front.pdf'))})
                IF    ${is_pdf}
                    Log To Console    ${is_pdf}
                    ${pdf_path}    Join Path    ${input_folder}    ${file}
                    convert_pdf_to_images    ${pdf_path}    ${output_folder}    ${poppler_path}
                    Log To Console    PDF to JPG converted.
                END
                ${is_jpeg}    Evaluate    str(${file.lower().endswith('.jpeg')})
                IF    ${is_jpeg}
                    Log To Console    ${is_jpeg}
                    ${image_path}    Join Path    ${input_folder}    ${file}
                    convert_jpeg_to_jpg    ${image_path}
                    Log To Console    JPEG to JPG converted.
                END
            END
        # EXCEPT
        #     Log To Console    Error occured while converting PDF to Image.
        #     # Append To File    ${Log}    Error occured while converting PDF to Image.\n
        # END
    # END
