*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     String
Library     Collections
Library     OperatingSystem
Library     RPA.Desktop
Library     DatabaseLibrary
Library     DateTime
Library     Sendmail.py
Resource    DT_Initiation.robot
Resource    EpassportExtract.robot


*** Variables ***
${doc}      ${EMPTY}
${Body1}    ${EMPTY}
${Body2}    ${EMPTY}
${CC}       ${EMPTY}


*** Keywords ***
DT_Renewal
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
                Click Element If Visible    (//*[@id="main-content"]//table)[2]//tbody/tr[${index}]/td[1]
                Wait Until Element Is Visible
                ...    //div[@class='uk-width-medium-1-3 pad-right-30']//span[@class='uk-content-label-18-active-color']
                ...    5s
                ${status}    Get Text
                ...    //div[@class='uk-width-medium-1-3 pad-right-30']//span[@class='uk-content-label-18-active-color']
                Log To Console    status=${status}
                IF    "${status}" == "ACTIVE"
                    ${Tech_flag}    Set Variable    True
                    Log To Console    Tech_flag= ${Tech_flag}
                    TRY
                        ${Progress}    Get Text
                        ...    //div[@class='uk-width-medium-1-3 uk-hidden-medium']//span[@class='uk-content-label-18-danger-color']
                        Log To Console    Progress=${Progress}
                    EXCEPT
                        Log To Console    Tech is ready for Renewal.
                        ${Progress}    Set Variable
                    END
                    IF    "${Progress}" == "RENEWAL IN PROGRESS"
                        ${Progress_flag}    Set Variable    False
                        Log To Console    Already Tech is Renewaled
                    ELSE
                        ${Progress_flag}    Set Variable    True
                        ${membership_active_to}    Get Text    //div[contains(text(),'Membership Active To:')]/span
                        Log To Console    Membership Active To: ${membership_active_to}
                        Log To Console    Tech is ready for Renewal.
                        IF    "${Alldatas}[service]" == "non_driver"
                            ${download_element}    Get WebElement
                            ...    //a[contains(text(),' Upload Non-Driver Affidavit')]/following::a[contains(@class,'download-link')][1]
                            ${element_exists}    Run Keyword And Return Status
                            ...    Element Should Be Visible
                            ...    ${download_element}
                            IF    ${element_exists} == False
                                Log To Console    Download file not available for    Upload Non-Driver Affidavit
                                ${Non_driver_file}    Set Variable    False
                            ELSE
                                Click Element If Visible    ${download_element}
                                ${Non_driver_file}    Set Variable    True
                                Log To Console    File downloaded for    Upload Non-Driver Affidavit
                            END
                        ELSE
                            ${Non_driver_file}    Set Variable    True
                        END
                        BREAK
                    END
                ELSE
                    ${Tech_flag}    Set Variable    False
                    Log To Console    Not Active
                    Click Element If Visible    (//*[@id="main-content"]//table)[2]//tbody/tr[${index}]/td[1]
                END
            ELSE
                ${Tech_flag}    Set Variable    False
                Click Element If Visible    (//*[@id="main-content"]//table)[2]//tbody/tr[${index}]/td[1]
            END
        END
        Log To Console    Tech_flag=${Tech_flag}
        IF    ${Tech_flag} == True
            Log To Console    Progress_flag=${Progress_flag}
            IF    ${Progress_flag} == True
                Log To Console    Non_driver_file=${Non_driver_file}
                IF    ${Non_driver_file} == True
                    Wait Until Element Is Visible    (//i[@class='uk-icon-home'])[1]    5s
                    Click Element If Visible    (//i[@class='uk-icon-home'])[1]
                    ${Verifications1}    Run Keyword And Return Status
                    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
                    ...    //div[text()='APPLICATION RENEWAL']
                    ...    30s
                    IF    "${Verifications1}" == "True"
                        Click Element If Visible    //span[text()='No']
                        Log To Console    Application RENEWAL Appear
                    END
                    Wait Until Element Is Visible    //*[@id="totalRenew"]    20s
                    Click Element If Visible    //*[@id="totalRenew"]
                    Sleep    3s
                    Wait Until Element Is Visible    //*[@id="rcenter-search"]    10s
                    Input Text When Element Is Visible    //*[@id="rcenter-search"]    ${Alldatas}[tech_last_name]
                    Press Key    //*[@id="rcenter-search"]    \\13
                    Sleep    5s
                    TRY
                        Wait Until Element Is Visible    (//*[@id="main-content"]//table)[2]//tbody    20s
                        ${rows}    Get WebElements    (//*[@id="main-content"]//table)[2]//tbody/tr
                        ${row_count}    Get Length    ${rows}
                        Log To Console    Number of Rows Found: ${row_count}
                        FOR    ${index}    IN RANGE    1    ${row_count + 1}
                            ${applicant_name}    Get Text
                            ...    (//*[@id="main-content"]//table)[2]//tbody/tr[${index}]/td[1]
                            Log To Console    applicant_name=${applicant_name}
                            ${applicant_name}    Strip String    ${applicant_name}
                            ${applicant_name}    Convert To Lower Case    ${applicant_name}
                            Log To Console    '${applicant_name}' == '${db_full_name}'
                            IF    '${applicant_name}' == '${db_full_name}'
                                ${Renewal_flag}    Set Variable    True
                                Log To Console    Renewal_flag= ${Renewal_flag}
                            END
                        END
                    EXCEPT
                        ${Renewal_flag}    Set Variable    False
                        Log To Console    Tech not found
                    END
                    IF    ${Renewal_flag} == True
                        Wait Until Element Is Visible
                        ...    //a[contains(@id, '-yes') and contains(@id, 'applicant')]
                        ...    20s
                        Click Element If Visible    //a[contains(@id, '-yes') and contains(@id, 'applicant')]
                        Wait Until Element Is Visible    //div[text()='CRIMSHIELD CERTIFICATION RENEWAL']    30s
                        IF    "${Alldatas}[service]" == "driver"
                            Execute JavaScript    document.getElementById('confirmDmvOnRenewal').click()
                            Sleep    1s
                            IF    "${Alldatas}[tech_middle_name]" == " " and "${Alldatas}[tech_middle_name]" == "None" and "${Alldatas}[tech_middle_name]" == ""
                                Input Text    //*[@id="renewal-middleName"]    NONE
                            END
                            Input Text When Element Is Visible
                            ...    //*[@id="renewal-driversLicense"]
                            ...    ${Alldatas}[license_number]
                            Sleep    1s
                            ${tech_state1}    Set Variable    ${Alldatas}[license_state]
                            ${tech_state1}    Replace String    ${tech_state1}    _    ' '
                            ${Cleaned_String1}    Replace String    ${tech_state1}    '    ${EMPTY}
                            ${state_name}    Convert To Title Case    ${Cleaned_String1}
                            Log To Console    ${state_name}
                            IF    "${state_name}" == "District Of Columbia"
                                ${state_name}    Replace String    ${tech_state1}    Of    of
                            END
                            IF    "${state_name}" == "federated' 'states' 'of' 'micronesia" or "${state_name}" == "Federated States Of Micronesia"
                                ${state_name}    Set Variable    Federated States of Micronesia
                            END
                            IF    "${state_name}" == "Armed Forces Americas Except Canada"
                                ${state_name}    Set Variable    Armed Forces Americas (Except Canada)
                            END
                            IF    "${state_name}" == "Armed Forces International Except Americas"
                                ${state_name}    Set Variable    Armed Forces (International Except Americas)
                            END
                            Log To Console    state_name=${state_name}
                            Wait Until Element Is Visible    //*[@id="renewal-dmvStateCode2"]    timeout=10s
                            Select From List By Label    //*[@id="renewal-dmvStateCode2"]    ${state_name}
                        ELSE
                            Execute JavaScript    document.getElementById('confirmNonDriverOnRenewal').click()
                            Click Element If Visible    //label[@for='nonDriverFile']
                            Sleep    2s
                            RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    1s
                        END
                        Execute JavaScript    document.getElementById('confirmDSOnRenewal').click()
                        Sleep    1s
                        Log To Console    license_state=${Alldatas}[badge]
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
                        Wait Until Element Is Visible
                        ...    //*[@id="clientRetailLocationInfoIdSelect-renewal"]
                        ...    timeout=10s
                        Click Element If Visible    //*[@id="clientRetailLocationInfoIdSelect-renewal"]
                        Click Element If Visible    ${PCbadge}
                        Sleep    1s
                        Wait Until Element Is Visible    //*[@id="employmentContractTypeIdRenewal"]    5s
                        IF    "${Alldatas}[tax_term]" == "w2"
                            Select From List By Value    //*[@id="employmentContractTypeIdRenewal"]    1
                        ELSE
                            Select From List By Value    //*[@id="employmentContractTypeIdRenewal"]    2
                        END
                        Click Element If Visible    //*[@id="renewApplication"]/div[7]/label/div
                        Sleep    2s
                        # Click Element If Visible    //*[@id="processRenewalBtn"]
                        # Sleep    15s
                        # ${handles}    Get Window Titles
                        # Switch window    ${handles}[1]
                        # Sleep    2s
                        ${Popup_exists}    Run Keyword And Return Status
                        ...    Element Should Contain
                        ...    xpath=//div[contains(@class, 'uk-title-dialog')]
                        ...    CRIMSHIELD CERTIFICATION RENEWAL
                        IF    ${Popup_exists} == True
                            # Click Element If Visible    //*[@id="renewal-with-mvr-Form"]/div/div[1]/a
                            # Click Element    xpath=//a[contains(text(), 'ORDER DRUG SCREENING')]
                            # Click Element    css=a.orderDSRenewalATag.uk-button.uk-button-primary.process-btn.uk-width-1-1
                            # Sleep    3s
                            # Wait Until Element Is Visible    //a[contains(text(), '(LINK to ORDER PAGE)')]    10s
                            # Click Element If Visible    //a[contains(text(), '(LINK to ORDER PAGE)')]
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
                                        ${Conformation_No}    ${ETA_Date}    ${PDF_Extract}    Epassport Extract
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
                                            ...    DT is Re-scheduled emailed and texted for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Make sure he receives it.
                                            ${Body1}    Set Variable
                                            ...    Confirmation Number = ${Conformation_No}
                                            ${Body2}    Set Variable    This order must be completed by: ${ETA_Date}
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
                                            Log To Console    Mail sent for Epassport not Downloaded.
                                        ELSE
                                            Append To file
                                            ...    ${Log}
                                            ...    Mail not sent for Epassport not Downloaded.\n
                                            Log To Console    Mail not sent for Epassport not Downloaded.
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
                                        Append To file    ${Log}    Mail sent for Clinic not available.\n
                                        Log To Console    Mail sent for Clinic not available.
                                        Execute Sql String
                                        ...    UPDATE spectrum_onboarding SET status = 'No Clinic Found' WHERE SSN = '${Alldatas}[ssn]'
                                    ELSE
                                        Append To file    ${Log}    Mail not sent for Clinic not available.\n
                                        Log To Console    Mail not sent for Clinic not available.
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
                                    Log To Console    Mail sent for DT initiation POSSIBLE DUPLICATES.
                                ELSE
                                    Append To file
                                    ...    ${Log}
                                    ...    Mail not sent for DT initiation POSSIBLE DUPLICATES.\n
                                    Log To Console    Mail not sent for DT initiation POSSIBLE DUPLICATES.
                                END
                            END
                        ELSE
                            Append To file
                            ...    ${Log}
                            ...    CRIMSHIELD CERTIFICATION RENEWAL Popup not found for DTRenewal.\n
                            Log To Console    CRIMSHIELD CERTIFICATION RENEWAL popup not found for DTRenewal
                        END
                    ELSE
                        Append To file    ${Log}    Tech not found for Renewal.\n
                        Log To Console    Tech not found for Renewal
                    END
                ELSE
                    Append To file    ${Log}    Non_Driver file not found.\n
                    Log To Console    Non_Driver file not found.
                END
            ELSE
                Append To file    ${Log}    Tech is alreay renewaled.\n
                Log To Console    Tech is alreay renewaled.
            END
        ELSE
            Append To file    ${Log}    Tech not found in Employee control center.\n
            Log To Console    Tech not found in Employee control center.
        END
    ELSE
        Append To file    ${Log}    Crimshield application not found.\n
        Log To Console    Crimshield application not found
    END
