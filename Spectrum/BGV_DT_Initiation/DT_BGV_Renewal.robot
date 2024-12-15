*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     String
Library     Collections
Library     OperatingSystem
Library     RPA.Desktop
Library     DatabaseLibrary
Library     DateTime
Library     Sendmail.py
Library    Movefiles.py
Resource    DT_Initiation.robot
Resource    DT&BGVFuseupdate.robot
Resource    BGV_Initiation.robot


*** Variables ***
${doc}                  ${EMPTY}
${Body1}                ${EMPTY}
${Body2}                ${EMPTY}
${CC}                   ${EMPTY}
${MAX_ITERATIONS}       3
${OUTPUT_PDF_PATH}      ${EMPTY}
${db_full_name1}
${SOURCE_FOLDER}    C:\\Users\\Administrator\\Downloads


*** Keywords ***
BGV_DT_Renewal
    [Arguments]    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Epass_name}    ${Log}

    ${CrimShield_login}    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //*[@id="main-content"]/div[1]/div[2]/div[4]/div
    ...    20s
    IF    "${CrimShield_login}" == "True"
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
            ${db_full_name}    Set Variable    ${first_name} ${last_name}
            ${db_full_name1}    Set Variable    ${first_name} none ${last_name}
            Log To Console    db_full_name2=${db_full_name}
            Log To Console    db_full_name2=${db_full_name1}
        END
        Click Element If Visible    (//i[@class='uk-icon-users'])[3]
        Wait Until Element Is Visible    //*[@id="fname"]    20s
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
        ${li_elements}    Get WebElements    //div[@class='data-table']//li
        ${row_count}    Get Length    ${li_elements}
        Log To Console    Number of <li> Elements Found: ${row_count}
        IF    ${row_count} >= 3
            Click Element If Visible    //*[@id="searchBtn-desktop"]
            Sleep    3s
            Wait Until Element Is Visible    //div[@class='data-table']    20s
            ${li_elements}    Get WebElements    //div[@class='data-table']//li
            Log To Console    li_elements=${li_elements}
            ${row_count}    Get Length    ${li_elements}
            Log To Console    Number of <li> Elements Found: ${row_count}
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
                Log To Console    ${applicant_name} == ${db_full_name1}
            EXCEPT
                Log To Console    No records to show
                ${applicant_name}    Set Variable    None
            END
            IF    '${applicant_name}' == '${db_full_name}' or '${applicant_name}' == '${db_full_name1}'
                Log To Console    Tech search Found
                ${eta}    Get Text    (//div[@class='data-table']//li)[${index}]//td[6]
                Log To Console    ETA=${eta}
                IF    "${eta}" == "COMPLETE"
                    Click Element If Visible    (//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span
                    Wait Until Element Is Visible
                    ...    (//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color'])[${index}]
                    ...    5s
                    ${status}    Get Text
                    ...    (//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color'])[${index}]
                    Log To Console    status= ${status}
                    IF    "${status}" == "INACTIVE"
                        ${Tech_flag}    Set Variable    True
                        ${Not_certified}    Get Text
                        ...    (//i[contains(@class, 'uk-icon-certificate') and contains(@class, 'uk-icon-small') and contains(@class, 'icon-gold')]/span[contains(@class, 'uk-content-label-18-danger-color')])[${index}]
                        Log To Console    Not_certified: ${Not_certified}
                        IF    "${Not_certified}" == "Not Currently Certified"
                            ${Tech_flag}    Set Variable    True
                            FOR    ${element}    IN    3
                                Remove Files    ${SOURCE_FOLDER}\\*.*
                                ${state_id_found}=    Run Keyword And Return Status
                                ...    RPA.Browser.Selenium.Wait Until Element Is Visible    (//a[contains(text(), 'Upload State Issued ID')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                Log To Console   State Issued ID Download Link Found: ${state_id_found}
                                IF    ${state_id_found} == True
                                    Wait Until Element Is Visible    (//a[contains(text(), 'Upload State Issued ID')]/following-sibling::a[contains(@class, 'download-link')])[${index}]    5s
                                    Click Element When Visible    (//a[contains(text(), 'Upload State Issued ID')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                    Sleep    2s
                                    ${files}    List Files In Directory    ${SOURCE_FOLDER}
                                    ${moved_count}=    Set Variable    0
                                    FOR    ${file}    IN    @{files}
                                        ${file_lower}=    Convert To Lowercase    ${file}
                                        Run Keyword If    'stateid' in '${file_lower}'    Move File    ${SOURCE_FOLDER}\\${file}    ${Epass_Path}\\DL.jpg
                                    END
                                    ${DL}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\DL.jpg 
                                    Log To Console    DL=${DL} 
                                END
                                ${ssn_found}=    Run Keyword And Return Status
                                ...    RPA.Browser.Selenium.Wait Until Element Is Visible    (//a[contains(text(), 'Upload SSN')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                Log To Console    SSN Download Link Found: ${ssn_found}
                                IF    ${ssn_found} == True
                                    Wait Until Element Is Visible    (//a[contains(text(), 'Upload SSN')]/following-sibling::a[contains(@class, 'download-link')])[${index}]    5s
                                    Click Element When Visible    (//a[contains(text(), 'Upload SSN')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                    Sleep    2s
                                    ${files}    List Files In Directory    ${SOURCE_FOLDER}
                                    ${moved_count}=    Set Variable    0
                                    FOR    ${file}    IN    @{files}
                                        ${file_lower}=    Convert To Lowercase    ${file}
                                        Run Keyword If    'securityid' in '${file_lower}'    Move File    ${SOURCE_FOLDER}\\${file}    ${Epass_Path}\\SSN.jpg
                                    END
                                    ${SSN}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\SSN.jpg
                                    Log To Console    SSN=${SSN}
                                END
                                ${auth_found}=    Run Keyword And Return Status
                                ...    RPA.Browser.Selenium.Wait Until Element Is Visible    (//a[contains(text(), 'Upload Authorization')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                Log To Console    Authorization Download Link Found: ${auth_found}
                                IF    ${auth_found} == True
                                    Wait Until Element Is Visible    (//a[contains(text(), 'Upload Authorization')]/following-sibling::a[contains(@class, 'download-link')])[${index}]    5s
                                    Click Element When Visible    (//a[contains(text(), 'Upload Authorization')]/following-sibling::a[contains(@class, 'download-link')])[${index}]
                                    Sleep    2s
                                    ${files}    List Files In Directory    ${SOURCE_FOLDER}
                                    ${moved_count}=    Set Variable    0
                                    FOR    ${file}    IN    @{files}
                                        ${file_lower}=    Convert To Lowercase    ${file}
                                        Run Keyword If    'Authorization'.lower() in '${file_lower}'    Move File    ${SOURCE_FOLDER}\\${file}    ${Epass_Path}\\Crimshield.pdf
                                    END
                                    ${Crimshield}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\Crimshield.pdf
                                    Log To Console    Crimshield=${Crimshield}
                                END
                                IF    ${DL} == True and ${SSN} == True and ${Crimshield} == True
                                    ${BGV_DT_Renewal}    Set Variable    True
                                    BREAK
                                ELSE
                                    ${BGV_DT_Renewal}    Set Variable    False
                                END 
                            END
                        ELSE
                            ${Tech_flag}    Set Variable    False
                            Append To file    ${Log}    Tech found but creteria not match.\n
                            Log To Console    Tech found but creteria not match.
                        END
                    ELSE
                        ${Tech_flag}    Set Variable    False
                        Append To file    ${Log}    Tech found but creteria not match.\n
                        Log To Console    Tech found but creteria not match.
                    END
                ELSE
                    Append To file    ${Log}    ETA not match as Complete.\n
                    Log To Console    ETA not match as Complete.
                END
            ELSE
                Append To file    ${Log}    Tech not found in Employee control center.\n
                Log To Console    Tech not found in Employee control center.
            END
        END
        Log To Console    BGV_DT_Renewal=${BGV_DT_Renewal}
        IF    ${BGV_DT_Renewal} == True
            Append To file    ${Log}    Creteria matches, BGV Initiation start.\n
            Log To Console    Creteria matches, BGV Initiation start.
            ${file_falg}    ${Drug_test}    BGV_Initiation
            ...    ${Alldatas}
            ...    ${credentials}
            ...    ${Epass_Path}
            ...    ${Epass_name}
            ...    ${Log}
            IF    ${Drug_test} == True
                Log To Console    DT initiation Start
                ${handles}    Get Window Titles
                Switch window    ${handles}[1]
                Sleep    2s
                ${Duplicates_Flag}    ${Clinic_flag}    ${Clinic_flag2}    DT Initiation
                ...    ${Alldatas}
                ...    ${credentials}
                ...    ${Epass_Path}
                ...    ${Epass_name}
                ...    ${Log}
                Log To Console    Duplicates_Flag=${Duplicates_Flag}
                Log To Console    Clinic_flag2=${Clinic_flag2}
                Log To Console    Clinic_flag=${Clinic_flag}
                IF    ${Duplicates_Flag} == False
                    IF    ${Clinic_flag} == True and ${Clinic_flag2} == True
                        ${File_exist}    Run Keyword And Return Status
                        ...    File Should Exist
                        ...    ${Epass_name}
                        IF    ${File_exist} == True
                            Append To File    ${Log}    Epassport Extracting.\n
                            Log To Console    Epassport Extracting
                            ${Conformation_No}
                            ...    ${ETA_Date}
                            ...    ${PDF_Extract}
                            ...    Epassport Extract
                            ...    ${Alldatas}
                            ...    ${Epass_name}
                            ...    ${Log}
                            IF    "${PDF_Extract}" == "True"
                                ${Recepients}    set variable    ${Alldatas}[supplier_mail]
                                ${CC}    Set Variable
                                ...    ${Alldatas}[approver_mail],${Alldatas}[cc_recipients],${credentials}[ybotID]
                                IF    "${Alldatas}[tax_term]" == "1099"
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                ELSE
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                END
                                ${Body}    Set Variable
                                ...    BG has been processed and DT is Re-scheduled emailed and texted for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Make sure he receives it.
                                ${Body1}    Set Variable
                                ...    Confirmation Number = ${Conformation_No}
                                ${Body2}    Set Variable
                                ...    This order must be completed by: ${ETA_Date}
                                ${Attachment}    Set Variable    ${Epass_name}
                                ${Mailsent}    Run Keyword And Return Status
                                ...    Sendmail
                                ...    ${Recepients}
                                ...    ${CC}
                                ...    ${Subject}
                                ...    ${Body}
                                ...    ${Body1}
                                ...    ${Body2}
                                ...    ${Attachment}
                                IF    ${Mailsent} == True
                                    Append To File    ${Log}    Mail sent for DT & BGV initiated.\n
                                    Log To Console    Mail sent for DT & BGV initiated
                                    Execute Sql String
                                    ...    UPDATE spectrum_onboarding SET bgv_dt_initiate_mail_sent = 'Mail Sent' WHERE SSN = '${Alldatas}[ssn]'
                                    Execute Sql String
                                    ...    UPDATE spectrum_onboarding SET status = 'Initiated' WHERE SSN = '${Alldatas}[ssn]'
                                ELSE
                                    Append To File
                                    ...    ${Log}
                                    ...    Mail not sent for DT & BGV initiated.\n
                                    Log To Console    Mail not sent for DT & BGV initiated
                                END
                                ${DT_Stop time}    Get Time
                                Append To File    ${Log}    DT_Bot Stop time=${DT_Stop time}.\n
                                Log To Console    DT_Bot Stop time=${DT_Stop time}
                                ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                ${CC}    Set Variable    ${credentials}[ybotID]
                                IF    "${Alldatas}[tax_term]" == "1099"
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                ELSE
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                END
                                ${Body}    Set Variable
                                ...    Files are not uploaded for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name] in Crimshield. Upload it manually.
                                ${Attachment}    Set Variable    ${doc}
                                ${Body1}    Set Variable
                                ${Body2}    Set Variable
                                ${Mailsent}    Run Keyword And Return Status
                                ...    Sendmail
                                ...    ${Recepients}
                                ...    ${CC}
                                ...    ${Subject}
                                ...    ${Body}
                                ...    ${Body1}
                                ...    ${Body2}
                                ...    ${Attachment}
                                IF    ${Mailsent} == True
                                    Append To File
                                    ...    ${Log}
                                    ...    Mail sent for files not upload for initiation.\n
                                    Log To Console
                                    ...    Mail sent for files not upload for initiation
                                ELSE
                                    Append To File
                                    ...    ${Log}
                                    ...    Mail not sent for files not upload for initiation.\n
                                    Log To Console
                                    ...    Mail not sent for files not upload for initiation
                                END
                            ELSE
                                Append To File    ${Log}    Epassport extracting failed.\n
                                Log To Console    Epassport extracting failed
                                ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                ${CC}    Set Variable    ${credentials}[ybotID]
                                IF    "${Alldatas}[tax_term]" == "1099"
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                ELSE
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                END
                                ${Body}    Set Variable    Spectrum Process
                                ${Body2}    Set Variable
                                ...    Unable to extract the Epassport details for ${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]. Fuse not updated and Mail not sent for Supervisor.
                                ${Attachment}    Set Variable    ${Epass_name}
                                ${Mailsent}    Run Keyword And Return Status
                                ...    Sendmail
                                ...    ${Recepients}
                                ...    ${CC}
                                ...    ${Subject}
                                ...    ${Body}
                                ...    ${Body1}
                                ...    ${Body2}
                                ...    ${Attachment}
                                IF    ${Mailsent} == True
                                    Log To Console    Mail sent for PDF error
                                    Append To File    ${Log}    Mail sent for PDF error
                                    Execute Sql String
                                    ...    UPDATE spectrum_onboarding SET status = 'PDF_Error' WHERE SSN = '${Alldatas}[ssn]'
                                ELSE
                                    Log To Console    Mail not sent for PDF error
                                    Append To File    ${Log}    Mail not sent for PDF error
                                END
                            END
                        ELSE
                            Append To file    ${Log}    Epassport not Downloaded.\n
                            Log To Console    Epassport not Downloaded
                            ${Recepients}    set variable    ${credentials}[ybotID]
                            ${CC}    Set Variable
                            IF    "${Alldatas}[tax_term]" == "1099"
                                ${Subject}    Set Variable
                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                            ELSE
                                ${Subject}    Set Variable
                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                            END
                            ${Body}    Set Variable    Spectrum Process
                            ${Body2}    Set Variable
                            ...    Epassport not Downloaded for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check the issue.
                            ${Attachment}    Set Variable    ${doc}
                            ${Mailsent}    Run Keyword And Return Status
                            ...    Sendmail
                            ...    ${Recepients}
                            ...    ${CC}
                            ...    ${Subject}
                            ...    ${Body}
                            ...    ${Body1}
                            ...    ${Body2}
                            ...    ${Attachment}
                            IF    ${Mailsent} == True
                                Append To file
                                ...    ${Log}
                                ...    Mail sent for Epassport not Downloaded.\n
                                Log To Console    Mail sent for Epassport not Downloaded
                            ELSE
                                Append To file
                                ...    ${Log}
                                ...    Mail not sent for Epassport not Downloaded.\n
                                Log To Console    Mail not sent for Epassport not Downloaded
                            END
                        END
                    ELSE
                        ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                        ${CC}    Set Variable    ${credentials}[ybotID]
                        IF    "${Alldatas}[tax_term]" == "1099"
                            ${Subject}    Set Variable
                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                        ELSE
                            ${Subject}    Set Variable
                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                        END
                        ${Body}    Set Variable    Spectrum Process
                        ${Body2}    Set Variable
                        ...    Clinic not available in the ZIP:${Alldatas}[clinic_zip_code] for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly share another ZIP code.
                        ${Attachment}    Set Variable    ${doc}
                        ${Mailsent}    Run Keyword And Return Status
                        ...    Sendmail
                        ...    ${Recepients}
                        ...    ${CC}
                        ...    ${Subject}
                        ...    ${Body}
                        ...    ${Body1}
                        ...    ${Body2}
                        ...    ${Attachment}
                        IF    ${Mailsent} == True
                            Append To file
                            ...    ${Log}
                            ...    Mail sent for Clinic not available.\n
                            Log To Console    Mail sent
                            Execute Sql String
                            ...    UPDATE spectrum_onboarding SET status = 'No Clinic Found' WHERE SSN = '${Alldatas}[ssn]'
                        ELSE
                            Append To file
                            ...    ${Log}
                            ...    Mail not sent for Clinic not available.\n
                            Log To Console    Mail not sent
                        END
                    END
                ELSE
                    Append To file
                    ...    ${Log}
                    ...    DT initiation POSSIBLE DUPLICATES for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name].\n
                    Log To Console
                    ...    POSSIBLE DUPLICATES for ${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name].
                    ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                    ${CC}    Set Variable    ${credentials}[ybotID]
                    IF    "${Alldatas}[tax_term]" == "1099"
                        ${Subject}    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                    ELSE
                        ${Subject}    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                    END
                    ${Body}    Set Variable    Spectrum Process
                    ${Body2}    Set Variable
                    ...    DT initiation POSSIBLE DUPLICATES for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check the issue.
                    ${Attachment}    Set Variable    ${doc}
                    ${Mailsent}    Run Keyword And Return Status
                    ...    Sendmail
                    ...    ${Recepients}
                    ...    ${CC}
                    ...    ${Subject}
                    ...    ${Body}
                    ...    ${Body1}
                    ...    ${Body2}
                    ...    ${Attachment}
                    IF    ${Mailsent} == True
                        Append To file
                        ...    ${Log}
                        ...    Mail sent for DT initiation POSSIBLE DUPLICATES.\n
                        Log To Console    Mail sent for DT initiation POSSIBLE DUPLICATES
                    ELSE
                        Append To file
                        ...    ${Log}
                        ...    Mail not sent for DT initiation POSSIBLE DUPLICATES.\n
                        Log To Console    Mail not sent for DT initiation POSSIBLE DUPLICATES
                    END
                END
            ELSE
                Append To file    ${Log}    BGV failed, not able to initiate DT.\n
                Log To Console    BGV failed, not able to initiate DT.
            END
        ELSE
            Append To file    ${Log}    Files are not downloaded successfully.\n
            Log To Console    Files are not downloaded successfully.
        END
    ELSE
        Append To file    ${Log}    Crimshield application not found.\n
        Log To Console    Crimshield application not found
    END