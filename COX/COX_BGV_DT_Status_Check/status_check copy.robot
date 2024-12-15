*** Settings ***
Library     RPA.Browser.Selenium
Library     String
Library     Sendmail.py
Library     Collections
Library     RPA.Desktop
Library     RPA.PDF
Library     OperatingSystem
Library     pdfdownload.py
Library     PDFExtract.py
Library     DateTime
Resource    FuseUpdate.robot
Library     DateKeywords.py
Library    RPA.Windows


*** Variables ***
${Fullname}             ${EMPTY}
${First}                ${EMPTY}
${Last}                 ${EMPTY}
${AllFullname}          ${EMPTY}
${doc}                  ${EMPTY}
${CC}                   ${EMPTY}
${TechStatus}           ${EMPTY}
${Infomart_Login}       ${EMPTY}
${Infomart_Home}        ${EMPTY}
${Fuse_update_flag}     ${EMPTY}
${MAX_RETRIES}          12


*** Keywords ***
 Status_Check
    [Arguments]    ${Alldatas}    ${credentials}    ${Epass_name}    ${Epass_Path}    ${DTLog}
    Append To File
    ...    ${DTLog}
    ...    ............................................Technician=${Alldatas}[first_name]_${Alldatas}[last_name]............................................\n
    Log To Console
    ...    *********************************${Alldatas}[first_name]_${Alldatas}[last_name]*********************************
    ${handles}=    Get Window Titles
    Switch window    ${handles}[0]
    Sleep    2s
    ${Infomart_Login}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="request-list-wrapper"]/div[1]/div/div[2]/div[3]/div/div/div[2]/div
    ...    5s
    IF    $Infomart_Login == False
        ${Infomart_Home}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //input[@name='search']
        ...    5s
    END
    FOR    ${index}    IN RANGE    ${MAX_RETRIES}
            ${site}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //*[@id="main-message"]/h1/span
            IF    ${site} == True
                Execute JavaScript    window.location.reload(true);
                # RPA.Browser.Selenium.Press Keys    Ctrl+Shift+R
                Log To Console    This site can't open is Appear (Attempt ${index + 1})
                Append To File    ${DTLog}    This site can't open is Appear (Attempt ${index + 1}).\n
                
            ELSE
                Log To Console    Page loaded successfully on attempt ${index + 1}
                Append To File    ${DTLog}    Page loaded successfully on attempt ${index + 1}.\n
                BREAK
            END
    END
    IF    $Infomart_Login == True or $Infomart_Home == True
        ${attempt}=    Set Variable    0
        IF    $Infomart_Home == True
            # Click Element When Visible    //*[@id="request-search-clear"]
            RPA.Browser.Selenium.Execute JavaScript    document.querySelectorAll('#request-search-clear')[0].value = '';
            Sleep    2s
        END
        
        ${Firstname}=    Strip String    ${Alldatas}[first_name]
        ${Lastname}=    Strip String    ${Alldatas}[last_name]
        ${first_name}=    Convert To Lower Case    ${Firstname}
        ${last_name}=    Convert To Lower Case    ${Lastname}
        ${db_full_name}=    Set Variable    ${first_name}_${last_name}
        

        ${FORMATTED_NAME}=    Set Variable    ${last_name}, ${first_name}
        IF    $Infomart_Login == True
            ${element}=    Get WebElement    xpath=(//a[text()='Home'])[1]
            ${href}=    Call Method    ${element}    get_attribute    href
            Go To    url=${href}
        END
        Wait Until Element Is Visible    //h3[text()='All Requests']    5s
        Click Element    //input[@name='search']
        Sleep    2s
        Scroll Element Into View    //tr[td[contains(text(), '')]]
        Input Text    //input[@name='search']    ${FORMATTED_NAME}
        Log To Console    Tech_Name=${FORMATTED_NAME}
        Sleep    1s
        TRY
            Scroll Element Into View    //i[@class='fas fa-search']
            Click Element    //i[@class='fas fa-search']
        EXCEPT    
            Execute Javascript    document.querySelector('i.fas.fa-search').click()
        END
        Sleep    1s
        FOR    ${index}    IN RANGE    ${MAX_RETRIES}
            ${site}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //*[@id="main-message"]/h1/span
            IF    ${site} == True
                Execute JavaScript    window.location.reload(true);
                # RPA.Browser.Selenium.Press Keys    Ctrl+Shift+R
                Log To Console    This site can't open is Appear (Attempt ${index + 1})
                Append To File    ${DTLog}    This site can't open is Appear (Attempt ${index + 1}).\n
                
            ELSE
                Log To Console    Page loaded successfully on attempt ${index + 1}
                Append To File    ${DTLog}    Page loaded successfully on attempt ${index + 1}.\n
                BREAK
            END
        END
        Scroll Element Into View    //tr[td[contains(text(), '')]]
        ${status_name}=
        ...    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //tr[td[contains(text(), '')]]    10s
        IF    ${status_name} == True
            ${TechStatus}=    RPA.Browser.Selenium.Get Text    //table[@class="table table-hover"]/tbody/tr/td[7]
            Append To file    ${DTLog}    TechStatus=${TechStatus}.\n
            Log To Console    Tech_status=${TechStatus}

            IF    "${TechStatus}" == "Complete"
                Wait Until Element Is Visible    //button[text()='View Profile']
                Click Button    //button[text()='View Profile']
                Sleep    2s
                ${handles}=    Get Window Handles
                Switch window    ${handles}[2]
                Sleep    2s
                RPA.Desktop.Press Keys    CTRL    s
                Sleep    2s
                RPA.Desktop.Type Text    ${Epass_name}
                Sleep    1s
                RPA.Desktop.Press Keys    Enter
                Sleep    1s
                TRY
                    RPA.Desktop.Press Keys    Tab
                    Sleep    1s
                    RPA.Desktop.Press Keys    Enter
                    Sleep    2s
                EXCEPT
                    Log To Console    File not downloaded
                END
                TRY
                    ${File_exist}=    Run Keyword And Return Status    File Should Exist    ${Epass_name}
                    IF    ${File_exist} != True
                        ${handles}=    Get Window Handles
                        Switch window    ${handles}[2]
                        Sleep    2s
                        Execute JavaScript    window.focus()
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    2s
                        RPA.Desktop.Type Text    ${Epass_name}
                        Sleep    3s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    2s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    File not downloaded
                            Append To File    ${DTLog}    File not downloaded.\n
                        END
                    ELSE
                        Append To File    ${DTLog}    Epassport Downloaded.\n
                        Log To Console    Epassport Downloaded.
                    END
                EXCEPT
                    Append To File    ${DTLog}    Epassport ReDownload failed.\n
                    Log To Console    Epassport ReDownload failed.
                END
                ${handles}=    Get Window Handles
                Switch window    ${handles}[2]
                Execute JavaScript    window.focus()
                Execute JavaScript    window.close()
                TRY
                    ${handles}=    Get Window Handles
                    Switch window    ${handles}[2]
                    Execute JavaScript    window.focus()
                    Execute JavaScript    window.close()
                EXCEPT
                    Log To Console    Pdf page Already Closed
                    Append To File    ${DTLog}    pdf page Already Closed\n
                END

                Log To Console    pdf Window closed
                Append To file    ${DTLog}    pdf Window closed.\n
                ${status_Pdf}=    Run Keyword And Return Status    File Should Exist    ${Epass_name}
                Log To Console    pdf=${status_Pdf}
                Append To file    ${DTLog}    pdf=${status_Pdf}\n
                IF    ${status_Pdf} == True
                    ${input_pdf_path}=    Set Variable    ${Epass_name}
                    ${output_pdf_path}=    Set Variable    ${Epass_Path}\\${db_full_name}_ProfileStatus.pdf
                    split_pdf    ${input_pdf_path}    ${output_pdf_path}
                    Log To Console    ProfileStatus pdf successfully created.
                    Append To file    ${DTLog}    ProfileStatus pdf successfully created.\n
                    ${ProfileStatus}=    Run Keyword And Return Status
                    ...    File Should Exist
                    ...    ${output_pdf_path}
                    Log To Console    ProfileStatus=${ProfileStatus}
                    Append To file    ${DTLog}    ProfileStatus=${ProfileStatus}\n
                    IF    ${ProfileStatus} == True
                        Log To Console    pdf_extracted
                        Append To file    ${DTLog}    pdf_extracted.\n
                        ${grade_level}    ${date}=    pdf_extract    ${output_pdf_path}
                        Log To Console    grade_level=${grade_level}
                        Log To Console    date=${date}
                        Append To file    ${DTLog}    grade_level=LEVEL-${grade_level}.\n
                        Append To file    ${DTLog}    Order_date=${date}.\n
                        IF    "${grade_level}" != "" or "${grade_level}" != "None"
                            ${Recepients}=    set variable    ${credentials}[cox_team]
                            ${CC}=    set variable    ${credentials}[Recipient]
                            ${Attachment}=    Set Variable    ${input_pdf_path}
                            Log To Console    Attachment=${Attachment}
                            IF    "${Alldatas}[tax_term]" == "1099"
                                ${Subject}=    Set Variable
                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                            ELSE
                                ${Subject}=    Set Variable
                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                            END
                            ${Body}    Set Variable
                            ...    Profile Status Process is completed for "${Alldatas}[first_name] ${Alldatas}[last_name]".\nGrade: LEVEL-${grade_level}
                            ${Mailsent}=    Run Keyword And Return Status
                            ...    Sendmail
                            ...    ${Recepients}
                            ...    ${CC}
                            ...    ${Subject}
                            ...    ${Body}
                            ...    ${Attachment}
                            IF    ${Mailsent} == True
                                Append To File    ${DTLog}    Mail sent for Profile status completed.\n
                                Log To Console    Mail sent for Profile status completed
                                Execute Sql String
                                ...    UPDATE cox_onboarding SET status_completed_mail_sent = 'Mail Sent' WHERE SSN = '${Alldatas}[ssn]'
                                Execute Sql String
                                ...    UPDATE cox_onboarding SET status = 'LEVEL-${grade_level}' WHERE SSN = '${Alldatas}[ssn]'
                                # Execute Sql String
                                # ...    UPDATE cox_onboarding SET bgv_completed_date = '${date}' WHERE SSN = '${Alldatas}[ssn]'
                            ELSE
                                Append To File    ${DTLog}    Mail not sent for Profile status completed.\n
                                Log To Console    Mail not sent for Profile status completed
                            END
                            IF    "${Alldatas}[process]" == "pre_employment"
                                IF    "${grade_level}" == "1"
                                    ${Fuse_update_flag}=    Set Variable    True
                                ELSE
                                    ${Fuse_update_flag}=    Set Variable    False
                                END
                            ELSE
                                ${Fuse_update_flag}=    Set Variable    False
                            END
                            Append To File    ${DTLog}    Fuse_update_flag=${Fuse_update_flag}.\n
                            Log To Console    Fuse_update_flag=${Fuse_update_flag}
                        ELSE
                            ${Recepients}=    set variable    ${credentials}[Recipient]
                            ${CC}=    set variable
                            ${Body}=    Set Variable
                            ...    Error occured while extracting the PDF for the tech "${Alldatas}[first_name] ${Alldatas}[last_name]". Kindly check.
                            ${Body2}=    Set variable
                            ${Attachment}=    Set Variable    ${output_pdf_path}
                            IF    "${Alldatas}[tax_term]" == "1099"
                                ${Subject}=    Set Variable
                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                            ELSE
                                ${Subject}=    Set Variable
                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                            END
                            ${Mailsent}=    Run Keyword And Return Status
                            ...    Sendmail
                            ...    ${Recepients}
                            ...    ${CC}
                            ...    ${Subject}
                            ...    ${Body}
                            ...    ${Attachment}
                            IF    ${Mailsent} == True
                                Append To File    ${DTLog}    Mail sent for Error occured while extracting the PDF.\n
                                Log To Console    Mail sent for Error occured while extracting the PDF
                            ELSE
                                Append To File
                                ...    ${DTLog}
                                ...    Mail not sent for Error occured while extracting the PDF.\n
                                Log To Console    Mail not sent for Error occured while extracting the PDF
                            END
                        END
                    ELSE
                        Log To Console    Unable to split the Profile PDF result page.
                        Append To file    ${DTLog}    Unable to split the Profile PDF result page.\n
                        ${Recepients}=    set variable    ${credentials}[Recipient]
                        ${CC}=    set variable
                        ${Body}=    Set Variable
                        ...    Error occured while spliting the Profile PDF result page for the tech "${Alldatas}[first_name] ${Alldatas}[last_name]". Kindly check.
                        ${Body2}=    Set variable
                        ${Attachment}=    Set Variable    ${output_pdf_path}
                        IF    "${Alldatas}[tax_term]" == "1099"
                            ${Subject}=    Set Variable
                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                        ELSE
                            ${Subject}=    Set Variable
                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                        END
                        ${Mailsent}=    Run Keyword And Return Status
                        ...    Sendmail
                        ...    ${Recepients}
                        ...    ${CC}
                        ...    ${Subject}
                        ...    ${Body}
                        ...    ${Attachment}
                        IF    ${Mailsent} == True
                            Append To File    ${DTLog}    Mail sent for Unable to split the Profile PDF result page.\n
                            Log To Console    Mail sent for Unable to split the Profile PDF result page.
                        ELSE
                            Append To File
                            ...    ${DTLog}
                            ...    Mail not sent for Unable to split the Profile PDF result page.\n
                            Log To Console    Mail not sent for Unable to split the Profile PDF result page.
                        END
                    END
                ELSE
                    Log To Console    Status pdf doesn't exist
                    Append To file    ${DTLog}    Status pdf doesn't exist.\n
                    ${Recepients}=    set variable    ${credentials}[Recipient]
                    ${CC}=    set variable
                    ${Attachment}=    Set Variable    ${Epass_name}
                    IF    "${Alldatas}[tax_term]" == "1099"
                        ${Subject}=    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                    ELSE
                        ${Subject}=    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                    END
                    ${Body1}=    Set Variable
                    ${Body}=    Set Variable
                    ...    The Infomart Status pdf doesn't exist for "${Alldatas}[first_name] ${Alldatas}[last_name]". Kindly check.
                    ${Body2}=    Set Variable
                    ${Mailsent}=    Run Keyword And Return Status
                    ...    Sendmail
                    ...    ${Recepients}
                    ...    ${CC}
                    ...    ${Subject}
                    ...    ${Body}
                    ...    ${Attachment}
                    IF    ${Mailsent} == True
                        Append To File    ${DTLog}    Mail sent for Status pdf doesn't exist.\n
                        Log To Console    Mail sent for Status pdf doesn't exist
                    ELSE
                        Append To File    ${DTLog}    Mail not sent for Status pdf doesn't exist.\n
                        Log To Console    Mail not sent for Status pdf doesn't exist
                    END
                END
            ELSE
                ${output_pdf_path}=    Set Variable
                ${date}=    Set Variable
                Log To Console    Tech_status=${TechStatus}
                IF    "${TechStatus}" == "" or "${TechStatus}" == "None"
                    IF    "${Alldatas}[status_completed_mail_sent]" != "Remainder_Sent"
                        ${order_date}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@class="table table-hover"]/tbody/tr/td[4]
                        ${created_date}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@class="table table-hover"]/tbody/tr/td[3]
                        Log To Console    created_date=${created_date}
                        ${order_number}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@class="table table-hover"]/tbody/tr/td[5]
                        Log To Console    order_date = ${order_date}
                        Append To file    ${DTLog}    order_date = ${order_date}.\n
                        ${current_date}=    Get Time    result_format=%m/%d/%Y
                        Log To Console    Current Date = ${current_date}
                        Append To file    ${DTLog}    Current Date: ${current_date}.\n
                        ${yesterday}=    Subtract Time From Date    ${current_date}    1 day    result_format=%m/%d/%Y
                        IF    "${created_date}" == "${yesterday}"
                            ${yesterday_date}=    Set Variable    True
                            Append To file    ${DTLog}    created date & yesterday date is match\n
                        ELSE
                            ${yesterday_date}=    Set Variable    False
                            Append To file    ${DTLog}    created date & yesterday date is not match\n
                        END
                        IF    "${yesterday_date}" != True 
                            IF    "${order_date}" == "${current_date}"
                                Log To Console    Order date and current_date is match
                                Append To File    ${DTLog}    Order date and current_date is match.\n
                                ${Body}=    Set Variable
                                ...    Please be reminded that tech "${Alldatas}[first_name] ${Alldatas}[last_name]" has an order number is  (${order_number}) and order date is (${order_date}), but their profile status is Pending.
                                ${Attachment}=    Set Variable    ${doc}
                                ${Recepients}=    set variable    ${credentials}[cox_team]
                                ${CC}=    set variable    ${credentials}[Recipient]
                                IF    "${Alldatas}[tax_term]" == "1099"
                                    ${Subject}=    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                ELSE
                                    ${Subject}=    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                END
                                ${Mailsent}=    Run Keyword And Return Status
                                ...    Sendmail
                                ...    ${Recepients}
                                ...    ${CC}
                                ...    ${Subject}
                                ...    ${Body}
                                ...    ${Attachment}
                                IF    ${Mailsent} == True
                                    Append To File    ${DTLog}    Mail sent for Remainder.\n
                                    Log To Console    Mail sent for Remainder.
                                    Execute Sql String
                                    ...    UPDATE cox_onboarding SET status_completed_mail_sent = 'Remainder_Sent' WHERE SSN = '${Alldatas}[ssn]'
                                ELSE
                                    Append To File    ${DTLog}    Mail not sent for Remainder.\n
                                    Log To Console    Mail not sent for Remainder.
                                END
                            ELSE
                                Log To Console    Order date and current_date is not match
                                Append To File    ${DTLog}    Order date and current_date is not match.\n
                            END
                        ELSE
                            Log To Console    created_date and yesterday date  is match
                            Append To File    ${DTLog}    created_date and yesterday date is match
                        END
                    END
                ELSE
                    Log To Console    TechStatus=${TechStatus}
                    Append To File    ${DTLog}    TechStatus=${TechStatus}
                END
                # ${Alldatas}[fuse_status_check]=    Get Fuse Status Check
                ${Today_date}=    Get Time
                IF    "${Alldatas}[fuse_status_check]" != "" and "${Alldatas}[fuse_status_check]" != "None"
                    ${TARGET_DATE}=    Set Variable    ${Alldatas}[fuse_status_check]
                    ${Today_date}=    Set Variable    ${Today_date}
                    ${Target_date}=    Add Time To Date    ${TARGET_DATE}    3 days
                    ${Target_date}=    Set Variable    ${Target_date}[:10]
                    Log To Console    Target_date=${Target_date}
                    ${Today_date}=    Set Variable    ${Today_date}[:10]
                    Log To Console    Today_date=${Today_date}
                    IF    "${Target_date}" == "${Today_date}"
                        ${Fuse_update_flag}=    Set Variable    True
                    ELSE
                        ${Fuse_update_flag}=    Set Variable    False
                    END
                ELSE
                    ${Fuse_update_flag}=    Set Variable    True
                END
            END
            IF    "${Alldatas}[process]" == "pre_employment"
                IF    ${Fuse_update_flag} == True
                    Log To Console    Fuse update Initiation.
                    Append To File    ${DTLog}    Fuse update Initiation.\n
                    Fuse_Updates
                    ...    ${Alldatas}
                    ...    ${credentials}
                    ...    ${output_pdf_path}
                    ...    ${DTLog}
                    ...    ${TechStatus}
                    ...    ${date}
                END
            END
        ELSE
            Log To Console    Tech result not found
            Append To file    ${DTLog}    Tech result not found.\n
        END
    ELSE
        Log To Console    Infomart Page not found
        Append To file    ${DTLog}    Infomart Page not found.\n
    END
