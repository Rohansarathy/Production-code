*** Settings ***
Documentation       OnBoarding Process-Spectrum DT_BGV_Status_Check

Library             RPA.Browser.Selenium    auto_close=${False}
Library             DatabaseLibrary
Library             RPA.JSON
Resource            Crimshield_login.robot
Library             Sendmail.py
Library             Collections
Library             RPA.JavaAccessBridge
Library             RPA.Robocorp.WorkItems
Library             DateTime
Library             RPA.MSGraph
Resource            DT&BGVFuseupdate.robot
Resource            Killtask.robot
Resource            Fuselogin.robot
Library             Dialogs


*** Variables ***
${doc}                  ${EMPTY}
${Body1}                ${EMPTY}
${Body2}                ${EMPTY}
${Initi_time}           ${EMPTY}
${CC}                   ${EMPTY}
${MAX_ITERATIONS}       2
${DATE_FORMAT}          %m/%d/%Y


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
    BGV_DT_Status_Check    ${credentials}    ${Log}


*** Keywords ***
BGV_DT_Status_Check
    [Arguments]    ${credentials}    ${Log}

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
    FOR    ${row}    IN    @{result}
        ${Alldatas}    Create Dictionary
        ${num_columns}    Get Length    ${column_names}
        FOR    ${i}    IN RANGE    ${num_columns}
            Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
        END
        IF    "${Alldatas}[fuse_status_check]" != "" and "${Alldatas}[fuse_status_check]" != "None"
            ${Today_date}    Get Time
            ${TARGET_DATE}    Set Variable    ${Alldatas}[fuse_status_check]
            ${Today_date}    Set Variable    ${Today_date}[:10]
            ${Target_date}    Add Time To Date    ${TARGET_DATE}    2 days
            ${Target_date}    Set Variable    ${Target_date}[:10]
            ${difference}    Evaluate
            ...    (datetime.datetime.strptime('${Today_date}', '%Y-%m-%d') - datetime.datetime.strptime('${TARGET_DATE}'[:10], '%Y-%m-%d')).days
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
        Log To Console    ${Alldatas}[tech_first_name]=${Fuse_update_flag}
    END
