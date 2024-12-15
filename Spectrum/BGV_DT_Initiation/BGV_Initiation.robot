*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     DateTime
Library     String
Library     Collections
Resource    DT_Initiation.robot
Resource    Crimshield_login.robot
Resource    Fuselogin.robot
Library     RPA.Desktop
Library     OperatingSystem
Library     Sendmail.py
Resource    Killtask.robot
Resource    Employee_search.robot
Library     Image_compress.py
Library     PDFtoJPG.py


*** Variables ***
${ERROR_TEXTS1}         Social Security Number is required
${ERROR_TEXTS2}         Please enter a valid SSN
${MAX_ITERATIONS}       2
${doc}                  ${EMPTY}
${Body1}                ${EMPTY}
${Body2}                ${EMPTY}
${CC}                   ${EMPTY}
${error1}               False
${error2}               False
${db_full_name1}        ${EMPTY}


*** Keywords ***
BGV_Initiation
    [Arguments]    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Log}    ${OUTPUT_PDF_PATH}

    Log To Console    *********************BGV_Initiation*********************.
    Append To File    ${Log}    *********************BGV_Initiation***********************\n
    ${handles}    Get Window Titles
    Switch window    ${handles}[0]
    Sleep    2s
    IF    "${Alldatas}[process]" == "pre_employment" or "${Alldatas}[process]" == "renewal_bgv_dt"
        IF    "${Alldatas}[dt_status]" == "BG_Processed"
            Log To Console    Employee search
            ${record_flag}    Employee_search    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Log}
            Log To Console    record_flag=${record_flag}
            Append To File    ${Log}    record_flag=${record_flag}.\n
        ELSE
            ${record_flag}    Set Variable    False
        END
        IF    ${record_flag} == False
            ##############################Personal_Information#############################
            TRY
                ${Verifications1}=    Run Keyword And Return Status
                ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                ...    //div[text()='APPLICATION RENEWAL']
                ...    10s
                IF    ${Verifications1}
                    Click Element If Visible    //span[text()='No']
                    Log To Console    Application RENEWAL Appear
                    Append To File    ${Log}    Application RENEWAL Appear
                END
                ${Verifications3}=    Run Keyword And Return Status
                ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                ...    //div[text()='No Tech ID']
                ...    3s
                IF    ${Verifications3}
                    Click Element If Visible    //*[@id="invalid-tech-div-dialog"]/div/div[3]/div/div[3]/div/a/span
                    Log To Console    No Tech ID
                    Append To File    ${Log}    No Tech ID POPUP appear
                END
            EXCEPT
                Log To Console    No POPUP is Appear
                Append To File    ${Log}    No POPUP is Appear
            END
            Wait Until Element Is Visible    (//i[@class='uk-icon-file'])[1]    10s
            Click Element If Visible    (//i[@class='uk-icon-file'])[1]
            Log To Console    license_state=${Alldatas}[business_unit]
            ${tech_unit1}    Set Variable    ${Alldatas}[business_unit]
            ${tech_unit1}    Replace String    ${tech_unit1}    _    ' '
            ${Cleaned_String1}    Replace String    ${tech_unit1}    '    ${EMPTY}
            ${business_unit}    convert to Uppercase    ${Cleaned_String1}
            IF    "${business_unit}" == "DONISOLUTIONS INC.-ITG COMMUNICATIONS, LLC"
                ${business_unit}    Set Variable    DONISOLUTIONS INC. - ITG COMMUNCATIONS, LLC
            END
            IF    "${business_unit}" == "SE COMMUNICATIONS - ITG COMMUNICATIONS, LLC"
                ${business_unit}    Set Variable    S. E. COMMUNICATIONS - ITG COMMUNICATIONS, LLC
            END
            Log To Console    Business_unit=${business_unit}
            Sleep    2s
            Wait Until Element Is Visible    //*[@id="childClientOptions"]    5s
            Select From List By Label    //*[@id="childClientOptions"]    ${business_unit}

            Wait Until Element Is Visible    //input[@id='firstName']    5s
            Input Text    //input[@id='firstName']    ${Alldatas}[tech_first_name]
            IF    "${Alldatas}[tech_middle_name]" != " " and "${Alldatas}[tech_middle_name]" != "None" and "${Alldatas}[tech_middle_name]" != ""
                Input Text    //input[@id='middleName']    ${Alldatas}[tech_middle_name]
            ELSE
                Input Text    //input[@id='middleName']    NONE
            END
            Input Text    //input[@id='lastName']    ${Alldatas}[tech_last_name]

            Wait Until Element Is Visible    //input[@id='socialSecurityNumber']    5s
            Click Element If Visible    //*[@id="socialSecurityNumber"]
            RPA.Desktop.Type Text    ${Alldatas}[ssn]
            TRY
            ${error1}    Run Keyword And Return Status
            ...    Element Text Should Be
            ...    //p[@for="socialSecurityNumber" and contains(@class, "error")]
            ...    5s
            IF    ${error1} == True
                Execute JavaScript    document.getElementById("socialSecurityNumber").value = "${Alldatas}[ssn]"
                Log To Console    ssn1 entered.
                Append To File    ${Log}    ssn1 entered.\n
            END
            EXCEPT
                Log To Console    Already ssn1 entered.
                Append To File    ${Log}    Already ssn1 entered.\n
            END

            Wait Until Element Is Visible    //input[@id='socialSecurityNumberConfirmation']    5s
            Click Element If Visible    //*[@id="socialSecurityNumberConfirmation"]
            RPA.Desktop.Type Text    ${Alldatas}[ssn]
            TRY
            ${error2}    Run Keyword And Return Status
            ...    Element Text Should Be
            ...    //p[@for="socialSecurityNumber" and contains(@class, "error")]
            ...    5s
            IF    ${error2} == True
                Execute JavaScript    document.getElementById("socialSecurityNumberConfirmation").value = "${Alldatas}[ssn]"
                Log To Console    ssn2 entered.
                Append To File    ${Log}    ssn2 entered.\n
            END
            EXCEPT
                Append To File    ${Log}    Already ssn2 entered.\n
                Log To Console    Already ssn2 entered.
            END

            Input Text    //input[@id='email']    ${Alldatas}[tech_mail_id]
            Input Text    //input[@id='addressLine1']    ${Alldatas}[tech_address]
            Input Text    //input[@id='city']    ${Alldatas}[tech_city]

            ${tech_state1}    Set Variable    ${Alldatas}[license_state]
            ${tech_state1}    Replace String    ${tech_state1}    _    ' '
            ${Cleaned_String1}    Replace String    ${tech_state1}    '    ${EMPTY}
            ${Tech_state}    Convert To Title Case    ${Cleaned_String1}
            IF    "${Tech_state}" == "District Of Columbia"
                ${Tech_state}    Set Variable    District of Columbia
            END
            IF    "${Tech_state}" == "federated' 'states' 'of' 'micronesia"
                ${Tech_state}    Set Variable    Federated States of Micronesia
            END
            IF    "${Tech_state}" == "Armed Forces Americas Except Canada"
                ${Tech_state}    Set Variable    Armed Forces Americas (Except Canada)
            END
            IF    "${Tech_state}" == "Armed Forces International Except Americas"
                ${Tech_state}    Set Variable    Armed Forces (International Except Americas)
            END
            Log To Console    Tech_state= ${Tech_state}
            Select From List By Label    //*[@id="stateCode"]    ${Tech_state}

            Wait Until Element Is Visible    //input[@id='zipCode']    5s
            Click Element If Visible    //input[@id='zipCode']
            RPA.Desktop.Type Text    ${Alldatas}[tech_zip_code]

            ${Tech_DOB}    Convert To String    ${Alldatas}[tech_dob]
            ${date_components}    Split String    ${Tech_DOB}    -
            ${DOBYear}    Get From List    ${date_components}    0
            ${DOBMonth}    Get From List    ${date_components}    1
            ${DOBDay}    Get From List    ${date_components}    2
            ${tech_dob}    set variable    ${DOBMonth}/${DOBDay}/${DOBYear}
            Log To Console    DOB=${tech_dob}
            Click Element If Visible    //input[@id='dateOfBirthString']
            Input Text    //input[@id='dateOfBirthString']    ${tech_dob}

            Input Text    //input[@id='homePhoneNumber']    ${Alldatas}[tech_phone_no]
            TRY
                ${error1}    Run Keyword And Return Status
                ...    Element Text Should Be
                ...    //p[@for="socialSecurityNumber" and contains(@class, "error")]
                ...    ${ERROR_TEXTS1}
                Log To Console    error1=${error1}
                ${error2}    Run Keyword And Return Status
                ...    Element Text Should Be
                ...    //p[@for="socialSecurityNumber" and contains(@class, "error")]
                ...    ${ERROR_TEXTS2}
                Log To Console    error2=${error2}
            EXCEPT
                Log To Console    SSN entered successfully.
            END
            IF    ${error1} == False and ${error2} == False
                ${data_flag}    Set Variable    True
            ELSE
                ${data_flag}    Set Variable    False
            END
            ####################################### Employment Badge Process #######################################
            IF    ${data_flag} == True
                ${tech_badge1}    Set Variable    ${Alldatas}[badge]
                ${tech_badge1}    Replace String    ${tech_badge1}    _    ' '
                ${Cleaned_String1}    Replace String    ${tech_badge1}    '    ${EMPTY}
                ${badge}    convert to Title Case    ${Cleaned_String1}
                ${badge}    Replace String    ${badge}    Pc    PC
                ${badge}    Replace String    ${badge}    Ny    NY
                ${badge}    Replace String    ${badge}    Ca    CA
                ${badge}    Replace String    ${badge}    Tx    TX
                ${badge}    Replace String    ${badge}    -elite    -Elite
                ${badge}    Replace String    ${badge}    -orlando    -Orlando
                ${badge}    Replace String    ${badge}    -montgomery    -Montgomery
                ${PCbadge}    Set Variable    //option[text()='${badge}']
                IF    "${badge}" == "Infinite Kaely Norris"
                    ${badge}    Set Variable    Infinite _ Kaely Norris
                    ${PCbadge}    Set Variable    //option[text()='${badge}']
                END
                IF    "${badge}" == "PC100-corporate"
                    ${badge}    Set Variable    PC100-Corporate
                    ${PCbadge}    Set Variable    //option[text()='${badge} ']
                END
                IF    "${badge}" == "PC446 - Cincinnati South"
                    ${badge}    Set Variable    PC446 - Cincinnati South
                    ${PCbadge}    Set Variable    //option[text()='${badge} ']
                END
                Log To Console    PCBadge=${PCbadge}
                Click Element If Visible    //*[@id="retailLocation"]
                Click Element If Visible    ${PCbadge}

                ${tech_state1}    Set Variable    ${Alldatas}[employment_state]
                ${tech_state1}    Replace String    ${tech_state1}    _    ' '
                ${Cleaned_String1}    Replace String    ${tech_state1}    '    ${EMPTY}
                ${Emp_state}    Convert To Title Case    ${Cleaned_String1}
                IF    "${Emp_state}" == "District Of Columbia"
                    ${Emp_state}    Set Variable    District of Columbia
                END
                IF    "${Emp_state}" == "federated' 'states' 'of' 'micronesia"
                    ${Emp_state}    Set Variable    Federated States of Micronesia
                END
                IF    "${Emp_state}" == "Armed Forces Americas Except Canada"
                    ${Emp_state}    Set Variable    Armed Forces Americas (Except Canada)
                END
                IF    "${Emp_state}" == "Armed Forces International Except Americas"
                    ${Emp_state}    Set Variable    Armed Forces (International Except Americas)
                END
                IF    "${Emp_state}" == "new_york_city"
                    ${Emp_state}    Set Variable    New York City
                END
                Log To Console    Emp_state= ${Emp_state}
                Wait Until Element Is Visible    //*[@id="currentEmploymentState"]    timeout=10s
                Select From List By Label    //*[@id="currentEmploymentState"]    ${Emp_state}
                sleep    1s
                IF    "${business_unit}" == "ITG COMMUNICATIONS - INFINITE COMMUNICATIONS"
                    Wait Until Element Is Visible    //*[@id="employmentContractTypeId"]    5s
                    IF    "${Alldatas}[tax_term]" == "w2"
                        Select From List By Value    //*[@id="employmentContractTypeId"]    1
                    ELSE
                        Select From List By Value    //*[@id="employmentContractTypeId"]    2
                    END
                END
                TRY
                    ${radio_button}    Run Keyword And Return Status
                    ...    Element Should Be Visible
                    ...    //*[@id="overStateLaw1"]
                    ...    10s
                    IF    "${radio_button}" == "True"
                        Click Element If Visible    //*[@id="overStateLaw1"]
                        Log To Console    Radio button    found
                    END
                EXCEPT
                    Log To Console    Radio button Not found
                END
                ################################ Compressing the IMG>900KB ################################
                TRY
                    ${input_image_path}    Set Variable    ${Epass_Path}\\SSN.jpg
                    ${output_image_path}    Set Variable    ${Epass_Path}\\SSN.jpg
                    check_and_compress_image    ${input_image_path}    ${output_image_path}
                    ${input_image_path}    Set Variable    ${Epass_Path}\\DL_front.jpg
                    ${output_image_path}    Set Variable    ${Epass_Path}\\DL_front.jpg
                    check_and_compress_image    ${input_image_path}    ${output_image_path}
                    ${input_image_path}    Set Variable    ${Epass_Path}\\DL_back.jpg
                    ${output_image_path}    Set Variable    ${Epass_Path}\\DL_back.jpg
                    check_and_compress_image    ${input_image_path}    ${output_image_path}
                    Log To Console    All Image compressed
                    Append To File    ${Log}    All Image compressed.\n               
                EXCEPT 
                    Log To Console    Error occured while Image compressing.
                    Append To File    ${Log}    Error occured while Image compressing.\n
                END
                ###################################### File Uploads ######################################
                # Upload Crimshield document
                Wait Until Element Is Visible    id=authorizationLetterData    5s
                Choose File    id=authorizationLetterData    ${Epass_Path}\\Crimshield.pdf
                Sleep    2s
                # Upload Social Security Card document
                Wait Until Element Is Visible    id=socialSecurityCardData    5s
                Choose File    id=socialSecurityCardData    ${Epass_Path}\\SSN.jpg
                Sleep    2s
                # Upload State ID Front
                Wait Until Element Is Visible    id=stateIssuedIDData    5s
                Choose File    id=stateIssuedIDData    ${Epass_Path}\\DL_front.jpg
                Sleep    2s
                # Upload State ID Back
                Wait Until Element Is Visible    id=stateIssuedIDDataBack    5s
                Choose File    id=stateIssuedIDDataBack    ${Epass_Path}\\DL_back.jpg
                Sleep    2s
                ${message1}    Get Text    stateIssuedIDData
                ${message2}    Get Text    stateIssuedIDDataBack
                ${message3}    Get Text    socialSecurityCardData
                IF    '${message1}' == 'Maximum File size limit is 10 mb' or '${message2}' == 'Maximum File size limit is 10 mb' or '${message3}' == 'Maximum File size limit is 10 mb'   
                    Log To Console    Upload Documents File size limit is 10 mb.
                    Append To File    ${Log}    Upload Documents File size limit is 10 mb.\n
                    ${file_error}    Set Variable    false
                ELSE
                    ${file_error}    Set Variable    True
                END
                IF    ${file_error} == True
                ######################################## Applicant Job Title ########################################
                ${title}    Set Variable    ${Alldatas}[applicant_job_title]
                ${title}    Replace String    ${title}    _    ' '
                ${Cleaned_String1}    Replace String    ${title}    '    ${EMPTY}
                ${job_title}    Convert To Uppercase    ${Cleaned_String1}
                Log To Console    job_title= ${job_title}
                Append To File    ${Log}    job_title= ${job_title}\n
                Wait Until Element Is Visible    //*[@id="clientEmployeePositionId"]    5s
                Select From List By Label    //*[@id="clientEmployeePositionId"]    ${job_title}
                ######################## Company Name #################################
                Wait Until Element Is Visible    //*[@id="billingComments"]
                Input Text    //*[@id="billingComments"]    ${Alldatas}[company_name]
                ############################### MVR Process ################################
                IF    "${Alldatas}[service]" == "driver"
                    Select Checkbox    //*[@id="mvrCheckBox"]
                    Sleep    2s
                    Wait Until Element Is Visible    //*[@id="dlMvr"]    5s
                    Input Text    //*[@id="dlMvr"]    ${Alldatas}[license_number]
                    Sleep    1s
                    ${tech_state1}    Set Variable    ${Alldatas}[license_state]
                    ${tech_state1}    Replace String    ${tech_state1}    _    ' '
                    ${Cleaned_String1}    Replace String    ${tech_state1}    '    ${EMPTY}
                    ${state_name}    Convert To Title Case    ${Cleaned_String1}
                    IF    "${state_name}" == "District Of Columbia"
                        ${state_name}    Replace String    ${tech_state1}    Of    of
                    END
                    IF    "${state_name}" == "federated' 'states' 'of' 'micronesia"
                        ${state_name}    Set Variable    Federated States of Micronesia
                    END
                    IF    "${state_name}" == "Armed Forces Americas Except Canada"
                        ${state_name}    Set Variable    Armed Forces Americas (Except Canada)
                    END
                    IF    "${state_name}" == "Armed Forces International Except Americas"
                        ${state_name}    Set Variable    Armed Forces (International Except Americas)
                    END
                    Log To Console    state_name= ${state_name}
                    Wait Until Element Is Visible    //*[@id="dmvStateCode"]    timeout=10s
                    Select From List By Label    //*[@id="dmvStateCode"]    ${state_name}
                END
                Select Checkbox    //*[@id="signedApplication"]
                Select Checkbox    //*[@id="idMatches"]
                Sleep    2s
                Wait Until Element Is Visible    //*[@id="processApp"]    10s
                Click Element If Visible    //*[@id="processApp"]
                Sleep    10s
                Log To Console    Process Application selected.
                Append To File    ${Log}    Process Application selected.\n
                Execute Sql String
                ...    UPDATE spectrum_onboarding SET dt_status = 'BG_Processed' WHERE SSN = '${Alldatas}[ssn]'
                ########################### Phase2 ############################
                ${error_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    //div[contains(@class, 'uk-alert-danger')]    10s
                Log To Console    ${error_visible}
                Append To File    ${Log}    error_visible=${error_visible} \n
                TRY
                    ${Error_message}    Get Text    //div[contains(@class, 'uk-alert-danger')]//li
                    Log To Console    ${Error_message}
                    Append To File    ${Log}    ${Error_message}.\n
                EXCEPT
                    Log To Console    Unable to capture the error.
                    ${Error_message}    Set Variable
                END
                IF    ${error_visible} == False
                    ${DuplicateSSN}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //*[@id="ssnDuplicateDiv"]/div/div[1]
                    ...    10s
                    IF    ${DuplicateSSN} == True
                        Click Element If Visible    //*[@id="btn-continue"]
                    END
                    ${Phase2_page}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //*[@id="imageUtilFormUpload"]/div[2]/div[1]
                    ...    35s
                    Log To Console    Phase2_page=${Phase2_page}
                    Append To File    ${Log}    Phase2_page=${Phase2_page}.\n
                    IF    ${Phase2_page} == True
                        ${file_falg}    Set Variable    False
                        TRY
                            Wait Until Element Is Visible    //*[@id="imageUtilFormUpload"]/div[2]/div[1]    20s
                            Log To Console    Phase2 page found.
                            Append To File    ${Log}    Phase2 page found.\n
                        EXCEPT
                            Log To Console    2.Error occured while searching for phase2.
                        END
                        ${Phase2_doc}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\Crimshield.pdf
                        IF    ${Phase2_doc} == True
                            Log To Console    Phase2 doc found.
                            Append To File    ${Log}    Phase2 doc uploading.\n
                            Click Element If Visible    //label[@for='myFile']
                            Sleep    2s
                            RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                            Sleep    3s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    1s
                            Select Checkbox    //*[@id="charterUploadConfirm2"]
                            Sleep    1s
                            Click Element If Visible    //*[@id="uploadCharterDocBtn"]
                            Append To File    ${Log}    Phase2 doc uploaded.\n
                        ELSE
                            Append To File    ${Log}    Phase2 doc skiping.\n
                            Wait Until Element Is Visible    //*[@id="charterUploadConfirm2"]    10s
                            Sleep    15s
                            Select Checkbox    //*[@id="charterUploadConfirm2"]
                            Sleep    1s
                            Click Element If Visible    //*[@id="main-content"]/div[1]/div/div[6]/a
                        END
                        Sleep    7s
                        ${Drug_test}    Run Keyword And Return Status
                        ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                        ...    //div[contains(@class, 'uk-title2') and contains(text(), 'Schedule Drug Screening')]
                        ...    30s
                        Click Element If Visible
                        ...    //div[contains(@class, 'uk-title2') and contains(text(), 'Schedule Drug Screening')]
                        Sleep    10s
                        ${error}    Set Variable    False
                        ${file_falg}    Set Variable    True
                        ${data_flag}    Set Variable    True
                        RETURN    ${file_falg}    ${Drug_test}    ${data_flag}    ${error}    ${Error_message}
                    END
                ELSE
                    ${error}    Set Variable    True
                    ${file_falg}    Set Variable    True
                    ${data_flag}    Set Variable    True
                    ${Drug_test}    Set Variable    False
                    Log To Console    BG not able to process due to error message.
                    Append To file    ${Log}    BG not able to process due to error message.\n
                    RETURN    ${file_falg}    ${Drug_test}    ${data_flag}    ${error}    ${Error_message}
                END
                ELSE
                    Log To Console    Document upload failed.
                    ${Error_message}    Set Variable     
                    ${error}    Set Variable    False
                    ${data_flag}    Set Variable    False
                    ${file_falg}    Set Variable    True
                    ${Drug_test}    Set Variable    False
                    RETURN    ${file_falg}    ${Drug_test}    ${data_flag}    ${error}    ${Error_message}
                END
            ELSE
                Log To Console    Unable to enter the details
                Append To file    ${Log}    Unable to enter the details.\n
                ${Error_message}    Set Variable     
                ${error}    Set Variable    False
                ${data_flag}    Set Variable    False
                ${file_falg}    Set Variable    True
                ${Drug_test}    Set Variable    False
                RETURN    ${file_falg}    ${Drug_test}    ${data_flag}    ${error}    ${Error_message}
            END
        ELSE
            ${Phase2_page}    Set Variable    False
        END
        ##########################Employee control center##########################
        IF    ${Phase2_page} == False
            Log To Console    Going to Employee control center
            Append To file    ${Log}    Going to Employee control center.\n
            ${Firstname}    Strip String    ${Alldatas}[tech_first_name]
            ${Lastname}    Strip String    ${Alldatas}[tech_last_name]
            ${first_name}    Convert To Lower Case    ${Firstname}
            ${last_name}    Convert To Lower Case    ${Lastname}
            IF    "${Alldatas}[tech_middle_name]" != " " and "${Alldatas}[tech_middle_name]" != "None" and "${Alldatas}[tech_middle_name]" != ""
                ${Middlename}    Strip String    ${Alldatas}[tech_middle_name]
                ${middle_name}    Convert To Lower Case    ${Middlename}
                ${db_full_name}    Set Variable    ${first_name} ${middle_name} ${last_name}
                Log To Console    db_full_name1=${db_full_name}
            ELSE
                ${db_full_name}    Set Variable    ${first_name} none ${last_name}
                Log To Console    db_full_name2=${db_full_name}
            END
            Click Element If Visible    (//i[@class='uk-icon-users'])[3]
            Wait Until Element Is Visible    //*[@id="fname"]    20s
            FOR    ${index}    IN RANGE    ${MAX_ITERATIONS}
                Input Text When Element Is Visible    //*[@id="fname"]    ${Firstname}
                Input Text When Element Is Visible    //*[@id="lname"]    ${Lastname}
                Select From List By Value     //*[@id="statusOptions"]    1
                Select From List By Value    //*[@id="search-days"]    0
                Sleep    1s
                Click Element If Visible    //*[@id="searchBtn-desktop"]
                Sleep    10s
                Click Element If Visible    //*[@id="searchBtn-desktop"]
                Sleep    3s
                Wait Until Element Is Visible    //div[@class='data-table']    20s
                ${no_records_visible1}=    Run Keyword And Return Status    Element Should Be Visible    //li[contains(text(), 'No records to show.')]    5s
                Append To file    ${Log}    no_records_visible1=${no_records_visible1}.\n
                IF    ${no_records_visible1} == True
                    Click Element If Visible    //*[@id="searchBtn-desktop"]
                    Sleep    4s
                    Wait Until Element Is Visible    //div[@class='data-table']    20s
                    ${no_records_visible2}=    Run Keyword And Return Status    Element Should Be Visible    //li[contains(text(), 'No records to show.')]    5s
                    Append To file    ${Log}    no_records_visible2=${no_records_visible2}.\n
                    Log To Console    no_records_visible2=${no_records_visible2}
                ELSE
                    ${no_records_visible2}    Set Variable    False
                END
                IF    ${no_records_visible2} == False
                    ${li_elements}    Get WebElements    //div[@class='data-table']//li
                    ${row_count}    Get Length    ${li_elements}
                    Log To Console    1.Number of <li> Elements Found: ${row_count}
                    Append To file    ${Log}    1.Number of <li> Elements Found: ${row_count}.\n
                    IF    ${row_count} >= 2
                        Click Element If Visible    //*[@id="searchBtn-desktop"]
                        Sleep    4s
                        Wait Until Element Is Visible    //div[@class='data-table']    20s
                        ${li_elements}    Get WebElements    //div[@class='data-table']//li
                        ${row_count}    Get Length    ${li_elements}
                        Log To Console    2.Number of <li> Elements Found: ${row_count}
                        Append To file    ${Log}    2.Number of <li> Elements Found: ${row_count}.\n
                    END
                    FOR    ${index}    IN RANGE    1    ${row_count + 1}
                        Log To Console    index=${index}
                        TRY
                            Wait Until Element Is Visible    (//div[@class='data-table']//li)[${index}]    3s
                            ${applicant_name}    Get Text
                            ...    (//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span
                            Log To Console    applicant_name=${applicant_name}
                            ${applicant_name}    Strip String    ${applicant_name}
                            ${applicant_name}    Convert To Lower Case    ${applicant_name}
                            Log To Console    ${applicant_name} == ${db_full_name}
                            Append To file    ${Log}    ${applicant_name} == ${db_full_name}.\n
                        EXCEPT
                            Append To file    ${Log}    No records to show.\n
                            Log To Console    No records to show
                            ${applicant_name}    Set Variable    None
                        END
                        IF    '${applicant_name}' == '${db_full_name}'
                            Log To Console    Tech search Found
                            ${Picture}    Get Text    (//div[@class='data-table']//li)[${index}]//td[4]
                            Log To Console    Picture=${Picture}
                            ${Progress}    Get Text    (//div[@class='data-table']//li)[${index}]//td[5]
                            Log To Console    Progress=${Progress}
                            Append To file    ${Log}    Picture=${Picture}.\n
                            Append To file    ${Log}    Progress=${Progress}.\n
                            IF    "${Progress}" == "IN PROGRESS"
                                Click Element If Visible
                                ...    (//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span
                                Wait Until Element Is Visible
                                ...    //li[${index}]//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color']
                                ...    5s
                                ${status}    Get Text
                                ...    //li[${index}]//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color']
                                Log To Console    status= ${status}
                                IF    "${status}" == "INACTIVE"
                                    ${Tech_flag}    Set Variable    True
                                    ${Not_certified}    Get Text
                                    ...    //li[${index}]//i[contains(@class, 'uk-icon-certificate') and contains(@class, 'uk-icon-small') and contains(@class, 'icon-gold')]/span[contains(@class, 'uk-content-label-18-danger-color')]
                                    IF    "${Not_certified}" == "Not Currently Certified - PENDING"
                                        ${non_certified}    Set Variable    True
                                        Log To Console    non_certified= ${non_certified}
                                        TRY
                                            ${row_num}    Set Variable    ${index}
                                            Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                            ${front_state_id_download}    Run Keyword And Return Status
                                            ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                            ...    (//a[contains(text(), 'Upload Front of State Issued Id')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                            ...    10s
                                            Log To Console    front_state_id_download=${front_state_id_download}
                                            IF    ${front_state_id_download} == False
                                                ${front_state_id_found}    Run Keyword And Return Status
                                                ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                ...    (//a[contains(text(), 'Upload Front of State Issued Id')])[${index}]
                                                Log To Console    Front State Issued ID Found: ${front_state_id_found}
                                                IF    ${front_state_id_found} == True
                                                    Click Element When Visible
                                                    ...    (//a[contains(text(), 'Upload Front of State Issued Id')])[${index}]
                                                    ${Upload_box1}    Run Keyword And Return Status
                                                    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                    ...    //div[text()='UPLOAD FRONT OF STATE ISSUE ID']
                                                    ...    5s
                                                    IF    ${Upload_box1} == True
                                                        Wait Until Element Is Visible    id=upload-image-iframe    30s
                                                        Select Frame    id=upload-image-iframe
                                                        TRY
                                                            Wait Until Element Is Visible
                                                            ...    //*[@id="upload-siid-btn"]
                                                            ...    10s
                                                            Click Element If Visible    //*[@id="upload-siid-btn"]
                                                        EXCEPT
                                                            Log To Console    File button not found
                                                        END
                                                        Wait Until Element Is Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        Sleep    2s
                                                        RPA.Desktop.Type Text    ${Epass_Path}\\DL_front.jpg
                                                        Sleep    1s
                                                        RPA.Desktop.Press Keys    Enter
                                                        Sleep    1s
                                                        Wait Until Element Is Visible
                                                        ...    //*[@id="upload-image-btn"]
                                                        ...    10s
                                                        Click Element If Visible    //*[@id="upload-image-btn"]
                                                        Sleep    3s
                                                        Unselect Frame
                                                        Wait Until Element Is Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        Log To Console    Upload_box1 front closed
                                                        Sleep    3s
                                                        Execute JavaScript    document.querySelector("#searchBtn-desktop").click();
                                                        Sleep    4s
                                                        Click Element If Visible
                                                        ...    (//div[@class='data-table']//li)[${row_num}]//td[contains(@class, 'dashtb-td')]/span
                                                        Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                                        ${front_state_id_file}    Run Keyword And Return Status
                                                        ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                        ...    (//a[contains(text(), 'Upload Front of State Issued Id')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                                        ...    10s
                                                        Log To Console    front_state_id_file=${front_state_id_file}
                                                        Append To file    ${Log}    DL back Download Link Found: ${front_state_id_file}.\n
                                                    END
                                                ELSE
                                                    Log To Console    Upload_box for DL front not found
                                                    Append To file    ${Log}    Upload_box for DL front not found.\n
                                                END
                                            ELSE
                                                ${front_state_id_file}    Set Variable    True
                                                Log To Console    Already Front side State ID uploaded
                                                Append To file    ${Log}    Already Front side State ID uploaded.\n
                                            END
                                            Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                            ${back_state_id_download}    Run Keyword And Return Status
                                            ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                            ...    (//a[contains(text(), 'Upload Back of State Issued Id')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                            ...    10s
                                            Log To Console    back_state_id_download=${back_state_id_download}
                                            IF    ${back_state_id_download} == False
                                                ${back_state_id_found}    Run Keyword And Return Status
                                                ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                ...    (//a[contains(text(), 'Upload Back of State Issued Id')])[${index}]
                                                Log To Console    back State Issued ID Found: ${back_state_id_found}
                                                IF    ${back_state_id_found} == True
                                                    Click Element When Visible
                                                    ...    (//a[contains(text(), 'Upload Back of State Issued Id')])[${index}]
                                                    ${Upload_box11}    Run Keyword And Return Status
                                                    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                    ...    //div[text()='UPLOAD BACK OF STATE ISSUE ID']
                                                    ...    10s
                                                    IF    ${Upload_box11} == True
                                                        Wait Until Element Is Visible    id=upload-image-iframe    30s
                                                        Select Frame    id=upload-image-iframe
                                                        TRY
                                                            Wait Until Element Is Visible
                                                            ...    //*[@id="upload-siid-btn"]
                                                            ...    10s
                                                            Click Element If Visible    //*[@id="upload-siid-btn"]
                                                        EXCEPT
                                                            Log To Console    File button not found
                                                        END
                                                        Wait Until Element Is Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        Sleep    2s
                                                        RPA.Desktop.Type Text    ${Epass_Path}\\DL_back.jpg
                                                        Sleep    1s
                                                        RPA.Desktop.Press Keys    Enter
                                                        Sleep    1s
                                                        Wait Until Element Is Visible
                                                        ...    //*[@id="upload-image-btn"]
                                                        ...    10s
                                                        Click Element If Visible    //*[@id="upload-image-btn"]
                                                        Sleep    3s
                                                        Unselect Frame
                                                        Wait Until Element Is Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        Log To Console    Upload_box1 back closed
                                                        Sleep    3s
                                                        Execute JavaScript    document.querySelector("#searchBtn-desktop").click();
                                                        Sleep    4s
                                                        Click Element If Visible
                                                        ...    (//div[@class='data-table']//li)[${row_num}]//td[contains(@class, 'dashtb-td')]/span
                                                        Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                                        ${back_state_id_file}    Run Keyword And Return Status
                                                        ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                        ...    (//a[contains(text(), 'Upload Back of State Issued Id')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                                        ...    10s
                                                        Log To Console    back_state_id_file=${back_state_id_file}
                                                        Append To file    ${Log}    DL back Download Link Found: ${back_state_id_file}.\n
                                                    END
                                                ELSE
                                                    Log To Console    Upload_box for DL back not found
                                                    Append To file    ${Log}    Upload_box for DL back not found.\n
                                                END
                                            ELSE
                                                ${back_state_id_file}    Set Variable    True
                                                Log To Console    Already Back side State ID uploaded
                                                Append To file    ${Log}    Already Back side State ID uploaded.\n
                                            END
                                            Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                            ${ssn_found}    Run Keyword And Return Status
                                            ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                            ...    (//a[contains(text(), 'Upload SSN')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                            Log To Console    SSN Found: ${ssn_found}
                                            IF    ${ssn_found} == False
                                                ${ssn_id_found}    Run Keyword And Return Status
                                                ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                ...    (//a[contains(text(), 'Upload SSN')])[${index}]
                                                Log To Console    State Issued ID Found: ${ssn_id_found}
                                                IF    ${ssn_id_found} == True
                                                    Click Element When Visible
                                                    ...    (//a[contains(text(), 'Upload SSN')])[${index}]
                                                    ${Upload_box2}    Run Keyword And Return Status
                                                    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                    ...    //div[text()='Applicant SSN Upload']
                                                    ...    10s
                                                    IF    ${Upload_box2} == True
                                                        Wait Until Element Is Visible    id=upload-image-iframe    30s
                                                        Select Frame    id=upload-image-iframe
                                                        TRY
                                                            Wait Until Element Is Visible
                                                            ...    //*[@id="upload-ssc-btn"]
                                                            ...    10s
                                                            Click Element If Visible    //*[@id="upload-ssc-btn"]
                                                        EXCEPT
                                                            Log To Console    File button not found
                                                        END
                                                        Wait Until Element Is Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        Sleep    2s
                                                        RPA.Desktop.Type Text    ${Epass_Path}\\SSN.jpg
                                                        Sleep    1s
                                                        RPA.Desktop.Press Keys    Enter
                                                        Sleep    1s
                                                        Wait Until Element Is Visible
                                                        ...    //*[@id="upload-image-btn"]
                                                        ...    10s
                                                        Click Element If Visible    //*[@id="upload-image-btn"]
                                                        Sleep    3s
                                                        Unselect Frame
                                                        Wait Until Element Is Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        Log To Console    Upload_box2 closed
                                                        Sleep    3s
                                                        Execute JavaScript    document.querySelector("#searchBtn-desktop").click();
                                                        Sleep    4s
                                                        Click Element If Visible
                                                        ...    (//div[@class='data-table']//li)[${row_num}]//td[contains(@class, 'dashtb-td')]/span
                                                        Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                                        ${ssn_file}    Run Keyword And Return Status
                                                        ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                        ...    (//a[contains(text(), 'Upload SSN')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                                        ...    10s
                                                        Log To Console    SSN Download Link Found: ${ssn_file}
                                                        Append To file    ${Log}    SSN Download Link Found: ${ssn_file}.\n
                                                    END
                                                ELSE
                                                    Log To Console    Upload_box for SSN not found
                                                    Append To file    ${Log}    Upload_box for SSN not found.\n
                                                END
                                            ELSE
                                                ${ssn_file}    Set Variable    True
                                                Log To Console    Already SSN uploaded
                                                Append To file    ${Log}    Already SSN uploaded.\n
                                            END
                                            Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                            ${Crimshield}    Run Keyword And Return Status
                                            ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                            ...    (//a[contains(text(), 'Upload Authorization')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                            Log To Console    Authorization Download Link Found: ${Crimshield}
                                            IF    ${Crimshield} == False
                                                ${Crim_found}    Run Keyword And Return Status
                                                ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                ...    (//a[contains(text(), 'Upload Authorization')])[${index}]
                                                Log To Console    Authorization Found: ${Crim_found}
                                                IF    ${Crim_found} == True
                                                    Click Element When Visible
                                                    ...    (//a[contains(text(), 'Upload Authorization')])[${index}]
                                                    ${Upload_box3}    Run Keyword And Return Status
                                                    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                    ...    //div[text()='Background Check Authorization Upload']
                                                    ...    10s
                                                    IF    ${Upload_box3} == True
                                                        Wait Until Element Is Visible    id=upload-image-iframe    30s
                                                        Select Frame    id=upload-image-iframe
                                                        TRY
                                                            Wait Until Element Is Visible
                                                            ...    //*[@id="upload-non-driver-btn"]
                                                            ...    10s
                                                            Click Element If Visible
                                                            ...    //*[@id="upload-non-driver-btn"]
                                                        EXCEPT
                                                            Log To Console    File button not found
                                                        END
                                                        Wait Until Element Is Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    //span[@class="focus-jfilestyle"]/label[@for="myFile1"]
                                                        Sleep    2s
                                                        RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                                                        Sleep    1s
                                                        RPA.Desktop.Press Keys    Enter
                                                        Sleep    1s
                                                        Wait Until Element Is Visible
                                                        ...    //*[@id="upload-image-btn"]
                                                        ...    10s
                                                        Click Element If Visible    //*[@id="upload-image-btn"]
                                                        Sleep    3s
                                                        Unselect Frame
                                                        Wait Until Element Is Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        ...    10s
                                                        Click Element If Visible
                                                        ...    (//a[contains(@class, 'uk-modal-close') and contains(@class, 'uk-close')])[${index}]
                                                        Log To Console    Upload_box3 closed
                                                        Sleep    3s
                                                        Execute JavaScript    document.querySelector("#searchBtn-desktop").click();
                                                        Sleep    4s
                                                        Click Element If Visible
                                                        ...    (//div[@class='data-table']//li)[${row_num}]//td[contains(@class, 'dashtb-td')]/span
                                                        Wait Until Element Is Visible    //div[starts-with(@id, 'applicant') and contains(@class, 'accordion-content')]    10s
                                                        ${Crim_file}    Run Keyword And Return Status
                                                        ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                                                        ...    (//a[contains(text(), 'Upload Authorization')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                                        Log To Console
                                                        ...    Authorization Download Link Found: ${Crim_file}
                                                        Append To file    ${Log}    Authorization Download Link Found: ${Crim_file}.\n
                                                    END
                                                ELSE
                                                    Log To Console    Upload_box3 for Crimshield not found
                                                    Append To file    ${Log}    Upload_box3 for Crimshield not found.\n
                                                END
                                            ELSE
                                                ${Crim_file}    Set Variable    True
                                                Log To Console    Already Crimshield uploaded
                                                Append To file    ${Log}    Already Crimshield uploaded.\n
                                            END
                                            IF    ${front_state_id_file} == True and ${back_state_id_file} == True and ${ssn_file} == True and ${Crim_file} == True
                                                ${file_falg}    Set Variable    True
                                            ELSE
                                                ${file_falg}    Set Variable    False
                                            END
                                        EXCEPT
                                            ${file_falg}    Set Variable    False
                                        END
                                    ELSE
                                        Append To file    ${Log}    Tech found but creteria not match.\n
                                        Log To Console    Tech found but creteria not match.
                                        Click Element If Visible
                                        ...    (//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span
                                    END
                                ELSE
                                    Append To file    ${Log}    Tech not Inactive, moving to next tech.\n
                                    Log To Console    Tech not Inactive, moving to next tech.
                                    Click Element If Visible
                                    ...    (//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span
                                END
                            ELSE
                                Append To file    ${Log}    Tech has no current record.\n
                                Log To Console    Tech has no current record.
                            END
                        ELSE
                            Append To file    ${Log}    Tech not found in Employee control center.\n
                            Log To Console    Tech not found in Employee control center.
                        END
                    END
                    IF    ${front_state_id_file} == True and ${back_state_id_file} == True and ${ssn_file} == True and ${Crim_file} == True
                        ${file_falg}    Set Variable    True
                        BREAK
                    ELSE
                        ${file_falg}    Set Variable    False
                    END
                ELSE
                    Append To file    ${Log}    No record found in Employee control center.\n
                    Log To Console    No record found in Employee control center.
                    ${file_falg}    Set Variable    True
                    ${data_flag}    Set Variable    True
                    ${Error_message}    Set Variable
                    ${Drug_test}    Set Variable    False         
                    ${error}    Set Variable    False
                    RETURN    ${file_falg}    ${Drug_test}    ${data_flag}    ${error}    ${Error_message}
                END
            END
            ${data_flag}    Set Variable    True
            ${Error_message}    Set Variable     
            ${error}    Set Variable    False
            Log To Console    file_falg=${file_falg}
            Log To Console    data_flag=${data_flag}
            ${Drug_test}    Run Keyword And Return Status
            ...    RPA.Browser.Selenium.Wait Until Element Is Visible
            ...    //div[@class='pad-left-110']//a[contains(text(),'DRUG Screen Applicant')]
            ...    30s
            Log To Console    Drug_test=${Drug_test}
            Click Element When Visible
            ...    //div[@class='pad-left-110']//a[contains(text(),'DRUG Screen Applicant')]
            Sleep    10s
            RETURN    ${file_falg}    ${Drug_test}    ${data_flag}    ${error}    ${Error_message}
        END
    END
