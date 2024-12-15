*** Settings ***
Documentation       OnBoarding Process-Spectrum DT_BGV_Status_Check

Library             RPA.Browser.Selenium    auto_close=${False}
Library             DatabaseLibrary
Library             RPA.JSON
Resource            Crimshield_login.robot
Library             Sendmail.py
Library             Collections
Library             RPA.JavaAccessBridge
Resource            DT&BGVFuseupdate.robot
Resource            Killtask.robot
Resource            Fuselogin.robot
Library             Scope_dir.py
Library             DateTime
Library             Dialogs


*** Variables ***
${doc}                  ${EMPTY}
${Body1}                ${EMPTY}
${Body2}                ${EMPTY}
${Initi_time}           ${EMPTY}
${CC}                   ${EMPTY}
${MAX_ITERATIONS}       5
${db_full_name1}        ${EMPTY}
@{expected_headers}     Criminal Background    Drug Screen Applicant    MVR/DMV Driving Record


*** Tasks ***
Process
    # Vault
    ${credentials}    Load JSON from file    credentials.json

    # Log file
    ${Time}    Get Time
    ${year}    Set Variable    ${Time}[0:4]
    ${month}    Set Variable    ${Time}[5:7]
    ${day}    Set Variable    ${Time}[8:10]
    ${mint}    Set Variable    ${Time}[11:13]
    ${Sec}    Set Variable    ${Time}[14:16]
    ${Log}    Set Variable    ${credentials}[Logfile]\\DT&BGV_${day}${month}${year}_${mint}_${Sec}.txt
    Create File    ${Log}
    # TRY
    Log To Console    *********************************Executing the Process*********************************
    Append To file
    ...    ${Log}
    ...    *********************************Executing the Process*********************************\n
    BGV_DT_Status_Check    ${credentials}    ${Log}
    Disconnect From Database
    Kill Chrome Processes
    cleanup_temp_items
    Log To Console    @###############################Execution Completed###############################
    Append To file
    ...    ${Log}
    ...    @###############################Execution Completed###############################\n
    # EXCEPT
    #    Disconnect From Database
    #    Kill Chrome Processes
    # cleanup_temp_items
    #    Append To file    ${DTLog}    -----------------Execution failed-----------------\n
    #    Log To Console    -----------------Execution failed-----------------
    # END


*** Keywords ***
BGV_DT_Status_Check
    [Arguments]    ${credentials}    ${Log}

    ${CrimShield_login}    Crimshield_login    ${credentials}    ${Log}
    ${FuseLogin}    Fuse Login    ${credentials}    ${Log}
    IF    ${CrimShield_login} == True and ${FuseLogin} == True
        Connect To Database
        ...    psycopg2
        ...    ${credentials}[DB_NAME]
        ...    ${credentials}[DB_USERNAME]
        ...    ${credentials}[DB_PASSWORD]
        ...    ${credentials}[DB_HOST]
        ...    ${credentials}[DB_PORT]
        Log To Console    Connecting DB.....
        Append To file    ${Log}    DB Connected\n
        # Get column names
        ${columns}    Query
        ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'spectrum_onboarding' AND table_schema = 'public'
        @{column_names}    Create List
        FOR    ${col}    IN    @{columns}
            Append To List    ${column_names}    ${col}[0]
        END
        # Get data rows
        ${result}    Query    SELECT * FROM public.spectrum_onboarding where status = 'Initiated'
        ${handles}    Get Window Titles
        Switch window    ${handles}[0]
        Sleep    2s
        Wait Until Element Is Visible    (//i[@class='uk-icon-users'])[3]    20s
        Click Element If Visible    (//i[@class='uk-icon-users'])[3]
        Log To Console    Selected employee control center
        FOR    ${row}    IN    @{result}
            ${Alldatas}    Create Dictionary
            ${num_columns}    Get Length    ${column_names}
            FOR    ${i}    IN RANGE    ${num_columns}
                Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
            END
            ${Date1}    Get Time
            ${Today_Date}    Set Variable    ${Date1}[:10]
            ${Date2}    set variable    ${Alldatas}[bgv_dt_initiated_date]
            ${Ini_Date}    Set Variable    ${Date2}[:10]
            IF    "${Today_Date}" != "${Ini_Date}"
                Append To File
                ...    ${Log}
                ...    @............................................Technician=${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]............................................\n
                Log To Console
                ...    *********************************${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]*********************************
                ${Tech_DOB}    Convert To String    ${Alldatas}[tech_dob]
                ${date_components}    Split String    ${Tech_DOB}    -
                ${DOBYear}    Get From List    ${date_components}    0
                ${DOBMonth}    Get From List    ${date_components}    1
                ${DOBDay}    Get From List    ${date_components}    2
                ${DOB}    Set Variable    ${DOBDay}${DOBMonth}${DOBYear}

                ${FIRST_NAME}    Set Variable    ${Alldatas}[tech_first_name]
                ${LAST_NAME}    Set Variable    ${Alldatas}[tech_last_name]

                ${first_name_words}    Split String    ${FIRST_NAME}
                ${last_name_words}    Split String    ${LAST_NAME}

                ${Firstname}    Set Variable    ${EMPTY}
                ${Lastname}    Set Variable    ${EMPTY}

                FOR    ${word}    IN    @{first_name_words}
                    ${Firstname}    Set Variable    ${Firstname}_${word}
                END
                ${Firstname}    Evaluate    "${Firstname}[1:]"
                FOR    ${word}    IN    @{last_name_words}
                    ${Lastname}    Set Variable    ${Lastname}_${word}
                END
                ${Lastname}    Evaluate    "${Lastname}[1:]"
                ${full_name}    Set Variable    ${Firstname}_${Lastname}

                ${Epass_Path}    Set Variable    ${credentials}[Default_Path]\\${full_name}${DOB}
                ${Epass_name}    Set Variable    ${Epass_Path}\\Crime_free_certificate.pdf

                ${handles}    Get Window Titles
                Switch window    ${handles}[0]
                Sleep    2s
                ${Firstname}    Strip String    ${Alldatas}[tech_first_name]
                ${Lastname}    Strip String    ${Alldatas}[tech_last_name]
                ${first_name}    Convert To Lower Case    ${Firstname}
                ${last_name}    Convert To Lower Case    ${Lastname}
                IF    "${Alldatas}[tech_middle_name]" != " " and "${Alldatas}[tech_middle_name]" != "None" and "${Alldatas}[tech_middle_name]" != ""
                    ${Middlename}    Strip String    ${Alldatas}[tech_middle_name]
                    ${middle_name}    Convert To Lower Case    ${Middlename}
                    ${db_full_name}    Set Variable    ${first_name} ${middle_name} ${last_name}
                ELSE
                    ${db_full_name}    Set Variable    ${first_name} ${last_name}
                    ${db_full_name1}    Set Variable    ${first_name} none ${last_name}
                END
                Input Text When Element Is Visible    //*[@id="fname"]    ${Firstname}
                Input Text When Element Is Visible    //*[@id="lname"]    ${Lastname}
                Select From List By Value    //*[@id="statusOptions"]    1
                Select From List By Value    //*[@id="search-days"]    0
                Sleep    1s
                Click Element If Visible    //*[@id="searchBtn-desktop"]
                Sleep    7s
                Click Element If Visible    //*[@id="searchBtn-desktop"]
                Sleep    3s
                Wait Until Element Is Visible    //div[@class='data-table']    20s
                ${no_records_visible1}    Run Keyword And Return Status
                ...    Element Should Be Visible
                ...    //li[contains(text(), 'No records to show.')]
                ...    5s
                Log To Console    no_records_visible1=${no_records_visible1}
                Append To file    ${Log}    no_records_visible1=${no_records_visible1}.\n
                IF    ${no_records_visible1} == True
                    Select From List By Value    //*[@id="statusOptions"]    2
                    Sleep    1s
                    Click Element If Visible    //*[@id="searchBtn-desktop"]
                    Sleep    4s
                    Wait Until Element Is Visible    //div[@class='data-table']    20s
                    ${no_records_visible2}    Run Keyword And Return Status
                    ...    Element Should Be Visible
                    ...    //li[contains(text(), 'No records to show.')]
                    ...    5s
                    Append To file    ${Log}    no_records_visible2=${no_records_visible2}.\n
                    Log To Console    no_records_visible2=${no_records_visible2}
                    IF    ${no_records_visible2} == True
                        Select From List By Value    //*[@id="statusOptions"]    3
                        Sleep    1s
                        Click Element If Visible    //*[@id="searchBtn-desktop"]
                        Sleep    4s
                        Wait Until Element Is Visible    //div[@class='data-table']    20s
                        ${no_records_visible3}    Run Keyword And Return Status
                        ...    Element Should Be Visible
                        ...    //li[contains(text(), 'No records to show.')]
                        ...    5s
                        Log To Console    no_records_visible3=${no_records_visible3}
                        Append To file    ${Log}    no_records_visible3=${no_records_visible3}.\n
                    ELSE
                        ${no_records_visible3}    Set Variable    False
                    END
                ELSE
                    ${no_records_visible3}    Set Variable    False
                END
                IF    ${no_records_visible3} == False
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
                        Log To Console    --------Row=${index}--------
                        Append To file    ${Log}    --------Row=${index}--------\n
                        TRY
                            Wait Until Element Is Visible    (//div[@class='data-table']//li)[${index}]    5s
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
                            Log To Console    Tech Found
                            ${Picture}    Get Text    (//div[@class='data-table']//li)[${index}]//td[4]
                            Log To Console    Picture=${Picture}
                            Append To file    ${Log}    Picture=${Picture}.\n
                            Sleep    1s
                            ${tech_Status}    Get Text    (//div[@class='data-table']//li)[${index}]//td[5]
                            Log To Console    tech_Status=${tech_Status}
                            Append To file    ${Log}    tech_Status=${tech_Status}.\n
                            Sleep    1s
                            ${ETA_Date}    Get Text    (//div[@class='data-table']//li)[${index}]//td[6]
                            Log To Console    ETA=${ETA_Date}
                            Append To file    ${Log}    ETA=${ETA_Date}.\n
                            Sleep    1s
                            ${Misc}    Get Text    (//div[@class='data-table']//li)[${index}]//td[7]
                            Log To Console    Misc=${Misc}
                            Append To file    ${Log}    Misc=${Misc}.\n
                            Sleep    1s
                            IF    "${Picture}" == " UPLOAD PHOTO" or "${Picture}" == " DETAILS" and "${Misc}" != "email | (INACTIVE)" and "${tech_Status}" != "VIEW REPORT"
                                Execute JavaScript
                                ...    document.evaluate("(//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
                                TRY
                                    Wait Until Element Is Visible
                                    ...    (//li[${index}]//div[@class='uk-width-medium-1-3 pad-right-30']//span[@class='uk-content-label-18-active-color'])
                                    ...    5s
                                    Log To Console    Active
                                    ${status}    Get Text
                                    ...    (//li[${index}]//div[@class='uk-width-medium-1-3 pad-right-30']//span[@class='uk-content-label-18-active-color'])
                                EXCEPT
                                    TRY
                                        Wait Until Element Is Visible
                                        ...    (//li[${index}]//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color'])
                                        ...    5s
                                        Log To Console    Inactive
                                        ${status}    Get Text
                                        ...    (//li[${index}]//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color'])
                                    EXCEPT
                                        Wait Until Element Is Visible
                                        ...    (//li[${index}]//div[@class='uk-width-medium-1-3 pad-right-30']//span[@class='uk-content-label-18-active-color'])
                                        ...    5s
                                        Log To Console    Active
                                        ${status}    Get Text
                                        ...    (//li[${index}]//div[@class='uk-width-medium-1-3 pad-right-30']//span[@class='uk-content-label-18-active-color'])
                                    END
                                END
                                Log To Console    status= ${status}
                                Append To file    ${Log}    status= ${status}.\n
                                FOR    ${round}    IN RANGE    1    4
                                    TRY
                                        ${Not_certified}    Get Text
                                        ...    (//li[${index}]//i[contains(@class, 'uk-icon-certificate') and contains(@class, 'uk-icon-small') and contains(@class, 'icon-gold')]/span[contains(@class, 'uk-content-label-18-danger-color')])
                                    EXCEPT
                                        TRY
                                            ${Not_certified}    Get Text
                                            ...    (//li[${index}]//a[contains(@id, 'charterBtn') and contains(@class, 'process-btn')])
                                        EXCEPT
                                            ${Not_certified}    Get Text
                                            ...    (//span[@class='uk-content-label-18-active-color'])
                                        END
                                    END
                                    IF    "${Not_certified}" == ""
                                        TRY
                                            ${Not_certified}    Get Text
                                            ...    (//li[${index}]//a[contains(@id, 'charterBtn') and contains(@class, 'process-btn')])
                                        EXCEPT
                                            TRY
                                                IF    "${Not_certified}" == ""
                                                    ${Not_certified}    Get Text
                                                    ...    (//li[${index}]//span[@class='uk-content-label-18-active-color'])
                                                END
                                            EXCEPT
                                                IF    "${Not_certified}" == ""
                                                    ${Not_certified}    Get Text
                                                    ...    (//li[${index}]//i[contains(@class, 'uk-icon-certificate') and contains(@class, 'uk-icon-small') and contains(@class, 'icon-gold')]/span[contains(@class, 'uk-content-label-18-danger-color')])
                                                END
                                            END
                                        END
                                    END
                                    IF    "${Not_certified}" != ""    BREAK
                                END
                                Log To Console    Not_certified: ${Not_certified}
                                Append To file    ${Log}    Not_certified: ${Not_certified}.\n
                                IF    "${status}" == "INACTIVE" and "${Not_certified}" == "Not Currently Certified - PENDING"
                                    Log To Console    Tech status is pending, waiting for BG
                                    Append To file    ${Log}    Tech status is pending, waiting for BG.\n
                                    ${result_falg}    Set Variable    True
                                ELSE
                                    IF    "${status}" == "ACTIVE" and "${Not_certified}" == " Submit For Security Clearance"
                                        Log To Console    Tech status is complete, waiting for submit.
                                        Append To file    ${Log}    Tech status is complete, waiting for submit.\n
                                        ${result_falg}    Set Variable    True
                                    ELSE
                                        IF    "${status}" == "INACTIVE" and "${Not_certified}" == " Submit For Security Clearance"
                                            Log To Console    Tech DT maybe Expired or DT is not available
                                            Append To file    ${Log}    Tech DT maybe Expired or DT is not available\n
                                            ${result_falg}    Set Variable    True
                                        ELSE
                                            IF    "${status}" == "INACTIVE" and "${Not_certified}" == "Not Currently Certified"
                                                Log To Console    This is old tech record maybe Expired.
                                                Append To file    ${Log}    This is old tech record maybe Expired.\n
                                                ${result_falg}    Set Variable    False
                                            ELSE
                                                IF    "${status}" == "INACTIVE" and "${Not_certified}" == "Currently Certified"
                                                    Log To Console    Tech is Terminated.
                                                    Append To file    ${Log}    Tech is Terminated.\n
                                                    ${result_falg}    Set Variable    False
                                                ELSE
                                                    IF    "${status}" == "ACTIVE" and "${Not_certified}" == "Currently Certified" and "${Picture}" == " DETAILS" and "${ETA_Date}" == "COMPLETE" and "${Misc}" == "email | active"
                                                        Log To Console    Tech is active and already submited.
                                                        Append To file
                                                        ...    ${Log}
                                                        ...    Tech is active and already submited.\n
                                                        ${result_falg}    Set Variable    False
                                                        IF    "${Alldatas}[status]" == "Initiated"
                                                            Execute Sql String
                                                            ...    UPDATE spectrum_onboarding SET status = 'completed' WHERE SSN = '${Alldatas}[ssn]'
                                                        END
                                                    END
                                                END
                                            END
                                        END
                                    END
                                END
                                IF    ${result_falg} == True
                                    # Criminal_status
                                    ${Criminal_label}    Get Text    (//td[@width='50%'][1]/div[1])[${index}]
                                    IF    '${Criminal_label}' == ' Criminal Background'
                                        Wait Until Element Is Visible
                                        ...    (//td[@width='50%'][2]/div[1])[${index}]
                                        ...    timeout=10
                                        ${criminal_status}    Get Text    (//td[@width='50%'][2]/div[1])[${index}]
                                        Log To Console    Criminal Background: ${criminal_status}
                                        IF    '${criminal_status}' == 'PENDING'
                                            ${criminal_result}    Set Variable    PENDING
                                        ELSE
                                            ${criminal_data_split}    Split String    ${criminal_status}    ${SPACE}
                                            ${criminal_result}    Get From List    ${criminal_data_split}    0
                                            ${criminal_date}    Get From List    ${criminal_data_split}    1
                                            ${criminal_date}    Replace String    ${criminal_date}    -    /
                                            Log To Console    criminal Status: ${criminal_result}
                                            Log To Console    criminal Date: ${criminal_date}
                                        END
                                        Append To file    ${Log}    criminal Status: ${criminal_result}.\n
                                    END
                                    # Drug_status
                                    ${Drug_label}    Get Text    (//td[@width='50%'][1]/div[2])[${index}]
                                    IF    '${Drug_label}' == ' Drug Screen Applicant'
                                        Wait Until Element Is Visible
                                        ...    (//td[@width='50%'][2]/div[2])[${index}]
                                        ...    timeout=10
                                        ${drug_status}    Get Text    (//td[@width='50%'][2]/div[2])[${index}]
                                        Log To Console    Drug Screen Applicant: ${drug_status}
                                        IF    '${drug_status}' == 'PENDING'
                                            ${drug_result}    Set Variable    PENDING
                                            ${drug_date}    Set Variable
                                            ${next_flag2}    set variable    True
                                        ELSE
                                            IF    '${drug_status}' == 'EXPIRED'
                                                ${current_date}    Get Current Date    result_format=%m/%d/%Y
                                                Log To Console    Current Date: ${current_date}
                                                ${drug_result}    Set Variable    EXPIRED
                                                ${drug_date}    Set Variable    ${current_date}
                                                ${next_flag2}    set variable    True
                                            ELSE
                                                ${drug_status_split}    Split String    ${drug_status}    /
                                                ${drug_data}    Get From List    ${drug_status_split}    0
                                                ${drug_result}    Get From List    ${drug_status_split}    1
                                                ${drug_data_split}    Split String    ${drug_data}    ${SPACE}
                                                ${status2}    Get From List    ${drug_data_split}    0
                                                ${drug_date}    Get From List    ${drug_data_split}    1
                                                ${drug_date}    Replace String    ${drug_date}    -    /
                                                Log To Console    drug test Status: ${status2}
                                                Log To Console    drug test Date: ${drug_date}
                                                Log To Console    drug test Result: ${drug_result}
                                                ${next_flag2}    set variable    True
                                            END
                                        END
                                        Append To file    ${Log}    drug test Result: ${drug_result}.\n
                                    ELSE
                                        ${next_flag2}    set variable    False
                                    END
                                    # MVR_status
                                    IF    ${next_flag2} == True
                                        ${MVR_label}    Get Text    (//td[@width='50%'][1]/div[3])[${index}]
                                        IF    '${MVR_label}' == ' MVR/DMV Driving Record'
                                            Wait Until Element Is Visible
                                            ...    (//td[@width='50%'][2]/div[3])[${index}]
                                            ...    timeout=10
                                            ${MVR_Status}    Get Text    (//td[@width='50%'][2]/div[3])[${index}]
                                            Log To Console    MVR/DMV Driving Record: ${MVR_Status}
                                            IF    '${MVR_Status}' == 'PENDING'
                                                ${MVR_result}    Set Variable    PENDING
                                            ELSE
                                                ${MVR_status_split}    Split String    ${MVR_Status}    /
                                                ${MVR_data}    Get From List    ${MVR_status_split}    0
                                                ${MVR_result}    Get From List    ${MVR_status_split}    1
                                                ${MVR_data_split}    Split String    ${MVR_data}    ${SPACE}
                                                ${status3}    Get From List    ${MVR_data_split}    0
                                                ${MVR_date}    Get From List    ${MVR_data_split}    1
                                                ${MVR_date}    Replace String    ${MVR_date}    -    /
                                                Log To Console    MVR Driving Record Status: ${status3}
                                                Log To Console    MVR Driving Record Date: ${MVR_date}
                                                Log To Console    MVR Driving Record Result: ${MVR_result}
                                            END
                                            Append To file    ${Log}    MVR Driving Record Result: ${MVR_result}.\n
                                        END
                                        Execute Sql String
                                        ...    UPDATE spectrum_onboarding SET bgv_eta = '${ETA_Date}' WHERE SSN = '${Alldatas}[ssn]'
                                        ${date}    Get Time
                                        IF    "${Alldatas}[mvr_status]" != "${MVR_result}"
                                            Execute Sql String
                                            ...    UPDATE spectrum_onboarding SET mvr_status = '${MVR_result}' WHERE SSN = '${Alldatas}[ssn]'
                                            ${MVR_flag}    Set Variable    True
                                            Append To file
                                            ...    ${Log}
                                            ...    MVR Driving Record Result '${MVR_result}' updated in DB.\n
                                        ELSE
                                            ${MVR_flag}    Set Variable    False
                                        END
                                        IF    "${Alldatas}[dt_status]" != "${drug_result}"
                                            IF    "${drug_result}" == "PASS"
                                                Execute Sql String
                                                ...    UPDATE spectrum_onboarding SET dt_status_received_date = '${drug_date}' WHERE SSN = '${Alldatas}[ssn]'
                                            ELSE
                                                Execute Sql String
                                                ...    UPDATE spectrum_onboarding SET dt_status_received_date = '${date}' WHERE SSN = '${Alldatas}[ssn]'
                                            END
                                            Execute Sql String
                                            ...    UPDATE spectrum_onboarding SET dt_status = '${drug_result}' WHERE SSN = '${Alldatas}[ssn]'
                                            # IF    "${drug_result}" == "EXPIRED"
                                            #     Execute Sql String
                                            #     ...    UPDATE spectrum_onboarding SET status = 'DT_Expired' WHERE SSN = '${Alldatas}[ssn]'
                                            # END
                                            ${DT_flag}    Set Variable    True
                                            Append To file    ${Log}    Drug Result '${drug_result}' updated in DB.\n
                                        ELSE
                                            ${DT_flag}    Set Variable    False
                                        END
                                        IF    "${Alldatas}[bgv_status]" != "${criminal_result}"
                                            IF    "${criminal_result}" == "COMPLETED"
                                                Execute Sql String
                                                ...    UPDATE spectrum_onboarding SET bgv_status_received_date = '${criminal_date}' WHERE SSN = '${Alldatas}[ssn]'
                                            ELSE
                                                Execute Sql String
                                                ...    UPDATE spectrum_onboarding SET bgv_status_received_date = '${date}' WHERE SSN = '${Alldatas}[ssn]'
                                            END
                                            Execute Sql String
                                            ...    UPDATE spectrum_onboarding SET bgv_status = '${criminal_result}' WHERE SSN = '${Alldatas}[ssn]'
                                            ${Crim_flag}    Set Variable    True
                                            Append To file
                                            ...    ${Log}
                                            ...    Criminal Record Result '${criminal_result}' updated in DB.\n
                                        ELSE
                                            ${Crim_flag}    Set Variable    False
                                        END
                                        IF    "${criminal_result}" == "COMPLETED" and "${drug_result}" != "EXPIRED" and "${MVR_result}" != "FAIL"
                                            ${Certificate}    Run Keyword And Return Status
                                            ...    Element Should Be Visible
                                            ...    (//div[@class='pad-left-30']//a[contains(text(), 'Crime Free Certificate')])[${index}]
                                            Log To Console    Certificate_found=${Certificate}
                                            Append To file    ${Log}    Certificate_found=${Certificate}.\n
                                            IF    ${Certificate} == True
                                                # Click Element If Visible    (//div[@class='pad-left-30']//a[contains(text(), 'Crime Free Certificate')])[${index}]
                                                # Sleep    2s
                                                # RPA.Desktop.Press Keys    CTRL    s
                                                # Sleep    2s
                                                # RPA.Desktop.Type Text    ${Epass_name}
                                                # Sleep    4s
                                                # RPA.Desktop.Press Keys    Enter
                                                # Sleep    2s
                                                Execute Sql String
                                                ...    UPDATE spectrum_onboarding SET fuse_status_check = 'Certified' WHERE SSN = '${Alldatas}[ssn]'
                                                Execute Sql String
                                                ...    UPDATE spectrum_onboarding SET status = 'completed' WHERE SSN = '${Alldatas}[ssn]'
                                                Log To Console    Status updated as complete in DB
                                                Append To file    ${Log}    Status updated as complete in DB.\n
                                                ${certified}    Set Variable    Found
                                            ELSE
                                                ${certified}    Set Variable    Not Found
                                                Execute Sql String
                                                ...    UPDATE spectrum_onboarding SET fuse_status_check = 'Cert not found' WHERE SSN = '${Alldatas}[ssn]'
                                            END
                                            Execute Sql String
                                            ...    UPDATE spectrum_onboarding SET status = 'completed' WHERE SSN = '${Alldatas}[ssn]'
                                        ELSE
                                            ${certified}    Set Variable
                                        END
                                        IF    "${drug_result}" == "FAIL" or "${drug_result}" == "EXPIRED" or "${MVR_result}" == "FAIL" or "${criminal_result}" == "COMPLETED"
                                            IF    "${Alldatas}[dt_status]" != "${drug_result}" or "${Alldatas}[mvr_status]" != "${MVR_result}" or "${Alldatas}[bgv_status]" != "${criminal_result}"
                                                ${Recepients}    set variable    ${credentials}[Spectrum_team]
                                                ${CC}    set variable    ${credentials}[ybotID]
                                                IF    "${Alldatas}[tax_term]" == "1099"
                                                    ${Subject}    Set Variable
                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                ELSE
                                                    ${Subject}    Set Variable
                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                END
                                                ${Body}    Set Variable
                                                ...    Please find the DT/BGV status for "${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]".\n\nMVR : "${MVR_result}"
                                                ${Body1}    Set Variable    DT : "${drug_result}"
                                                ${Body2}    Set Variable
                                                ...    BGV : "${criminal_result}" #ETA : "${ETA_Date}".\n\nCertificate : "${certified}"
                                                IF    "${criminal_result}" == "COMPLETED"
                                                    ${Attachment}    Set Variable    ${doc}
                                                ELSE
                                                    ${Attachment}    Set Variable    ${doc}
                                                END
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
                                                    Append To file    ${Log}    Mail sent for Tech result.\n
                                                    Log To Console    Mail sent for Tech result
                                                    IF    "${criminal_result}" == "COMPLETED"
                                                        Execute Sql String
                                                        ...    UPDATE spectrum_onboarding SET bgv_dt_status_mail_sent = 'Mail Sent' WHERE SSN = '${Alldatas}[ssn]'
                                                    END
                                                ELSE
                                                    Append To file    ${Log}    Mail not sent for Tech result.\n
                                                    Log To Console    Mail not sent for Tech result
                                                END
                                            END
                                        END
                                        IF    "${Alldatas}[fuse_status_check]" != "Certified" and "${Alldatas}[fuse_status_check]" != "Cert not found"
                                            IF    "${Alldatas}[fuse_status_check]" != "" and "${Alldatas}[fuse_status_check]" != "None"
                                                ${Today_date}    Get Time
                                                ${TARGET_DATE}    Set Variable    ${Alldatas}[fuse_status_check]
                                                ${Today_date}    Set Variable    ${Today_date}[:10]
                                                ${Target_date}    Add Time To Date    ${TARGET_DATE}    2 days
                                                ${Target_date}    Set Variable    ${Target_date}[:10]
                                                ${difference}    Evaluate    (datetime.datetime.strptime('${Today_date}', '%Y-%m-%d') - datetime.datetime.strptime('${TARGET_DATE}'[:10], '%Y-%m-%d')).days
                                                Log To Console    Target_date=${Target_date}
                                                Log To Console    Today_date=${Today_date}
                                                IF    "${Target_date}" == "${Today_date}" or ${difference} > 2
                                                    ${Fuse_update_flag}    Set Variable    True
                                                ELSE
                                                    ${Fuse_update_flag}    Set Variable    False
                                                END
                                            ELSE
                                                ${Fuse_update_flag}    Set Variable    True
                                            END
                                            Log To Console    Fuse_update_flag=${Fuse_update_flag}
                                            IF    "${Alldatas}[dt_status]" != "${drug_result}" and "${criminal_result}" != "COMPLETED" or "${Fuse_update_flag}" == "True"
                                                Log To Console    Fuse update initiated
                                                Append To file    ${Log}    Fuse update initiated.\n
                                                DT&BGV_Fuse_Update
                                                ...    ${credentials}
                                                ...    ${Alldatas}
                                                ...    ${ETA_Date}
                                                ...    ${Log}
                                                ...    ${criminal_result}
                                                ...    ${drug_result}
                                                ...    ${drug_date}
                                                ...    ${MVR_result}
                                            END
                                        END
                                    ELSE
                                        Append To file    ${Log}    Drug result not found for the tech.\n
                                        Log To Console    Drug result not found for the tech.
                                        Execute JavaScript
                                        ...    document.evaluate("(//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
                                    END
                                ELSE
                                    Append To file
                                    ...    ${Log}
                                    ...    Tech status already completed or not able to fetch text for status and Not certified.\n
                                    Log To Console
                                    ...    Tech status already completed or not able to fetch text for status and Not certified.
                                    Execute JavaScript
                                    ...    document.evaluate("(//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
                                END
                            ELSE
                                Append To file    ${Log}    ETA and Picture creteria are not Match.\n
                                Log To Console    ETA and Picture creteria are not Match.
                                # Execute JavaScript
                                # ...    document.evaluate("(//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
                            END
                        ELSE
                            Append To file    ${Log}    Tech not found in Employee control center.\n
                            Log To Console    Tech not found in Employee control center.

                        END
                    END
                ELSE
                    # Pause Execution    No record found.
                    Append To file    ${Log}    No record found in Employee control center.\n
                    Log To Console    No record found in Employee control center.
                END
            END
        END
    ELSE
        Log To Console    CrimShield or Fuse application login unsuccessful.
        Append To file    ${Log}    CrimShield or Fuse application login unsuccessful.\n
        Close Browser
        ${Recepients}    set variable    ${credentials}[ybotID]
        ${CC}    Set Variable
        ${Subject}    Set Variable    CrimShield or Fuse Login UnSuccessful.
        ${Body}    Set Variable    CrimShield or Fuse Login UnSuccessful. Kindly check the issue.
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
            Log To Console    Mail sent
            Append To file    ${Log}    Mail sent for CrimShield or Fuse Login UnSuccessful.\n
        ELSE
            Log To Console    Mail not sent
            Append To file    ${Log}    Mail not sent for CrimShield or Fuse Login UnSuccessful.\n
        END
    END
