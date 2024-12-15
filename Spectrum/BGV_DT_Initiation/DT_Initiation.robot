*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     String
Library     Collections
Library     OperatingSystem
Library     RPA.Desktop
Library     DatabaseLibrary


*** Variables ***
@{days}     Monday    Tuesday    Wednesday    Thursday    Friday


*** Keywords ***
DT Initiation
    [Arguments]    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Epass_name}    ${Log}

    Log To Console    *********************DT Initiation*********************
    Append To File    ${Log}    *********************DT Initiation***********************\n
    # ****REASON FOR TEST - DRUG TESTING****
    Log To Console    REASON FOR TEST - DRUG TESTING
    TRY
        Wait Until Element Is Visible    rdReason    40s
        Log To Console    rdReason found
        Append To File    ${Log}    rdReason found\n 
    EXCEPT
        Log To Console    rdReason not found
        Append To File    ${Log}    rdReason not found\n
        ${handles}    Get Window Titles
        Switch window    ${handles}[2]
        Sleep    2s
    END
    TRY
    Wait Until Element Is Visible    rdReason    30s
    Select Radio Button    rdReason    rdPreEmp
    Sleep    1s

    # ****TYPE OF TEST - DRUG TESTING****
    Wait Until Element Is Visible    //*[@id="chkService6"]    10s
    IF    "${Alldatas}[process]" == "renewal_dt"
        Click Element If Visible    //*[@id="chkService3"]
        Sleep    1s
        Select From List By Value    //*[@id="sel_Panels"]    1687
    ELSE
        Click Element If Visible    //*[@id="chkService6"]
    END

    # ****DONOR Details****
    ${Tech_Phone_No}=    Convert To String    ${Alldatas}[tech_phone_no]
    ${PH1}=    Get Substring    ${Tech_Phone_No}    0    3
    ${PH2}=    Get Substring    ${Tech_Phone_No}    3    6
    ${PH3}=    Get Substring    ${Tech_Phone_No}    6    10

    Input Text When Element Is Visible    //*[@id="txtAreaCodeUSeiDayPhone"]    ${PH1}
    Input Text When Element Is Visible    //*[@id="txtPrefixUSeiDayPhone"]    ${PH2}
    Input Text When Element Is Visible    //*[@id="txtStationCodeUSeiDayPhone"]    ${PH3}

    Click Element If Visible    //*[@id="cmdNext2"]
    Sleep    1s

    ${duplicates}=    RPA.Browser.Selenium.Get Text    //*[@id="lblTitle"]
    IF    "POSSIBLE DUPLICATES" == "${duplicates}"
        Execute Sql String
        ...    UPDATE onboarding SET dt_confirmation_number = 'POSSIBLE DUPLICATES' WHERE SSN = '${Alldatas}[ssn]'
        ${Duplicates_Flag}=    Set Variable    True
        ${Clinic_flag}=    Set Variable    False
        ${Clinic_flag2}=    Set Variable    False
        ${dt_error}    Set Variable    False
        RETURN    ${dt_error}    ${Duplicates_Flag}    ${Clinic_flag2}    ${Clinic_flag}
    ELSE
        ${Duplicates_Flag}=    Set Variable    False
        # ****Search for clinic****
        RPA.Browser.Selenium.Execute JavaScript    document.querySelector('#txtAddress').value = '';
        RPA.Browser.Selenium.Execute JavaScript    document.querySelector('#txtCity').value = '';
        Sleep    1s
        TRY
            Select From List By Index    //select[@name='ddlStateUSeiState']    0
            Log To Console    Index
            Append To File    ${Log}    Index\n
        EXCEPT
            Click Element If Visible    //select[@name='ddlStateUSeiState']
            Click Element If Visible    //*[@id="ddlStateUSeiState"]/option[1]
            Log To Console    Click
            Append To File    ${Log}    Click\n
        END

        ${clinic_zip_code}=    Strip String    ${Alldatas}[clinic_zip_code]
        Wait Until Element Is Visible    //*[@id="txtZipeiZipCode"]    30s
        Input Text When Element Is Visible    //*[@id="txtZipeiZipCode"]    ${clinic_zip_code}
        Input Text When Element Is Visible    //*[@id="txtDistanceUSeiDistance"]    ${credentials}[Distance]
        Click Element If Visible    //*[@id="cmdSearch"]
        Sleep    5s

        ${Clinic_search}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="pnlClinicExcellence"]
        ...    20s
        Append To File    ${Log}    Clinic_search=${Clinic_search}\n
        Log To Console    Clinic_search=${Clinic_search}
        IF    "${Clinic_search}" != "True"
            TRY
                ${notfound}=    RPA.Browser.Selenium.Get Text    //*[@id="lblNothingFound"]
                Log To Console    ${notfound}
                Append To File    ${Log}    ${notfound}\n
            EXCEPT
                Log To Console    Error
            END
            ${Clinic_flag2}=    Set Variable    False
            ${Clinic_flag}=    Set Variable    False
            ${dt_error}    Set Variable    False
            RETURN    ${dt_error}    ${Duplicates_Flag}    ${Clinic_flag2}    ${Clinic_flag}
        ELSE
            ${Clinic_flag2}=    Set Variable    True
            ${dt_error}    Set Variable    False
            # ****Checking the Clinic****
            Append To File    ${Log}    ****Checking the Clinic****\n
            Log To Console    ****Checking the Clinic****
            Wait Until Element Is Visible    //*[@id="pnlClinicExcellence"]    30s
            ${element_list}=    Get WebElements    //*[@id="searchResultTemplate"]
            ${element_count}=    Get Length    ${element_list}
            ${availableclinic}=    Evaluate    ${element_count}+1
            ${no}=    Set Variable    2
            Log To Console    clinic_index= ${availableclinic}
            FOR    ${clinic_index}    IN RANGE    1    ${availableclinic}
                ${int}=    Convert To Integer    ${no}
                IF    ${int} <= 9
                    ${ctl}=    Set Variable    ctl0${no}
                ELSE
                    ${ctl}=    Set Variable    ctl${no}
                END
                ${Clinicname}=    RPA.Browser.Selenium.Get Text    //*[@id="gvClinicResult_${ctl}_btnName"]
                Log To Console    ${Clinicname}
                ${GetMiles}=    RPA.Browser.Selenium.Get Text    //*[@id="gvClinicResult_${ctl}_lblDistance"]
                ${Miles}=    Split String    ${GetMiles}
                ${TechMiles}=    Get From List    ${Miles}    0
                Log To Console    ${TechMiles} > ${credentials}[Distance]
                IF    ${TechMiles} > ${credentials}[Distance]
                    ${MilesFlag}=    Set Variable    False
                ELSE
                    ${MilesFlag}=    Set Variable    True
                END
                TRY
                    ${GetWIA}=    RPA.Browser.Selenium.Get Text    //*[@id="gvClinicResult_${ctl}_lblWalk"]
                    IF    '${GetWIA}' != 'Walk-In allowed'
                        ${WIAFlag}=    Set Variable    False
                    ELSE
                        ${WIAFlag}=    Set Variable    True
                        Log To Console    Walk-In allowed
                    END
                EXCEPT
                    ${GetWIA}=    RPA.Browser.Selenium.Get Text    //*[@id="gvClinicResult_${ctl}_lblDrugWarning"]
                    ${WIAFlag}=    Set Variable    False
                END
                # ****Check for available Hours****
                Sleep    2s
                Log to Console    ****Check for available Hours****
                Click Element If Visible    (//*[text()='Show Details'])[${clinic_index}]
                Sleep    2s
                FOR    ${day}    IN    @{days}
                    ${hours}=    RPA.Browser.Selenium.Get Text    xpath=//*[@id="gvClinicResult_${ctl}_lbl${day}"]
                    ${class}=    Get Element Attribute    xpath=//*[@id="gvClinicResult_${ctl}_lbl${day}"]    class
                    ${contains_am}=    Run Keyword And Return Status    Should Contain    ${hours}    AM
                    ${contains_pm}=    Run Keyword And Return Status    Should Contain    ${hours}    PM
                    IF    '${contains_am}' == 'True' and '${contains_pm}' == 'True'
                        ${day}=    Set Variable    True
                    ELSE
                        ${day}=    Set Variable    False
                        BREAK
                    END
                END
                Log To Console    ${MilesFlag} == False or ${WIAFlag} == False or ${day} == False
                IF    ${MilesFlag} == False or ${WIAFlag} == False or ${day} == False
                    Sleep    2s
                    Click Element If Visible    (//*[text()='Hide Details'])[${clinic_index}]
                    Sleep    2s
                    ${Clinic_flag}=    Set Variable    False
                    ${no}=    Evaluate    ${int}+1
                    Log To Console    No=${no}
                ELSE
                    Append To File    ${Log}    Selecting the clinic-${Clinicname}.\n
                    Log To Console    *Selecting the clinic-${Clinicname}*
                    Click Element If Visible    //*[@id="gvClinicResult_${ctl}_btnName"]
                    Wait Until Element Is Visible    //*[@id="pnlCalculateTime"]    30s
                    ${Clinic_flag}=    Set Variable    True
                    BREAK
                END
            END

            IF    ${Clinic_flag} == True
                # # ****Confirm Schedule event****
                Input Text When Element Is Visible
                ...    //*[@id="spanMultipleEmaileiMultiEmailAddress"]
                ...    ${Alldatas}[supplier_mail];${Alldatas}[hr_coordinator];${credentials}[ybotID]

                Sleep    2s
                Click Element If Visible    //*[@id="cmdConfirm"]

                # ****PRINT ePASSPORT****
                Append To File    ${Log}    ****PRINT ePASSPORT****.\n
                Log To Console    ****PRINT ePASSPORT****

                Wait Until Element Is Visible    //*[@id="pnlPassportOptions"]    40s
                
                # ****EPassport mail Notification****
                TRY
                    Input Text When Element Is Visible    //*[@id="spanMultipleEmaileiMultiEmailAddress"]    ${Alldatas}[tech_mail_id];${Alldatas}[supplier_mail];${credentials}[ybotID]
                    Append To File    ${Log}    EPassport mail Notification sent.\n                
                EXCEPT
                    Append To File    ${Log}    EPassport mail Notification not sent.\n 
                END

                ${pdf_url}=    Get Element Attribute    css=iframe[src]    src
                Sleep    2s
                Select Checkbox    //*[@id="chkSendTextMessage"]
                Sleep    1s
                Input Text When Element Is Visible    //*[@id="txtAreaCodeUSeiCellPhone"]    ${PH1}
                Input Text When Element Is Visible    //*[@id="txtPrefixUSeiCellPhone"]    ${PH2}
                Input Text When Element Is Visible    //*[@id="txtStationCodeUSeiCellPhone"]    ${PH3}
                Sleep    1s
                Click Element If Visible    //*[@id="cmdSend"]
                Append To File    ${Log}    SMS send for tech.\n
                Sleep    1s
                RPA.Browser.Selenium.Go to    ${pdf_url}
                Sleep    4s
                Capture Page Screenshot    ${Epass_Path}\\1.png
                RPA.Desktop.Press Keys    CTRL    s
                Sleep    2s
                RPA.Desktop.Type Text    ${Epass_name}
                Sleep    4s
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
                Sleep    3s
                TRY
                    ${File_exist1}=    Run Keyword And Return Status    File Should Exist    ${Epass_name}
                    IF    ${File_exist1} != True
                        Append To File    ${Log}    Epassport ReDownload.\n
                        Log To Console    Epassport ReDownload.
                        RPA.Browser.Selenium.Go to    ${pdf_url}
                        Sleep    3s
                        Capture Page Screenshot    ${Epass_Path}\\2.png
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    2s
                        RPA.Desktop.Type Text    ${Epass_name}
                        Sleep    4s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    2s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    File Redownloaded
                        END
                        Sleep    2s
                    ELSE
                        Append To File    ${Log}    Epassport Downloaded.\n
                        Log To Console    Epassport Downloaded.
                    END
                EXCEPT
                    Append To File    ${Log}    Epassport ReDownload failed.\n
                    Log To Console    Epassport ReDownload failed.
                END
                ${dt_error}    Set Variable    False
            ELSE
                ${dt_error}    Set Variable    False
                ${Clinic_flag}=    Set Variable    False
                Append To File    ${Log}    Clinic not found.\n
                Log To Console    Clinic not found
                RETURN    ${dt_error}    ${Duplicates_Flag}    ${Clinic_flag}    ${Clinic_flag2}
            END
        END
        RETURN    ${dt_error}    ${Duplicates_Flag}    ${Clinic_flag}    ${Clinic_flag2}
    END
    EXCEPT
        ${dt_error}    Set Variable    True
        Append To File    ${Log}    Error occured while processing DT.\n
        Log To Console    Error occured while processing DT.
        RETURN    ${dt_error}    ${Duplicates_Flag}    ${Clinic_flag}    ${Clinic_flag2}
    END
