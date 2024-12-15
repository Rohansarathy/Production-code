*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     DatabaseLibrary
Resource    EScreen Login.robot
Resource    DTStatusPDFExtract.robot
Resource    DT&BGVStatus_update.robot
Resource    DTExpired.robot
Library     Sendmail.py


*** Keywords ***
DTStatusCheck
    [Arguments]
    ...    ${Alldatas}
    ...    ${credentials}
    ...    ${Epass_Path}
    ...    ${DTEpass_name}
    ...    ${doc}
    ...    ${Body1}
    ...    ${Body2}
    ...    ${DTLog}
    ...    ${BGVLog}

    Log To Console    DTStatuscheck_Start.
    Append To File    ${DTLog}    DTStatuscheck_Start.\n
    ${Firstname}    set variable    ${Alldatas}[first_name]
    ${Lastname}    Set Variable    ${Alldatas}[last_name]
    ${PC_Number}    Set Variable    ${Alldatas}[pc_number]
    TRY
        Click Element If Visible    //*[@id="service1"]/div
        Wait Until Element Is Visible    //*[@id="service1"]/ul/li[2]/a    10s
        Sleep    1s
        Click Element If Visible    //*[@id="service1"]/ul/li[2]/a
        Sleep    3s
        Select Frame    //*[@id="mainFrame"]
        Sleep    1s
        Wait Until Element Is Visible    //*[@id="txtConfirmationID"]    10s
    EXCEPT
        Click Element If Visible    //*[@id="service1"]/div
        Wait Until Element Is Visible    //*[@id="service1"]/ul/li[2]/a    10s
        Sleep    1s
        Click Element If Visible    //*[@id="service1"]/ul/li[2]/a
        Sleep    3s
        Select Frame    //*[@id="mainFrame"]
        Sleep    1s
        Wait Until Element Is Visible    //*[@id="txtConfirmationID"]    10s
    END

    Input Text When Element Is Visible    //*[@id="txtConfirmationID"]    ${Alldatas}[dt_confirmation_number]
    Sleep    1s
    Click Element If Visible    //*[@id="cmdSearch"]
    TRY
        Wait Until Element Is Visible    //*[@id="gridResults_ctl02_btnGetReport"]    10s
    EXCEPT
        Log To Console    Status tab Not found
    END
    ${Status}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="gridResults_ctl02_btnGetReport"]
    ...    20s
    IF    ${Status} == True
        ${DTStatus}    RPA.Browser.Selenium.Get Text    //*[@id="gridResults_ctl02_lblTrueStatus"]
        Unselect Frame
        IF    "${DTStatus}" == "Completed"
            Append To File    ${DTLog}    DTstatus1=${DTStatus}\n
            Log To Console    DTstatus1=${DTStatus}
            TRY
                Click Element If Visible    //*[@id="21"]/div
                Wait Until Element Is Visible    //*[@id="21"]/ul/li[1]/a    5s
                Click Element If Visible    //*[@id="21"]/ul/li[1]/a
                Sleep    1s
                Select Frame    //*[@id="mainFrame"]
                Sleep    1s
                Wait Until Element Is Visible    //*[@id="txtConfirmationID"]    10s
            EXCEPT
                Click Element If Visible    //*[@id="21"]/div
                Wait Until Element Is Visible    //*[@id="21"]/ul/li[1]/a    5s
                Click Element If Visible    //*[@id="21"]/ul/li[1]/a
                Sleep    1s
                Select Frame    //*[@id="mainFrame"]
                Sleep    1s
                Wait Until Element Is Visible    //*[@id="txtConfirmationID"]    10s
            END
            Input Text When Element Is Visible    //*[@id="txtConfirmationID"]    ${Alldatas}[dt_confirmation_number]
            Sleep    1s
            Click Element If Visible    //*[@id="btnSearch"]
            Sleep    1s
            TRY
                Wait Until Element Is Visible    //*[@id="esdgSummaryResults_ctl02_lbl_ResultStatus9"]    30s
                ${DTResult}    RPA.Browser.Selenium.Get Text    //*[@id="esdgSummaryResults_ctl02_lbl_ResultStatus9"]
                Sleep    1s
                IF    "${DTResult}" == "Negative" or "${DTResult}" == "Positive" or "${DTResult}" == "Positive Unable To Contact Donor" or "${DTResult}" == "Cancelled" or "${DTResult}" == "Refusal To Test" or "${DTResult}" == "Substituted"
                    Log To Console    DTResult4=${DTResult}
                    Append To File    ${DTLog}    DTResult4=${DTResult}\n
                    Log To Console    DTEpass_name=${DTEpass_name}
                    TRY
                        ${DtStatus}=    Run Keyword And Return Status    File Should Exist    ${DTEpass_name}
                        IF   ${DtStatus} == True
                            Remove File       ${DTEpass_name}
                            Log To Console    Existing Dt_Status File removed
                            Append To File    ${DTLog}    Existing Dt_Status File Removed\n
                        ELSE
                            Log To Console    Existing Dt_Status File not Found.
                            Append To File    ${DTLog}    Existing Dt_Status File not Found.\n
                        END                       
                    EXCEPT
                        Log To Console    Error occured while removing/checking existing DT_status file.
                        Append To File    ${DTLog}    Error occured while removing/checking existing DT_status file.\n
                    END
                    ${Time}    Get Time
                    Wait Until Element Is Visible    //*[@id="esdgSummaryResults_ctl02_btn_DonorName0"]    10s
                    Click Element If Visible    //*[@id="esdgSummaryResults_ctl02_btn_DonorName0"]
                    Sleep    2s
                    ${DTStatus_url}    Get Element Attribute    css=iframe[src]    src
                    Sleep    2s
                    RPA.Browser.Selenium.Go to    ${DTStatus_url}
                    Sleep    3s
                    RPA.Desktop.Press Keys    CTRL    s
                    Sleep    4s
                    RPA.Desktop.Type Text    ${DTEpass_name}
                    Sleep    2s
                    RPA.Desktop.Press Keys    Enter
                    Sleep    2s
                    TRY
                        RPA.Desktop.Press Keys    Tab
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    2s
                    EXCEPT
                        Log To Console    File downloaded
                    END
                    TRY
                        ${File_exist1}=    Run Keyword And Return Status    File Should Exist    ${DTEpass_name}
                        IF    ${File_exist1} != True
                            Append To File    ${DTLog}    Epassport ReDownload.\n
                            Log To Console    Epassport ReDownload.
                            RPA.Browser.Selenium.Go to    ${DTStatus_url}
                            Sleep    3s
                            ${handles}=    Get Window Titles
                            Switch window    ${handles}[0]
                            Sleep    1s
                            Capture Page Screenshot    ${Epass_Path}\\2.png
                            RPA.Desktop.Press Keys    CTRL    s
                            Sleep    2s
                            RPA.Desktop.Type Text    ${DTEpass_name}
                            Sleep    3s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                            TRY
                                RPA.Desktop.Press Keys    Tab
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    2s
                            EXCEPT
                                Log To Console    File downloaded
                            END
                            Sleep    2s
                            Go Back
                            sleep    5s
                        ELSE
                            Append To File    ${DTLog}    Epassport Downloaded.\n
                            Log To Console    Epassport Downloaded.
                        END
                    EXCEPT
                        Append To File    ${DTLog}    Epassport ReDownload failed.\n
                        Log To Console    Epassport ReDownload failed.
                    END
                    Go Back
                    Sleep    2s
                    DTStatuspdfextract
                    ...    ${Alldatas}
                    ...    ${credentials}
                    ...    ${DTEpass_name}
                    ...    ${DTResult}
                    ...    ${doc}
                    ...    ${Body1}
                    ...    ${Body2}
                    ...    ${DTLog}
                    ...    ${Firstname}
                    ...    ${Lastname}
                ELSE
                    Append To file    ${DTLog}    DTResult5=${DTResult}\n
                    Log To Console    DTResult5=${DTResult}
                    ${Time}    Get Time
                    IF    "${Time}[11:13]" >= "${credentials}[FuseUpdateTime]"
                        IF    "${Alldatas}[dt_status_time_check]" != "BGV_updated" and "${Alldatas}[dt_status_time_check]" != "DT_BGV_updated"
                            Log To Console    DT&BGV Status_update
                            Append To File
                            ...    ${BGVLog}
                            ...    @...............................................Technician=${Alldatas}[first_name]_${Alldatas}[last_name]-(${Alldatas}[mso])................................................\n
                            Append To file    ${DTLog}    DT&BGV Status_update\n
                            Append To File    ${BGVLog}    DT&BGV Status_update\n
                            DT&BGVStatus_update
                            ...    ${Alldatas}
                            ...    ${credentials}
                            ...    ${DTResult}
                            ...    ${DTLog}
                            ...    ${BGVLog}
                            ...    ${Firstname}
                            ...    ${Lastname}
                        END
                    END
                    IF    "${Alldatas}[dt_status]" != "${DTResult}"
                        ${Message}    set variable    DT status is <b>${DTResult}</b> for
                        IF    "${Alldatas}[tax_term]" == "1099"
                            ${Term}    Set Variable    ${Alldatas}[tax_term]|${Alldatas}[company_name]
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
                            Append To file    ${DTLog}    Message sent for DT status is ${DTResult}\n
                            Log To Console    Message sent for DT status is ${DTResult}
                        ELSE
                            Append To file    ${DTLog}    Message not sent for DT status is ${DTResult}\n
                            Log To Console    Message not sent for DT status is ${DTResult}
                        END
                        Execute Sql String
                        ...    UPDATE onboarding SET dt_status = '${DTResult}' WHERE SSN = '${Alldatas}[ssn]'
                    END
                END
            EXCEPT
                ${No_record}    RPA.Browser.Selenium.Get Text
                ...    //span[@id="esdgSummaryResults_ctl01_lbl_esdgSummaryResults_NoData"]
                Append To file    ${DTLog}    No Records Found in E-screen\n
                Log To Console    No Records Found in E-screen
                Execute Sql String
                ...    UPDATE onboarding SET dt_status = 'No Records Found' WHERE SSN = '${Alldatas}[ssn]'
            END
        ELSE
            IF    "${DTStatus}" == "Expired"
                Append To File    ${DTLog}    DTStatus2=${DTStatus}.\n
                Log To Console    DTStatus2=${DTStatus}
                ${Message}    set variable    DT is <b>missed/expired</b> for
                IF    "${Alldatas}[tax_term]" == "1099"
                    ${Term}    Set Variable    ${Alldatas}[tax_term]|${Alldatas}[company_name]
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
                    Append To File    ${DTLog}    Message sent for DT status is ${DTStatus}.\n
                    Log To Console    Message sent for DT status is ${DTStatus}
                ELSE
                    Append To File    ${DTLog}    Message sent for DT status is ${DTStatus}.\n
                    Log To Console    Message not sent for DT status is ${DTStatus}
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
                ...    DT missed/expired for ${Alldatas}[first_name] ${Alldatas}[last_name]. Hence removing applicant from process.
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
                        Append To File    ${DTLog}    Mail sent for DT is Expired.\n
                        Log To Console    Mail sent
                    ELSE
                        Append To File    ${DTLog}    Mail not sent for DT is Expired.\n
                        Log To Console    Mail not sent
                    END
                ${Time}    Get Time
                Log To Console    ${Time}
                Execute Sql String
                ...    UPDATE onboarding SET dt_status_received_date = '${Time}' WHERE SSN = '${Alldatas}[ssn]'
                Execute Sql String    UPDATE onboarding SET dt_status = 'Expired' WHERE SSN = '${Alldatas}[ssn]'
                # Execute Sql String    UPDATE onboarding SET status = 'Removed' WHERE SSN = '${Alldatas}[ssn]'
                DT_Expired
                ...    ${Alldatas}
                ...    ${credentials}
                ...    ${doc}
                ...    ${Body1}
                ...    ${Body2}
                ...    ${DTLog}
                ...    ${Firstname}
                ...    ${Lastname}
            ELSE
                Append To File    ${DTLog}    DTStatus3=${DTStatus}.\n
                Log To Console    DTStatus3=${DTStatus}
                ${Time}    Get Time
                IF    "${DTStatus}" != "Scheduled"
                    Execute Sql String
                    ...    UPDATE onboarding SET dt_status = '${DTStatus}' WHERE SSN = '${Alldatas}[ssn]'
                END
                IF    "${Time}[11:13]" >= "${credentials}[FuseUpdateTime]"
                    IF    "${Alldatas}[dt_status_time_check]" != "BGV_updated" and "${Alldatas}[dt_status_time_check]" != "DT_BGV_updated"
                        Log To Console    DT&BGV Status_update
                        Append To File
                        ...    ${BGVLog}
                        ...    @...............................................Technician=${Alldatas}[first_name]_${Alldatas}[last_name]-(${Alldatas}[mso])................................................\n
                        Append To File    ${DTLog}    DT&BGV Status_updating\n
                        Append To File    ${BGVLog}    DT&BGV Status_updating\n
                        ${DTResult}    Set Variable    ${DTStatus}
                        DT&BGVStatus_update
                        ...    ${Alldatas}
                        ...    ${credentials}
                        ...    ${DTResult}
                        ...    ${DTLog}
                        ...    ${BGVLog}
                        ...    ${Firstname}
                        ...    ${Lastname}
                    END
                END
                ${year}    Set Variable    ${Time}[0:4]
                ${month}    Set Variable    ${Time}[5:7]
                ${day}    Set Variable    ${Time}[8:10]
                ${month}    Evaluate    str(int("${month}"))
                ${day}    Evaluate    str(int("${day}"))
                ${Today_Date}    Set Variable    ${month}/${day}/${year}
                ${Date2}    Set Variable    ${Alldatas}[dt_eta]
                ${Ini_Date}    Set Variable    ${Date2}[0:9]
                IF    "${Ini_Date}" == "${Today_Date}" and "${Alldatas}[dt_status]" != "Remainder"
                   IF    "${Alldatas}[tax_term]" == "1099"
                   ${Term}    Set Variable    ${Alldatas}[tax_term]|${Alldatas}[company_name]
                   ELSE
                   ${Term}    Set Variable    ${Alldatas}[tax_term]
                   END
                   ${Message}    set variable    Mail sent for <b>DT remainder</b> for
                   ${Teams}    Run Keyword And Return Status    Teamspass    ${Firstname}    ${Lastname}    ${Message}    ${PC_Number}    ${Term}
                   IF    ${Teams} == True
                   Append To file    ${DTLog}    Message sent for DT remainder\n
                   Log To Console    Message sent for for DT remainder
                   ELSE
                   Append To file    ${DTLog}    Message not sent for DT remainder\n
                   Log To Console    Message not sent for DT remainder
                   END
                    ${Recepients}    set variable    ${Alldatas}[supplier_mail]
                    ${CC}    Set Variable
                    ...    ${Alldatas}[cc_recipients],${credentials}[ybotID]
                   IF    "${Alldatas}[tax_term]" == "1099"
                   ${Subject}    Set Variable
                   ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                   ELSE
                   ${Subject}    Set Variable
                   ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                   END
                   ${Body}    Set Variable
                   ...    This is to remind you that DT for ${Alldatas}[first_name] ${Alldatas}[last_name] will expire today.
                   ${Body1}    Set Variable    This order must be completed by:${Alldatas}[dt_eta]
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
                   Append To File    ${DTLog}    Mail sent for DT remainder.\n
                   Log To Console    Mail sent for DT remainder
                   ELSE
                   Append To File    ${DTLog}    Mail not sent for DT remainder.\n
                   Log To Console    Mail not sent for DT remainder
                   END
                   Append To File    ${DTLog}    ${Alldatas}[dt_eta]
                   Execute Sql String    UPDATE onboarding SET dt_status = 'Remainder' WHERE SSN = '${Alldatas}[ssn]'
                END
            END
        END
    ELSE
        Append To File    ${DTLog}    Not able to capture the status.\n
        Log To Console    Not able to capture the status.
    END
