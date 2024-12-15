*** Settings ***
Documentation       OnBoarding Process-Comcast DT_BGV_Status_Check

Library             RPA.Browser.Selenium    auto_close=${False}
Library             DatabaseLibrary
Library             RPA.JSON
Resource            EScreen Login.robot
Resource            DTStatus_Check.robot
Resource            DTExpired.robot
Library             Sendmail.py
Library             Collections
Resource            BGVPDFExtract.robot
Resource            BGVStatusFuseupdate.robot
Resource            Killtask.robot
Resource            Fuselogin.robot
Resource            BGVStatus_Check.robot


*** Variables ***
${doc}              ${EMPTY}
${Body1}            ${EMPTY}
${Body2}            ${EMPTY}
${Initi_time}       ${EMPTY}
${CC}               ${EMPTY}


*** Tasks ***
Process
    # Vault
    ${credentials}    Load JSON from file    credentials2.json

    ${Time}    Get Time
    Log To Console    ${Time}
    ${year}    Set Variable    ${Time}[0:4]
    ${month}    Set Variable    ${Time}[5:7]
    ${day}    Set Variable    ${Time}[8:10]
    ${mint}    Set Variable    ${Time}[11:13]
    ${Sec}    Set Variable    ${Time}[14:16]
    ${DTLog}    Set Variable    ${credentials}[DTLogfile]\\DT_${day}${month}${year}_${mint}_${Sec}.txt
    ${BGVLog}    Set Variable    ${credentials}[BGVLogfile]\\BGV_${day}${month}${year}_${mint}_${Sec}.txt
    Create File    ${DTLog}
    Create File    ${BGVLog}
    TRY
        Log To Console
        ...    *********************************Executing the Process*********************************
        Append To file
        ...    ${DTLog}
        ...    *********************************Executing the Process*********************************\n
        Append To file
        ...    ${BGVLog}
        ...    *********************************Executing the Process*********************************\n
        DT_BGV_Status_Check    ${credentials}    ${DTLog}    ${BGVLog}
        Disconnect From Database
        Kill Chrome Processes
        Log To Console    @###############################Execution Completed###############################
        Append To file
        ...    ${DTLog}
        ...    @###############################Execution Completed###############################\n
        Append To file
        ...    ${BGVLog}
        ...    @###############################Execution Completed###############################\n
    EXCEPT
        Disconnect From Database
        Kill Chrome Processes
        Append To file    ${DTLog}    -----------------Execution failed-----------------\n
        Append To file    ${BGVLog}    -----------------Execution failed-----------------\n
        Log To Console    -----------------Execution failed-----------------
    END


*** Keywords ***
DT_BGV_Status_Check
    [Arguments]    ${credentials}    ${DTLog}    ${BGVLog}

    # Process Flow
    ${EscreenLogin}    Escreen Login    ${credentials}    ${DTLog}    ${BGVLog}
    ${FuseLogin}    Fuse Login    ${credentials}    ${DTLog}    ${BGVLog}

    IF    ${EscreenLogin} == True and ${FuseLogin} == True
        Connect To Database
        ...    psycopg2
        ...    ${credentials}[DB_NAME]
        ...    ${credentials}[DB_USERNAME]
        ...    ${credentials}[DB_PASSWORD]
        ...    ${credentials}[DB_HOST]
        ...    ${credentials}[DB_PORT]
        Log To Console    DB Connected
        Append To file    ${DTLog}    DB Connected\n
        Append To file    ${BGVLog}    DB Connected\n
        # Get column names
        ${columns}    Query
        ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'onboarding' AND table_schema = 'public'
        @{column_names}    Create List
        FOR    ${col}    IN    @{columns}
            Append To List    ${column_names}    ${col}[0]
        END
        # Get data rows
        ${result}    Query    SELECT * FROM public.onboarding WHERE status = 'Initiated' and mso IN ('comcast', 'altice', 'btr')
        # Combine headers and data rows
        FOR    ${row}    IN    @{result}
            ${Alldatas}    Create Dictionary
            ${num_columns}    Get Length    ${column_names}
            FOR    ${i}    IN RANGE    ${num_columns}
                Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
            END
            ${Tech_DOB}    Convert To String    ${Alldatas}[tech_dob]
            ${date_components}    Split String    ${Tech_DOB}    -
            ${DOBYear}    Get From List    ${date_components}    0
            ${DOBMonth}    Get From List    ${date_components}    1
            ${DOBDay}    Get From List    ${date_components}    2
            ${DOB}    Set Variable    ${DOBDay}${DOBMonth}${DOBYear}

            ${Firstname}    Strip String    ${Alldatas}[first_name] 
            ${Lastname}    Strip String    ${Alldatas}[last_name]

            ${FIRST_NAME}    Set Variable    ${Firstname}
            ${LAST_NAME}    Set Variable    ${Lastname}

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
            
            IF    "${Alldatas}[suffix]" != " " and "${Alldatas}[suffix]" != "none" and "${Alldatas}[suffix]" != "" and "${Alldatas}[suffix]" != "None"
                ${suf}    Strip String    ${Alldatas}[suffix]
                ${suffix}    Set Variable    ${suf}
                ${full_name}    Set Variable    ${Firstname}_${Lastname}_${suffix}
            ELSE
                ${full_name}    Set Variable    ${Firstname}_${Lastname}
            END

            ${Epass_Path}    Set Variable    ${credentials}[Default_Path]\\${full_name}${DOB}
            ${DTEpass_name}    Set Variable    ${Epass_Path}\\${full_name}${DOB}_DTstatus.pdf
            ${BGV_PDF}    Set variable    ${Epass_Path}\\${full_name}${DOB}_BGV.pdf

            ${Firstname}    set variable    ${Alldatas}[first_name]
            ${Lastname}    Set Variable    ${Alldatas}[last_name]
            ${PC_Number}    Set Variable    ${Alldatas}[pc_number]

            ${Time}    Get Time
            IF    "${Time}[11:13]" == "08" or "${Time}[11:13]" == "09"
                Execute Sql String    UPDATE onboarding SET dt_status_time_check = ''
            END
            # ${confirmation_number}  Set Variable  ${Alldatas['dt_confirmation_number']}
            IF    "${Time}[11:13]" != "${credentials}[BGVUpdateTime]"
                # IF    "${confirmation_number}" != "POSSIBLE DUPLICATES"
                    IF    "${Alldatas}[dt_status]" == "Scheduled" or "${Alldatas}[dt_status]" == "Sent To Lab" or "${Alldatas}[dt_status]" == "Received At Lab" or "${Alldatas}[dt_status]" == "In Process With MRO" or "${Alldatas}[dt_status]" == "Remainder" or "${Alldatas}[dt_status]" == "In Process" or "${Alldatas}[dt_status]" == "Waiting" or "${Alldatas}[dt_status]" == "No Records Found"
                        Log To Console    ${Alldatas}[first_name]_${Alldatas}[last_name]-${Alldatas}[dt_status]
                        ${Date1}    Get Time
                        ${Today_Date}    Set Variable    ${Date1}[:10]
                        ${Date2}    set variable    ${Alldatas}[dt_initiated_date]
                        ${Ini_Date}    Set Variable    ${Date2}[:10]
                        IF    "${Today_Date}" != "${Ini_Date}"
                            Append To File
                            ...    ${DTLog}
                            ...    @............................................Technician=${Alldatas}[first_name]_${Alldatas}[last_name]${DOB}-(${Alldatas}[mso])............................................\n
                            Log To Console
                            ...    *********************************${Alldatas}[first_name]_${Alldatas}[last_name]${DOB}-(${Alldatas}[mso])*********************************
                            ${DTStatuscheck_Start_time}    Get Time
                            Log To Console    DTStatuscheck_Start_time=${DTStatuscheck_Start_time}
                            Append To File    ${DTLog}    DTStatuscheck_Start_time=${DTStatuscheck_Start_time}.\n
                            # TRY
                                ${handles}    Get Window Titles
                                Switch window    ${handles}[0]
                                ${E_Login_}    Run Keyword And Return Status
                                ...    Wait Until Element Is Visible
                                ...    //*[@id="mainFrame"]
                                ...    30s
                                IF    ${E_Login_} == True
                                    DTStatusCheck
                                    ...    ${Alldatas}
                                    ...    ${credentials}
                                    ...    ${Epass_Path}
                                    ...    ${DTEpass_name}
                                    ...    ${doc}
                                    ...    ${Body1}
                                    ...    ${Body2}
                                    ...    ${DTLog}
                                    ...    ${BGVLog}
                                    ${DTStatuscheck_Stop_time}    Get Time
                                    Log To Console    DTStatuscheck_Stop_time=${DTStatuscheck_Stop_time}
                                    Append To File    ${DTLog}    DTStatuscheck_Stop_time=${DTStatuscheck_Stop_time}.\n
                                ELSE
                                    Append To File    ${DTLog}    EScreen not found.\n
                                    Log To Console    EScreen not found.
                                END                         
                            # EXCEPT
                            #     Append To File    ${DTLog}    Erro Occured while processing DT Status Check.\n
                            #     Log To Console    Erro Occured while processing DT Status Check.
                            # END
                        END
                    END
                # END 
            END
            IF    "${Time}[11:13]" >= "${credentials}[BGVUpdateTime]"
                IF    "${Alldatas}[dt_status_time_check]" != "BGV_updated" and "${Alldatas}[dt_status_time_check]" != "DT_BGV_updated"
                    IF    "${Alldatas}[bgv_ticket_no]" != "None" and "${Alldatas}[bgv_status]" == "pending" and "${Alldatas}[bgv_requested_id]" == "None"
                        IF    "${Alldatas}[dt_status]" == "Negative" or "${Alldatas}[dt_status]" == "Positive" or "${Alldatas}[dt_status]" == "Positive Unable To Contact Donor" or "${Alldatas}[dt_status]" == "Canceled" or "${Alldatas}[dt_status]" == "Refusal To Test" or "${Alldatas}[dt_status]" == "Substituted" or "${Alldatas}[dt_status]" == "Refusal to test: Substituted"
                            Log To Console    BGV pending Status daily updating
                            Append To File    ${BGVLog}
                            ...    @...............................................Technician=${Alldatas}[first_name]_${Alldatas}[last_name]${DOB}-(${Alldatas}[mso])................................................\n
                            Append To File    ${BGVLog}    Bot_start_time=${Time}\n
                            Append To File    ${BGVLog}    BGV pending status daily updating\n
                            ${BGV_IssuedDate1}    Set Variable
                            BGVStatusFuseUpdate    ${Alldatas}    ${credentials}    ${BGV_PDF}    ${BGV_IssuedDate1}    ${BGVLog}    ${Firstname}    ${Lastname}
                            IF    "${Time}[11:13]" >= "${credentials}[BGVUpdateTime]" and "${Alldatas}[bgv_status]" == "pending"
                                Execute Sql String    UPDATE onboarding SET dt_status_time_check = 'BGV_updated' WHERE SSN = '${Alldatas}[ssn]'
                            END
                            Append To File    ${BGVLog}    Bot_stop_time=${Time}\n
                        END
                    END
                END
            END
            IF    "${Alldatas}[bgv_ticket_no]" != "None" and "${Alldatas}[bgv_status]" == "completed" and "${Alldatas}[bgv_requested_id]" == "None"
                Append To File
                ...    ${BGVLog}
                ...    @...............................................Technician=${Alldatas}[first_name]_${Alldatas}[last_name]${DOB}-(${Alldatas}[mso])................................................\n
                Log To Console
                ...    ********************BGV-${Alldatas}[first_name]_${Alldatas}[last_name]*********************
                ${BGVStatuscheck_Start_time}    Get Time
                Log To Console    BGVStatuscheck_Start_time=${BGVStatuscheck_Start_time}
                Append To File    ${BGVLog}    BGVStatuscheck_Start_time=${BGVStatuscheck_Start_time}.\n
                BGVStatuscheck    ${Alldatas}    ${credentials}    ${BGV_PDF}    ${BGVLog}
                ${BGVStatuscheck_Stop_time}    Get Time
                Log To Console    BGVStatuscheck_Stop_time=${BGVStatuscheck_Stop_time}
                Append To File    ${BGVLog}    BGVStatuscheck_Stop_time=${BGVStatuscheck_Stop_time}.\n
            ELSE
                IF    "${Alldatas}[bgv_ticket_no]" == "None" and "${Alldatas}[bgv_status]" == "completed"
                    Append To File    ${BGVLog}    Details updated wrongly in DB for ${Firstname}_${Lastname}${DOB}\n
                    ${Message}    set variable
                    ...    Details updated wrongly in DB, <b>bgv_ticket_no</b>=<b>${Alldatas}[bgv_ticket_no]</b> and <b>bgv_status</b>=<b>${Alldatas}[bgv_status]</b> for
                    ${Teams}    Run Keyword And Return Status
                    ...    Teamsfail
                    ...    ${Firstname}
                    ...    ${Lastname}
                    ...    ${Message}
                    IF    ${Teams} == True
                        Append To File    ${BGVLog}    Message sent for wrong details updated in DB.\n
                        Log To Console    Message sent for wrong details updated in DB.
                    ELSE
                        Append To File    ${BGVLog}    Message not sent for wrong details updated in DB.\n
                        Log To Console    Message not sent for wrong details updated in DB.
                    END
                END
            END
            IF    "${Alldatas}[bgv_ticket_no]" != "None" and "${Alldatas}[bgv_status]" == "failed" or "${Alldatas}[bgv_status]" == "suspended_license" or "${Alldatas}[bgv_status]" == "mvr" and "${Alldatas}[bgv_requested_id]" == "None"
                ${Time}    Get Time
                ${year}    Set Variable    ${Time}[0:4]
                ${month}    Set Variable    ${Time}[5:7]
                ${day}    Set Variable    ${Time}[8:10]
                ${BGV_IssuedDate1}    Set Variable    ${month}/${day}/${year}
                ${handles}    Get Window Titles
                Switch window    ${handles}[1]
                ${F_Login_}    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="topicons"]/ul/li[5]/a
                ...    30s
                IF    ${F_Login_} == True
                    ${FuseUpdate_Flag}    BGVStatusFuseUpdate
                    ...    ${Alldatas}
                    ...    ${credentials}
                    ...    ${BGV_PDF}
                    ...    ${BGV_IssuedDate1}
                    ...    ${BGVLog}
                    ...    ${Firstname}
                    ...    ${Lastname}
                    ${Message}    set variable    BGV is <b>Failed</b> for
                    ${Teams}    Run Keyword And Return Status
                    ...    Teamsfail
                    ...    ${Firstname}
                    ...    ${Lastname}
                    ...    ${Message}
                    IF    ${Teams} == True
                        Append To File    ${BGVLog}    Message sent for BGV is Failed.\n
                        Log To Console    Message sent for BGV is Failed.
                    ELSE
                        Append To File    ${BGVLog}    Message not sent for BGV is Failed.\n
                        Log To Console    Message not sent for BGV is Failed.
                    END
                    ${Recepients}    set variable    ${Alldatas}[supplier_mail]
                    ${CC}    Set Variable
                    ...    ${Alldatas}[approver_mail],${Alldatas}[cc_recipients],${credentials}[ybotID]
                    IF    "${Alldatas}[tax_term]" == "1099"
                        ${Subject}    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                    ELSE
                        ${Subject}    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                    END
                    IF    "${Alldatas}[bgv_status]" == "failed"
                        ${Body}    Set Variable
                        ...    The applicant ${Alldatas}[first_name] ${Alldatas}[last_name] failed background test, if he would like to dispute or request further information he can contact
                        ${Body1}    Set Variable    HireRight- Phone- 866.521.6995, Option 1 for Applicant Care.\n 
                        ${Body2}    Set Variable    Please acknowledge receipt of this request and update this email thread upon completion of removal.
                        Append To File    ${BGVLog}    BGV is Failed.\n
                        Log To Console    BGV is Failed.
                    ELSE
                        IF    "${Alldatas}[bgv_status]" == "suspended_license"
                            ${Body}    Set Variable
                            ...    The applicant ${Alldatas}[first_name] ${Alldatas}[last_name] failed the background test due to a suspended license.
                            ${Body1}    Set Variable    
                            ${Body2}    Set Variable    Can you please have this issue resolved and update us. Once done, we'll re-run his MVR.
                            Append To File    ${BGVLog}    BGV is Failed due to suspended_license.\n
                            Log To Console    BGV is Failed due to suspended_license.
                        ELSE
                            IF    "${Alldatas}[bgv_status]" == "mvr"
                                ${Body}    Set Variable
                                ...    The applicant ${Alldatas}[first_name] ${Alldatas}[last_name] failed the background test due to a MVR Issues.
                                ${Body1}    Set Variable    
                                ${Body2}    Set Variable    Can you please have this issue resolved and update us. Once done, we'll re-run his MVR.
                                Append To File    ${BGVLog}    BGV is Failed due to MVR.\n
                                Log To Console    BGV is Failed due to MVR.
                            END
                        END
                    END
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
                        Append To File    ${BGVLog}    Mail sent for BGV is Failed.\n
                        Log To Console    Mail sent BGV is Failed
                        Execute Sql String
                        ...    UPDATE onboarding SET bgv_status_mail_sent = 'Mail sent' WHERE SSN = '${Alldatas}[ssn]'
                    ELSE
                        Append To File    ${BGVLog}    Mail not sent for BGV is Failed.\n
                        Log To Console    Mail not sent BGV is Failed
                    END
                    Execute Sql String
                    ...    UPDATE onboarding SET status = 'Removed' WHERE SSN = '${Alldatas}[ssn]'
                END
            END
            IF    "${Alldatas}[bgv_status]" == "completed" and "${Alldatas}[bgv_issued_date]" != "None"
                IF    "${Alldatas}[dt_status]" == "Negative" or "${Alldatas}[dt_status]" == "Positive" or "${Alldatas}[dt_status]" == "Positive Unable To Contact Donor"
                    Execute Sql String    UPDATE onboarding SET status = 'completed' WHERE SSN = '${Alldatas}[ssn]'
                    Append To File
                    ...    ${BGVLog}
                    ...    Initiation and Status check completed for ${Alldatas}[first_name]_${Alldatas}[last_name]\n
                    Append To File
                    ...    ${DTLog}
                    ...    Initiation and Status check completed for ${Alldatas}[first_name]_${Alldatas}[last_name]\n
                    Log To Console
                    ...    Initiation and Status check completed for ${Alldatas}[first_name]_${Alldatas}[last_name]
                END
            END
            IF    "${Alldatas}[dt_status]" == "Refusal to test" or "${Alldatas}[dt_status]" == "Refusal to test: Substituted"
                Execute Sql String    UPDATE onboarding SET status = 'Removed' WHERE SSN = '${Alldatas}[ssn]'
            END
        END
    ELSE
        Append To File    ${DTLog}    EScreen and Fuse Login Unsuccessful.\n
        Append To File    ${BGVLog}    EScreen and Fuse Login Unsuccessful.\n
        Log To Console    EScreen and Fuse Login Unsuccessful.
        Close Browser
        ${Recepients}    set variable    ${credentials}[ybotID]
        ${CC}    Set Variable
        ${Subject}    Set Variable    EScreen and Fuse Login UNSuccessful-DTStatuscheck
        ${Body}    Set Variable    EScreen and Fuse Login UnSuccessful. Kindly check the issue.
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
            Append To File    ${DTLog}    Mail sent for EScreen and Fuse Login Unsuccessful.\n
            Append To File    ${BGVLog}    Mail sent for EScreen and Fuse Login Unsuccessful.\n
            Log To Console    Mail sent
        ELSE
            Append To File    ${DTLog}    Mail not sent for EScreen and Fuse Login Unsuccessful.\n
            Append To File    ${BGVLog}    Mail not sent for EScreen and Fuse Login Unsuccessful.\n
            Log To Console    Mail not sent
        END
    END
