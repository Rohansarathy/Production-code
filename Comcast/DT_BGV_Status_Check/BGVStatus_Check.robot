*** Settings ***
Documentation       OnBoarding Process-Comcast BGV_Status_Check

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.JSON
Library             OperatingSystem
Library             DatabaseLibrary
Resource            BGVPDFExtract.robot
Resource            BGVStatusFuseupdate.robot
Resource            Killtask.robot
Resource            Fuselogin.robot
Library             Sendmail.py
Library             Teams_Pass.py
Library             Teams_Fail.py
Library             Collections


*** Variables ***
${doc}      ${EMPTY}
${Body1}    ${EMPTY}
${Body2}    ${EMPTY}


*** Keywords ***
BGVStatuscheck
    [Arguments]    ${Alldatas}    ${credentials}    ${BGV_PDF}    ${BGVLog}

    Log To Console    BGVStatuscheck_Start
    Append To File    ${BGVLog}    BGVStatuscheck_Start
    ${Firstname}    set variable    ${Alldatas}[first_name]
    ${Lastname}    Set Variable    ${Alldatas}[last_name]
    ${PC_Number}    Set Variable    ${Alldatas}[pc_number]
    # ${First_Name_Length}    Get Length    ${Alldatas}[first_name]
    # ${Last_Name_Length}    Get Length    ${Alldatas}[last_name]

    # ${Total_Length}    Evaluate    ${First_Name_Length}+${Last_Name_Length}+1

    ${PDF_exist}    Run Keyword And Return Status    File Should Exist    ${BGV_PDF}
    IF    ${PDF_exist} == True
        TRY
            ${BGV_IssuedDate1}    ${BGV_Request_ID}    ${BGV_IssuedDate}    BGVPDFExtract
            ...    ${Alldatas}
            ...    ${BGV_PDF}
            ...    ${BGVLog}
        EXCEPT
            Append To File    ${BGVLog}    Error occured while PDF extract.\n
            Log To Console    Error occured while PDF extract.
        END
        ${handles}    Get Window Titles
        Switch window    ${handles}[1]
        ${F_Login_}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="topicons"]/ul/li[5]/a
        ...    30s
        IF    ${F_Login_} == True
            Append To File    ${BGVLog}    Going for Fuse update.\n
            ${FuseUpdate_Flag}    BGVStatusFuseUpdate
            ...    ${Alldatas}
            ...    ${credentials}
            ...    ${BGV_PDF}
            ...    ${BGV_IssuedDate1}
            ...    ${BGVLog}
            ...    ${Firstname}
            ...    ${Lastname}
            IF    ${FuseUpdate_Flag} == False
                Append To File    ${BGVLog}    BGV status not updated in Fuse.\n
                ${Message}    set variable    BGV status not updated in Fuse for
                ${Teams}    Run Keyword And Return Status    Teamsfail    ${Firstname}    ${Lastname}    ${Message}
                IF    ${Teams} == True
                    Append To File    ${BGVLog}    Message sent for BGV status not updated in Fuse.\n
                    Log To Console    Message sent for BGV status not updated in Fuse
                ELSE
                    Append To File    ${BGVLog}    Message not sent for BGV status not updated in Fuse.\n
                    Log To Console    Message not sent for BGV status not updated in Fuse
                END
            END
            Execute Sql String
            ...    UPDATE onboarding SET bgv_requested_id = '${BGV_Request_ID}' WHERE SSN = '${Alldatas}[ssn]'
            Execute Sql String
            ...    UPDATE onboarding SET bgv_issued_date = '${BGV_IssuedDate}' WHERE SSN = '${Alldatas}[ssn]'

            ${Message}    set variable    BGV is <b>Cleared</b> for
            IF    "${Alldatas}[tax_term]" == "1099"
                ${Term}    Set Variable    ${Alldatas}[tax_term]| ${Alldatas}[company_name]
            ELSE
                ${Term}    Set Variable    ${Alldatas}[tax_term]
            END
            ${Teams}    Run Keyword And Return Status
            ...    Teamspass
            ...    ${Firstname}
            ...    ${Lastname}
            ...    ${Message}
            ...    ${PC_Number}
            ...    ${Term}
            IF    ${Teams} == True
                Append To File    ${BGVLog}    Message sent for BGV Cleared.\n
                Log To Console    Message sent for BGV Cleared
            ELSE
                Append To File    ${BGVLog}    Message not sent for BGV Cleared.\n
                Log To Console    Message not sent for BGV Cleared
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
            ${Body}    Set Variable
            ...    BGV is Cleared for ${Alldatas}[first_name] ${Alldatas}[last_name].
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
                    Append To File    ${BGVLog}    Mail sent for BGV Cleared.\n
                    Log To Console    Mail sent
                    Execute Sql String
                    ...    UPDATE onboarding SET bgv_status_mail_sent = 'Mail sent' WHERE SSN = '${Alldatas}[ssn]'
                ELSE
                    Append To File    ${BGVLog}    Mail not sent for BGV Cleared.\n
                    Log To Console    Mail not sent
                END
            Log To Console    BGV_IssuedDate1=${BGV_IssuedDate1},dt_status=${Alldatas}[dt_status]
            IF    "${Alldatas}[bgv_status]" == "completed" and "${BGV_IssuedDate1}" != "None"
                IF    "${Alldatas}[dt_status]" == "Negative" or "${Alldatas}[dt_status]" == "Positive" or "${Alldatas}[dt_status]" == "Positive Unable To Contact Donor"
                    Execute Sql String    UPDATE onboarding SET status = 'completed' WHERE SSN = '${Alldatas}[ssn]'
                    Append To File
                    ...    ${BGVLog}
                    ...    Initiation and Status check completed for ${Alldatas}[first_name]_${Alldatas}[last_name]\n
                    Log To Console
                    ...    Initiation and Status check completed for ${Alldatas}[first_name]_${Alldatas}[last_name]
                END
            END
        ELSE
            Append To File    ${BGVLog}    Fuse Login UnSuccessful.\n
            ${Recepients}    set variable    ${credentials}[ybotID]
            ${CC}    Set Variable
            ${Subject}    Set Variable    Fuse Login UnSuccessful-BGVstatusupdate
            ${Body}    Set Variable    Fuse Login UnSuccessful. Kindly check the issue.
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
                Append To File    ${BGVLog}    Mail sent for Fuse Login UnSuccessful.\n
                Log To Console    Mail sent for Fuse Login UnSuccessful
            ELSE
                Append To File    ${BGVLog}    Mail not sent for Fuse Login UnSuccessful.\n
                Log To Console    Mail not sent for Fuse Login UnSuccessful
            END
        END
    ELSE
        Append To File    ${BGVLog}    BGV Status PDF not found.\n
        Log To Console    BGV Status PDF not found.
        ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
        ${CC}    Set Variable    ${credentials}[ybotID]
        ${Subject}    Set Variable    BGV Status
        ${Body}    Set Variable
        ...    BGV Status PDF not found for ${Alldatas}[first_name]_${Alldatas}[last_name]. Kindly check the issue.
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
            Append To File    ${BGVLog}    Mail sent for BGV Status PDF not found.\n
            Log To Console    Mail sent for BGV Status PDF not found.
        ELSE
            Append To File    ${BGVLog}    Mail not sent for BGV Status PDF not found.\n
            Log To Console    Mail not sent for BGV Status PDF not found.
        END
        ${Message}    set variable    BGV Status PDF not found for
        ${Teams}    Run Keyword And Return Status    Teamsfail    ${Firstname}    ${Lastname}    ${Message}
        IF    ${Teams} == True
            Append To File    ${BGVLog}    Message sent for BGV Status PDF not found.\n
            Log To Console    Message sent for BGV Status PDF not found.
        ELSE
            Append To File    ${BGVLog}    Message not sent for BGV Status PDF not found.\n
            Log To Console    Message not sent for BGV Status PDF not found.
        END
    END
