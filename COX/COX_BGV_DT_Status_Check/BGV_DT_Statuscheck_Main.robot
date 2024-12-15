*** Settings ***
Documentation       COX_Onboarding Process-COX_DT_BGV_Satus_Check

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.JSON
Library             DatabaseLibrary
Library             Collections
Resource            Infomart_login.robot
Resource            status_check.robot
Resource            Fuse_login.robot
Resource            killtask.robot
Library             Scope_dir.py
# Library             psutil.py


*** Variables ***
${doc}              ${EMPTY}
${Body1}            ${EMPTY}
${Body2}            ${EMPTY}
${Initi_time}       ${EMPTY}
${CC}               ${EMPTY}
${PID}    12340
*** Tasks ***
Process
    #Vault
    ${credentials}    Load JSON from file    Infomart.json
    
    #Log File
    ${Time}    Get Time
    ${year}    Set Variable    ${Time}[0:4]
    ${month}    Set Variable    ${Time}[5:7]
    ${day}    Set Variable    ${Time}[8:10]
    ${mint}    Set Variable    ${Time}[11:13]
    ${Sec}    Set Variable    ${Time}[14:16]
    ${DTLog}    Set Variable    ${credentials}[Logfile]\\BGV&DT_Status_${day}${month}${year}_${mint}_${Sec}.txt
    Create File    ${DTLog}
    TRY
        Log To Console
        ...    *********************************Executing the Process*****************
        Append To file
        ...    ${DTLog}
        ...    *********************************Executing the Process*********************************\n
        BGV_DT_Status_Check    ${credentials}    ${DTLog}
        Disconnect From Database
        Kill Chrome Processes
        # cleanup_temp_items
        Log To Console    @###############################Execution Completed###############################
        Append To file
        ...    ${DTLog}
        ...    @###############################Execution Completed###############################\n
    EXCEPT
        Disconnect From Database
        Kill Chrome Processes
        # cleanup_temp_items
        # TRY
        #     ${result}=    Run Process    chrome.exe    timeout=10s
        # EXCEPT    psutil.NoSuchProcess
        #     Log    Chrome process no longer exists, skipping action
        # END
        Append To file    ${DTLog}    -----------------Execution failed-----------------\n
        Log To Console    -----------------Execution failed-----------------
    END
    


*** Keywords ***
BGV_DT_Status_Check
    [Arguments]    ${credentials}    ${DTLog}

    FOR    ${i}    IN RANGE    3
        ${Infomart_Login}    Run Keyword And Return Status    Infomart_Login    ${credentials}    ${DTLog}
        IF    ${Infomart_Login} == True
            BREAK
        ELSE
            Kill Chrome Processes
        END
    END
    ${Fuse_Login}    Fuse_Login    ${credentials}    ${DTLog}
    IF    ${Infomart_Login} == True and ${FuseLogin} == True
        Connect To Database
        ...    psycopg2
        ...    ${credentials}[DB_NAME]
        ...    ${credentials}[DB_USERNAME]
        ...    ${credentials}[DB_PASSWORD]
        ...    ${credentials}[DB_HOST]
        ...    ${credentials}[DB_PORT]
        Log To Console    DB Connected
        Append To file    ${DTLog}    DB Connected\n
        # Get column names
        ${columns}    Query
        ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'cox_onboarding' AND table_schema = 'public'
        @{column_names}    Create List
        FOR    ${col}    IN    @{columns}
            Append To List    ${column_names}    ${col}[0]
        END
        # Get data rows
        ${result}    Query    SELECT * FROM public.cox_onboarding WHERE status = 'Initiated'
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

           ${FIRST_NAME}    Set Variable    ${Alldatas}[first_name]
            ${LAST_NAME}    Set Variable    ${Alldatas}[last_name]
                        
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

            IF    "${Alldatas}[suffix]" != "" and "${Alldatas}[suffix]" != "None" and "${Alldatas}[suffix]" != " "
                ${suffix}    Set Variable    ${Alldatas}[suffix]
                ${full_name}    Set Variable    ${Firstname}_${Lastname}_${suffix}
            ELSE
                ${full_name}    Set Variable    ${Firstname}_${Lastname}
            END

            ${Epass_Path}    Set Variable    ${credentials}[Default_Path]\\${full_name}${DOB}
            ${Epass_name}    Set Variable    ${Epass_Path}\\${full_name}${DOB}_Status.pdf

            ${Date1}    Get Time
            ${Today_Date}    Set Variable    ${Date1}[:10]
            ${Date2}    set variable    ${Alldatas}[bgv_dt_initiated_date]
            ${Ini_Date}    Set Variable    ${Date2}[:10]
            IF    "${Today_Date}" != "${Ini_Date}"
                Status_Check    ${Alldatas}
                ...    ${credentials}
                ...    ${Epass_name}
                ...    ${Epass_Path}
                ...    ${DTLog}
            END
        END
        # ${is_running}=    Is Process Running    ${PID}
        # Run Keyword If    ${is_running}    Log To Console    Process with PID ${PID} is running.
        # ...               ELSE    Log To Console    Process with PID ${PID} no longer exists.
    ELSE
        Append To File    ${DTLog}    Infomart and Fuse Login Unsuccessful.\n
        Log To Console    Infomart and Fuse Login Unsuccessful.
        Close Browser
        ${Recepients}    set variable    ${credentials}[Recipient]
        ${CC}    set variable    
        ${Subject}    Set Variable    Infomart and Fuse Login UNSuccessful-Statuscheck
        ${Body}    Set Variable    Infomart and Fuse Login UnSuccessful. Kindly check the issue.
        ${Attachment}    Set Variable    ${doc}
        ${Mailsent}    Run Keyword And Return Status
        ...    Sendmail
        ...    ${Recepients}
        ...    ${CC}
        ...    ${Subject}
        ...    ${Body}
        ...    ${Attachment}
        IF    ${Mailsent} == True
            Append To File    ${DTLog}    Mail sent for Infomart and Fuse Login Unsuccessful.\n
            Log To Console    Mail sent for Infomart and Fuse Login Unsuccessful
        ELSE
            Append To File    ${DTLog}    Mail not sent for Infomart and Fuse Login Unsuccessful.\n
            Log To Console    Mail not sent for Infomart and Fuse Login Unsuccessful
        END
    END
