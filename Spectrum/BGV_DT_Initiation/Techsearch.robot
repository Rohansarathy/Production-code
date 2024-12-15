*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem
Library     String
Library     Sendmail


*** Variables ***
${expected_text}    No data available in table
${Fullname}         ${EMPTY}
${First}            ${EMPTY}
${Last}             ${EMPTY}
${AllFullname}      ${EMPTY}
${doc}              ${EMPTY}
${Body1}            ${EMPTY}
${Body2}            ${EMPTY}
${CC}               ${EMPTY}

*** Keywords ***
Techsearch
    [Arguments]    ${Alldatas}    ${credentials}    ${Log}

    ${handles}=    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    1s
    TRY
        ${Popup_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    3s
        IF    '${Popup_exists} == True'
            Click Element If Visible    //*[@id="update_frm"]/div/div/h2/div[3]/label/div
            Sleep    2s
            Handle Alert    ACCEPT
            Sleep    1s
            TRY
                Click Element If Visible    //*[@id="example_main_notification"]/tbody/tr/td[4]/div/a
            EXCEPT
                Log To Console    Popup closed
            END
        END
    EXCEPT
        Log To Console    Popup not found
    END
    ${F_Login_}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="myNavbar"]/ul/li[3]/a
    ...    5s
    Log To Console    ${F_Login_}
    IF    ${F_Login_} == True
        ${Firstname}=    Strip String    ${Alldatas}[tech_first_name]
        ${Lastname}=    Strip String    ${Alldatas}[tech_last_name]
        ${first_name}=    Convert To Lower Case    ${Firstname}
        ${last_name}=    Convert To Lower Case    ${Lastname}
        ${db_full_name}=    Set Variable    ${first_name} ${last_name}
        ${Timing}=    Get Time
        IF    "${Alldatas}[tax_term]" == "1099"
            Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[8]/a    5s
            Click Element If Visible    //*[@id="myNavbar"]/ul/li[8]/a
            Wait Until Element Is Visible    //li/a[@href='/onb/contractor_recruiting.php']    5s
            Click Element If Visible    //li/a[@href='/onb/contractor_recruiting.php']
            TRY
                ${Popup_exists}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    3s
                IF    '${Popup_exists} == True'
                    Click Element If Visible    //*[@id="update_frm"]/div/div/h2/div[3]/label/div
                    Sleep    2s
                    Handle Alert    ACCEPT
                    Sleep    1s
                    TRY
                        Click Element If Visible    //*[@id="example_main_notification"]/tbody/tr/td[4]/div/a
                    EXCEPT
                        Log To Console    Popup closed
                    END
                END
            EXCEPT
                Log To Console    Popup not found
            END
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    3s
            Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
            Input Text
            ...    //*[@id="exampleRecruits_filter"]/label/input
            ...    ${db_full_name}
            Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
            Click Button    //*[@id="refresh_dt"]
            Sleep    5s
            ${row_index}=    Set Variable    ${EMPTY}
            ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
            FOR    ${index}    IN RANGE    1    ${row_count+1}
                TRY
                    ${Tech11}=    RPA.Browser.Selenium.Get Text
                    ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[6]
                    ${Tech1}=    Strip String    ${Tech11}
                    ${Tech22}=    RPA.Browser.Selenium.Get Text
                    ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[5]
                    ${Tech2}=    Strip String    ${Tech22}
                    ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                    ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                    ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                    Log To Console    Name:'${full_name}' == '${db_full_name}'
                    Append To File
                    ...    ${Log}
                    ...    Name: '${full_name}' == '${db_full_name}'\n
                    IF    '${full_name}' == '${db_full_name}'
                        ${row_index}=    Set Variable    ${index}
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            IF    '${value}' == 'D/B Check'
                                IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                    Click Element If Visible
                                    ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                END
                                ${Fullname}=    Set Variable    True
                                BREAK
                            END
                    ELSE
                        ${Fullname}=    Set Variable    False
                    END
                EXCEPT
                    ${Fullname}=    Set Variable    False
                END
            END
            IF    "${Fullname}" == "False"
                Log To Console    Fullname=${Fullname}
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    5s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                FOR    ${index}    IN RANGE    1    ${row_count+1}
                    TRY
                        ${Tech11}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[6]
                        ${Tech1}=    Strip String    ${Tech11}
                        ${Tech22}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[5]
                        ${Tech2}=    Strip String    ${Tech22}
                        ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                        ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                        ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                        Log To Console    Name: '${full_name}' == '${db_full_name}'
                        Append To File
                        ...    ${Log}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}  
                                Wait Until Element Is Visible
                                    ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                    ...    5s
                                    ${element}=    Get WebElement
                                    ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                    ${value}=    Get Element Attribute    ${element}    value
                                    Log To Console    Value Attribute: ${value}
                                    Append To File    ${Log}    Value Attribute: ${value}\n
                                    IF    '${value}' == 'D/B Check'
                                        IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                            Click Element If Visible
                                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                        END
                                        ${First}=    Set Variable    True
                                        BREAK
                                    END
                        ELSE
                            ${First}=    Set Variable    False
                        END
                    EXCEPT
                        ${First}=    Set Variable    False
                    END
                END
            END
            IF    "${First}" == "False"
                Log To Console    First=${First}
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    5s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                FOR    ${index}    IN RANGE    1    ${row_count+1}
                    TRY
                        ${Tech11}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[6]
                        ${Tech1}=    Strip String    ${Tech11}
                        ${Tech22}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[5]
                        ${Tech2}=    Strip String    ${Tech22}
                        ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                        ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                        ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                        Log To Console    Name: '${full_name}' == '${db_full_name}'
                        Append To File
                        ...    ${Log}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                                Wait Until Element Is Visible
                                ...    //*[@id="exampleRecruits"]/tbody/tr[${row_index}]/td[4]
                                ...    5s
                                Wait Until Element Is Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ...    5s
                                ${element}=    Get WebElement
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${value}=    Get Element Attribute    ${element}    value
                                Log To Console    Value Attribute: ${value}
                                Append To File    ${Log}    Value Attribute: ${value}\n
                                IF    '${value}' == 'D/B Check'
                                    IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                        Click Element If Visible
                                        ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                    END
                                    ${Last}=    Set Variable    True
                                    BREAK
                                END
                        ELSE
                            ${Last}=    Set Variable    False
                        END
                    EXCEPT
                        ${Last}=    Set Variable    False
                    END
                END
            END
            IF    "${Last}" == "False"
                # All Process
                Click Element If Visible    //*[@id="frm_filter_data"]/div[4]/span/label/div
                Sleep    4s
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Input Text
                ...    //*[@id="exampleRecruits_filter"]/label/input
                ...    ${db_full_name}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    5s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                FOR    ${index}    IN RANGE    1    ${row_count+1}
                    TRY
                        ${Tech11}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[6]
                        ${Tech1}=    Strip String    ${Tech11}
                        ${Tech22}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleRecruits']/tbody/tr[${index}]/td[5]
                        ${Tech2}=    Strip String    ${Tech22}
                        ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                        ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                        ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                        Log To Console    Name: '${full_name}' == '${db_full_name}'
                        Append To File
                        ...    ${Log}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                                Wait Until Element Is Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ...    5s
                                ${element}=    Get WebElement
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${value}=    Get Element Attribute    ${element}    value
                                Log To Console    Value Attribute: ${value}
                                Append To File    ${Log}    Value Attribute: ${value}\n
                                IF    '${value}' == 'D/B Check'
                                    IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                        Click Element If Visible
                                        ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                    END
                                    ${AllFullname}=    Set Variable    True
                                    BREAK
                                END
                        ELSE
                            ${AllFullname}=    Set Variable    False
                        END
                    EXCEPT
                        ${AllFullname}=    Set Variable    False
                    END
                END
            END
        ELSE
            Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[8]/a    5s
            Click Element If Visible    //*[@id="myNavbar"]/ul/li[8]/a
            Wait Until Element Is Visible   (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7]    5s
            Click Element If Visible   (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7]
            TRY
                ${Popup_exists}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    3s
                IF    '${Popup_exists} == True'
                    Click Element If Visible    //*[@id="update_frm"]/div/div/h2/div[3]/label/div
                    Sleep    2s
                    Handle Alert    ACCEPT
                    Sleep    1s
                    TRY
                        Click Element If Visible    //*[@id="example_main_notification"]/tbody/tr/td[4]/div/a
                    EXCEPT
                        Log To Console    Popup closed
                    END
                END
            EXCEPT
                Log To Console    Popup not found
            END
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    3s
            Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
            Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
            Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
            Click Button    (//*[@id="refresh_dt"])[1]
            Sleep    5s
            ${row_index}=    Set Variable    ${EMPTY}
            ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
            FOR    ${index}    IN RANGE    1    ${row_count+1}
                TRY
                    ${Tech11}=    RPA.Browser.Selenium.Get Text
                    ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[6]
                    ${Tech1}=    Strip String    ${Tech11}
                    ${Tech22}=    RPA.Browser.Selenium.Get Text
                    ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[5]
                    ${Tech2}=    Strip String    ${Tech22}
                    ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                    ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                    ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                    Log To Console    Name: '${full_name}' == '${db_full_name}'
                    Append To File
                    ...    ${Log}
                    ...    Name: '${full_name}' == '${db_full_name}'\n
                    IF    '${full_name}' == '${db_full_name}'
                        ${row_index}=    Set Variable    ${index}
                        Wait Until Element Is Visible
                        ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                        ...    5s
                        ${element}=    Get WebElement
                        ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                        ${value}=    Get Element Attribute    ${element}    value
                        IF    '${value}' == 'D/B Check'
                            IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                Click Element If Visible
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            END
                            ${Fullname}=    Set Variable    True
                            BREAK
                        END
                    ELSE
                        ${Fullname}=    Set Variable    False
                    END
                EXCEPT
                    ${Fullname}=    Set Variable    False
                END
            END
            IF    "${Fullname}" == "False"
                Log To Console    Fullname=${Fullname}
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
                Click Button    (//*[@id="refresh_dt"])[1]
                Sleep    5s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
                FOR    ${index}    IN RANGE    1    ${row_count+1}
                    TRY
                        ${Tech11}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[6]
                        ${Tech1}=    Strip String    ${Tech11}
                        ${Tech22}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[5]
                        ${Tech2}=    Strip String    ${Tech22}
                        ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                        ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                        ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                        Log To Console    Name: '${full_name}' == '${db_full_name}'
                        Append To File
                        ...    ${Log}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            IF    '${value}' == 'D/B Check'
                                IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                    Click Element If Visible
                                    ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                END
                                ${First}=    Set Variable    True
                                BREAK
                            END
                        ELSE
                            ${First}=    Set Variable    False
                        END
                    EXCEPT
                        ${First}=    Set Variable    False
                    END
                END
            END
            IF    "${First}" == "False"
                Log To Console    First=${First}
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
                Click Button    (//*[@id="refresh_dt"])[1]
                Sleep    5s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
                FOR    ${index}    IN RANGE    1    ${row_count+1}
                    TRY
                        ${Tech11}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[6]
                        ${Tech1}=    Strip String    ${Tech11}
                        ${Tech22}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[5]
                        ${Tech2}=    Strip String    ${Tech22}
                        ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                        ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                        ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                        Log To Console    Name: '${full_name}' == '${db_full_name}'
                        Append To File
                        ...    ${Log}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            IF    '${value}' == 'D/B Check'
                                IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                    Click Element If Visible
                                    ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                END
                                ${Last}=    Set Variable    True
                                BREAK
                            END
                        ELSE
                            ${Last}=    Set Variable    False
                        END
                    EXCEPT
                        ${Last}=    Set Variable    False
                    END
                END
            END
            IF    "${Last}" == "False"
                # All Process
                Click Element If Visible    //*[@id="frm_filter_data"]/div[4]/span/label/div
                Sleep    4s
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
                Click Button    (//*[@id="refresh_dt"])[1]
                Sleep    5s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
                FOR    ${index}    IN RANGE    1    ${row_count+1}
                    TRY
                        ${Tech11}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[6]
                        ${Tech1}=    Strip String    ${Tech11}
                        ${Tech22}=    RPA.Browser.Selenium.Get Text
                        ...    //table[@id='exampleImport']/tbody/tr[${index}]/td[5]
                        ${Tech2}=    Strip String    ${Tech22}
                        ${First_Tech1}=    Convert To Lower Case    ${Tech1}
                        ${Last_Tech2}=    Convert To Lower Case    ${Tech2}
                        ${full_name}=    Set Variable    ${First_Tech1} ${Last_Tech2}
                        Log To Console    Name: '${full_name}' == '${db_full_name}'
                        Append To File
                        ...    ${Log}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            IF    '${value}' == 'D/B Check'
                                IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                    Click Element If Visible
                                    ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                END
                                ${AllFullname}=    Set Variable    True
                                BREAK
                            END
                        ELSE
                            ${AllFullname}=    Set Variable    False
                        END
                    EXCEPT
                        ${AllFullname}=    Set Variable    False
                    END
                END
            END
        END
        IF    "${AllFullname}" == "False"
            Log To Console    Tech not found for Fuse update
            Append To File    ${Log}    Tech not found in Fuse update.\n
            ${Tech_found_flag}    Set Variable    False
            ${Recepients}=    set variable    ${credentials}[ybotID]
            IF    "${Alldatas}[tax_term]" == "1099"
                ${Subject}=    Set Variable
                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
            ELSE
                ${Subject}=    Set Variable
                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
            END
            ${Subject}=    Set Variable
            ...    Tech not found in Fuse update,
            ${Body}=    Set Variable
            ...    Technician not found, Bot didn't updated DT&BGV Initiation details in Fuse. Kindly check.
            ${Attachment}=    Set Variable    ${doc}
            ${Mailsent}=    Run Keyword And Return Status
            ...    Sendmail
            ...    ${Recepients}
            ...    ${CC}
            ...    ${Subject}
            ...    ${Body}
            ...    ${Body1}
            ...    ${Body2}
            ...    ${Attachment}
            IF    ${Mailsent} == True
                Append To file    ${Log}    Mail sent for Tech not found.\n
                Log To Console    Mail sent
            ELSE
                Append To file    ${Log}    Mail not sent for Tech not found.\n
                Log To Console    Mail not sent
            END
        ELSE
            ${Tech_found_flag}    Set Variable    True
        END
        RETURN    ${Tech_found_flag}
    ELSE
        Append To File    ${Log}    Fuse application not found for Tech search \n
        Log To Console    Fuse application not found for Tech search
    END