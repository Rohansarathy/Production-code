*** Settings ***
Documentation       COX_Onboarding Process-COX_DT_BGV_Satus_Check

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.JSON
Library             DatabaseLibrary
Library             Collections
Library             PDFExtract.py
Library             DateTime
Resource            Fuse_login.robot
Resource            FuseUpdate.robot


*** Variables ***
${doc}              ${EMPTY}
${Body1}            ${EMPTY}
${Body2}            ${EMPTY}
${Initi_time}       ${EMPTY}
${CC}               ${EMPTY}

${grade_level}       1
*** Tasks ***
Process
    BGV_DT_Status_Check


*** Keywords ***
BGV_DT_Status_Check
    # Vault
    ${credentials}    Load JSON from file    Infomart.json
    # Log File
    ${Time}    Get Time
    ${year}    Set Variable    ${Time}[0:4]
    ${month}    Set Variable    ${Time}[5:7]
    ${day}    Set Variable    ${Time}[8:10]
    ${mint}    Set Variable    ${Time}[11:13]
    ${Sec}    Set Variable    ${Time}[14:16]
    ${DTLog}    Set Variable    ${credentials}[Logfile]\\BGV&DT_Status_${day}${month}${year}_${mint}_${Sec}.txt

    Connect To Database
    ...    psycopg2
    ...    ${credentials}[DB_NAME]
    ...    ${credentials}[DB_USERNAME]
    ...    ${credentials}[DB_PASSWORD]
    ...    ${credentials}[DB_HOST]
    ...    ${credentials}[DB_PORT]
    Log To Console    DB Connected
    # Get column names
    ${columns}    Query
    ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'cox_onboarding' AND table_schema = 'public'

    @{column_names}    Create List
    FOR    ${col}    IN    @{columns}
        Append To List    ${column_names}    ${col}[0]
    END
    # Get data rows
    ${result}    Query    SELECT * FROM public.cox_onboarding WHERE ssn = '259926143'
    # ${result}    Query    SELECT * FROM public.cox_onboarding WHERE ssn = '376217538'
    FOR    ${row}    IN    @{result}
        ${Alldatas}    Create Dictionary
        ${num_columns}    Get Length    ${column_names}
        FOR    ${i}    IN RANGE    ${num_columns}
            Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
        END
        ${Today_date}    Get Time
        ${Recepients}=    set variable    ${credentials}[Recipient]
        ${CC}=    set variable    ${credentials}[Recipient]
        ${Attachment}=    Set Variable    ${doc}
        # Log To Console    Attachment=${Attachment}
        IF    "${Alldatas}[tax_term]" == "1099"
            ${Subject}=    Set Variable
            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
        ELSE
             ${Subject}=    Set Variable
            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
        END
        # ${Body}=    Set Variable    
        # ...  Profile Status Process is completed for "${Alldatas}[first_name] ${Alldatas}[last_name]". Kindly check.
        # ...  Grade:LEVEL-${grade_level}
        ${Body}    Set Variable
        ...   Profile Status Process is completed for "<mark>${Alldatas}[first_name] ${Alldatas}[last_name]</mark>".\nGrade: LEVEL-${grade_level}
        ${Mailsent}=    Run Keyword And Return Status
        ...    Sendmail
        ...    ${Recepients}
        ...    ${CC}
        ...    ${Subject}
        ...    ${Body}
        ...    ${Attachment}
    END
