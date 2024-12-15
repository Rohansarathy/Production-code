*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     DatabaseLibrary
Library     RPA.JSON
Resource    Killtask.robot
Resource    EScreen Login.robot
Resource    DTStatusPDFExtract.robot
Resource    DTExpired.robot
Library     Sendmail.py
Library     Collections

*** Tasks ***
Process
    DTstatuscheck


*** Keywords ***
DTStatusCheck
    #Vault
    ${credentials}    Load JSON from file    credentials2.json
    #Process Flow
    Connect To Database    psycopg2    ${credentials}[DB_NAME]    ${credentials}[DB_USERNAME]    ${credentials}[DB_PASSWORD]    ${credentials}[DB_HOST]    ${credentials}[DB_PORT]
    ${result}=    Query    SELECT * FROM public.onboarding where dt_status = 'Scheduled'
    FOR    ${Alldatas}    IN    @{result}
        ${Date1}    Get Time
        ${CurrentTime}    Set Variable    ${Date1}[11:13]
        Log To Console    T=${CurrentTime}
        ${Time2}    set variable    ${Alldatas}[36][11:13]
        Log To Console    I=${Time2}
        ${Initi_time}    Evaluate    ${Time2}+4
        Log To Console    ${Current_time}
        IF    ${Current_time} == ${Initi_time}
            Log To Console    Yes
        ELSE
            Log To Console    No
        END    

    END
