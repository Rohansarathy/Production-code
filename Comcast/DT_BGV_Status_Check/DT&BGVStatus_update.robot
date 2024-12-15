*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     DatabaseLibrary
Library     OperatingSystem
Library     Teams_Fail.py
Library     String
Library    Sendmail


*** Variables ***
${Fullname}         ${EMPTY}
${First}            ${EMPTY}
${Last}             ${EMPTY}
${AllFullname}      ${EMPTY}
${doc}              ${EMPTY}
${Body1}            ${EMPTY}
${Body2}            ${EMPTY}


*** Keywords ***
DT&BGVStatus_update
    [Arguments]
    ...    ${Alldatas}
    ...    ${credentials}
    ...    ${DTResult}
    ...    ${DTLog}
    ...    ${BGVLog}
    ...    ${Firstname}
    ...    ${Lastname}

    ${handles}=    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    TRY
        ${Popup_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    3s
        IF    '${Popup_exists} == True'
            Click Element If Visible    //*[@id="update_frm"]/div/div/h2/div[3]/label/div
            Sleep    1s
            Handle Alert    ACCEPT
            Sleep    1s
            TRY
                Click Element If Visible    //*[@id="example_main_notification"]/tbody/tr/td[4]/div/a
            EXCEPT
                Log To Console    Popup closed
                Append To File    ${DTLog}    Popup closed\n
            END
        END
    EXCEPT
        Log To Console    Popup not found
        Append To File    ${DTLog}    Popup closed\n
    END
    ${F_Login_}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="topicons"]/ul/li[5]/a
    ...    10s
    IF    ${F_Login_} == True
        ${Firstname}=    Strip String    ${Alldatas}[first_name]
        ${Lastname}=    Strip String    ${Alldatas}[last_name]
        ${first_name}=    Convert To Lower Case    ${Firstname}
        IF    "${Alldatas}[suffix]" != "" and "${Alldatas}[suffix]" != "None" and "${Alldatas}[suffix]" != " " and "${Alldatas}[suffix]" != "none"
            ${suffix}    Set Variable    ${Alldatas}[suffix]
            ${last_name}=    Convert To Lower Case    ${Lastname} ${suffix}
        ELSE
            ${last_name}=    Convert To Lower Case    ${Lastname}
        END
        ${db_full_name}=    Set Variable    ${first_name} ${last_name}
        Append To File    ${DTLog}    Searching the Tech\n
        ${Timing}=    Get Time
        TRY
            ${Popup_exists}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    3s
            IF    '${Popup_exists} == True'
                Click Element If Visible    //*[@id="update_frm"]/div/div/h2/div[3]/label/div
                Sleep    1s
                Handle Alert    ACCEPT
                Sleep    1s
                TRY
                    Click Element If Visible    //*[@id="example_main_notification"]/tbody/tr/td[4]/div/a
                EXCEPT
                    Log To Console    Popup closed
                    Append To File    ${DTLog}    Popup closed\n
                END
            END
        EXCEPT
            Log To Console    Popup not found
            Append To File    ${DTLog}    Popup closed\n
        END
        IF    "${Alldatas}[tax_term]" == "1099"
            Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[8]/a    5s
            Click Element If Visible    //*[@id="myNavbar"]/ul/li[8]/a
            Wait Until Element Is Visible    //li/a[@href='/onb/contractor_recruiting.php']    5s
            Click Element If Visible    //li/a[@href='/onb/contractor_recruiting.php']
            Sleep    2s
            Append To File    ${DTLog}    Cheking for popup\n
            TRY
                ${Popup_exists}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    5s
                IF    '${Popup_exists} == True'
                    Click Element If Visible    //*[@id="update_frm"]/div/div/h2/div[3]/label/div
                    Sleep    1s
                    Handle Alert    ACCEPT
                    Sleep    1s
                    TRY
                        Click Element If Visible    //*[@id="example_main_notification"]/tbody/tr/td[4]/div/a
                    EXCEPT
                        Log To Console    Popup closed
                        Append To File    ${DTLog}    Popup closed\n
                    END
                END
            EXCEPT
                Log To Console    Popup not found
                Append To File    ${DTLog}    Popup closed\n
            END
            # In Process
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    6s
            Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
            Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
            Input Text
            ...    //*[@id="exampleRecruits_filter"]/label/input
            ...    ${db_full_name}
            Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
            Click Element    //*[@id="refresh_dt"]
            Sleep    7s
            ${row_index}=    Set Variable    ${EMPTY}
            ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
            Log To Console    Row Count: ${row_count}
            Append To File    ${DTLog}    Row Count: ${row_count}\n
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
                    ...    ${DTLog}
                    ...    Name: '${full_name}' == '${db_full_name}'\n
                    IF    '${full_name}' == '${db_full_name}'
                        ${row_index}=    Set Variable    ${index}
                        Log To Console    Matching Row Index: ${row_index}
                        Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                        # ${Date}=    RPA.Browser.Selenium.Get Text
                        # ...    //*[@id="exampleRecruits"]/tbody/tr[${row_index}]/td[4]
                        # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                        Wait Until Element Is Visible
                        ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                        ...    5s
                        ${element}=    Get WebElement
                        ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                        ${value}=    Get Element Attribute    ${element}    value
                        Log To Console    Value Attribute: ${value}
                        Append To File    ${DTLog}    Value Attribute: ${value}\n
                        IF    '${value}' == 'D/B Check'
                            Click Element If Visible
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${Fullname}=    Set Variable    True
                            BREAK
                        END
                        # END
                    ELSE
                        ${Fullname}=    Set Variable    False
                    END
                EXCEPT
                    ${Fullname}=    Set Variable    False
                END
            END
            IF    "${Fullname}" == "False"
                Log To Console    Fullname=${Fullname}
                Append To File    ${DTLog}    Fullname=${Fullname}\n
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Element    //*[@id="refresh_dt"]
                Sleep    7s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                Log To Console    Row Count: ${row_count}
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
                        ...    ${DTLog}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                            # ${Date}=    RPA.Browser.Selenium.Get Text
                            # ...    //*[@id="exampleRecruits"]/tbody/tr[${row_index}]/td[4]
                            # Log To Console    ${Date}[6:10]
                            # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${DTLog}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${First}=    Set Variable    True
                                BREAK
                            END
                            # END
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
                Append To File    ${DTLog}    First=${First}\n
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Element    //*[@id="refresh_dt"]
                Sleep    7s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                Log To Console    Row Count: ${row_count}
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
                        ...    ${DTLog}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                            # Wait Until Element Is Visible
                            # ...    //*[@id="exampleRecruits"]/tbody/tr[${row_index}]/td[4]
                            # ...    5s
                            # ${Date}=    RPA.Browser.Selenium.Get Text
                            # ...    //*[@id="exampleRecruits"]/tbody/tr[${row_index}]/td[4]
                            # Log To Console    ${Date}[6:10]
                            # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${DTLog}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${Last}=    Set Variable    True
                                BREAK
                            END
                            # END
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
                Sleep    6s
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                Input Text
                ...    //*[@id="exampleRecruits_filter"]/label/input
                ...    ${db_full_name}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Element    //*[@id="refresh_dt"]
                Sleep    7s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                Log To Console    Row Count: ${row_count}
                Append To File    ${DTLog}    Row Count: ${row_count}\n
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
                        ...    ${DTLog}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                            # ${Date}=    RPA.Browser.Selenium.Get Text
                            # ...    //*[@id="exampleRecruits"]/tbody/tr[${row_index}]/td[4]
                            # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${DTLog}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${AllFullname}=    Set Variable    True
                                BREAK
                            END
                            # END
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
            Wait Until Element Is Visible    (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7]    5s
            Click Element If Visible    (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7]
            Sleep    2s
            Append To File    ${DTLog}    Cheking for popup\n
            TRY
                ${Popup_exists}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    5s
                IF    '${Popup_exists} == True'
                    Click Element If Visible    //*[@id="update_frm"]/div/div/h2/div[3]/label/div
                    Sleep    1s
                    Handle Alert    ACCEPT
                    Sleep    1s
                    TRY
                        Click Element If Visible    //*[@id="example_main_notification"]/tbody/tr/td[4]/div/a
                    EXCEPT
                        Log To Console    Popup closed
                        Append To File    ${DTLog}    Popup closed\n
                    END
                END
            EXCEPT
                Log To Console    Popup not found
                Append To File    ${DTLog}    Popup closed\n
            END
            # In Process
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    7s
            Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
            Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
            Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
            Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
            Click Element    (//*[@id="refresh_dt"])[1]
            Sleep    10s
            ${row_index}=    Set Variable    ${EMPTY}
            ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
            Log To Console    Row Count: ${row_count}
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
                    ...    ${DTLog}
                    ...    Name: '${full_name}' == '${db_full_name}'\n
                    IF    '${full_name}' == '${db_full_name}'
                        ${row_index}=    Set Variable    ${index}
                        Log To Console    Matching Row Index: ${row_index}
                        Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                        # ${Date}=    RPA.Browser.Selenium.Get Text
                        # ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[4]
                        # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                        Wait Until Element Is Visible
                        ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                        ...    5s
                        ${element}=    Get WebElement
                        ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                        ${value}=    Get Element Attribute    ${element}    value
                        Log To Console    Value Attribute: ${value}
                        Append To File    ${DTLog}    Value Attribute: ${value}\n
                        IF    '${value}' == 'D/B Check'
                            Click Element If Visible
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${Fullname}=    Set Variable    True
                            BREAK
                        END
                        # END
                    ELSE
                        ${Fullname}=    Set Variable    False
                    END
                EXCEPT
                    ${Fullname}=    Set Variable    False
                END
            END
            IF    "${Fullname}" == "False"
                Log To Console    Fullname=${Fullname}
                Append To File    ${DTLog}    Fullname=${Fullname}\n
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Click Element    (//*[@id="refresh_dt"])[1]
                Sleep    10s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
                Log To Console    Row Count: ${row_count}
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
                        ...    ${DTLog}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                            # ${Date}=    RPA.Browser.Selenium.Get Text
                            # ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[4]
                            # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                            Wait Until Element Is Visible
                            ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${DTLog}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${First}=    Set Variable    True
                                BREAK
                            END
                            # END
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
                Append To File    ${DTLog}    First=${First}\n
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Click Element    (//*[@id="refresh_dt"])[1]
                Sleep    10s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
                Log To Console    Row Count: ${row_count}
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
                        ...    ${DTLog}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                            # ${Date}=    RPA.Browser.Selenium.Get Text
                            # ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[4]
                            # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                            Wait Until Element Is Visible
                            ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${DTLog}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${Last}=    Set Variable    True
                                BREAK
                            END
                            # END
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
                Sleep    7s
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Click Element    (//*[@id="refresh_dt"])[1]
                Sleep    10s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleImport']/tbody/tr
                Log To Console    Row Count: ${row_count}
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
                        ...    ${DTLog}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${DTLog}    Matching Row Index: ${row_index}\n
                            # ${Date}=    RPA.Browser.Selenium.Get Text
                            # ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[4]
                            # IF    "${Timing}[0:4]" == "${Date}[6:10]"
                            Wait Until Element Is Visible
                            ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${DTLog}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${AllFullname}=    Set Variable    True
                                BREAK
                            END
                            # END
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
            Log To Console    Tech not found in Fuse update
            Append To File    ${DTLog}    Tech not found in Fuse update.\n
            ${Body}=    Set Variable
            ...    Bot failed to update the DT status#(${DTResult}) in Fuse due to Tech Name mismatch for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly update Manually.
            ${Recepients}=    set variable    ${Alldatas}[hr_coordinator]
            ${CC}=    Set Variable    ${credentials}[ybotID]
            ${Attachment}=    Set Variable    ${doc}
            IF    "${Alldatas}[tax_term]" == "1099"
                ${Subject}=    Set Variable
                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
            ELSE
                ${Subject}=    Set Variable
                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
            END
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
                Append To file    ${DTLog}    Mail sent for DT status not Updated in Fuse.\n
                Log To Console    Mail sent not Updated in Fuse
            ELSE
                Append To file    ${DTLog}    Mail not sent for DT status not Updated in Fuse.\n
                Log To Console    Mail not sent not Updated in Fuse
            END
        END

        # Notes Update
        IF    "${Alldatas}[tax_term]" == "w2"
            IF    "${Alldatas}[dt_status]" == "Scheduled" or "${Alldatas}[dt_status]" == "Sent To Lab" or "${Alldatas}[dt_status]" == "Received At Lab" or "${Alldatas}[dt_status]" == "In Process With MRO" or "${Alldatas}[dt_status]" == "Remainder" or "${Alldatas}[dt_status]" == "In Process" or "${Alldatas}[dt_status]" == "Waiting"
                Input Text When Element Is Visible    //*[@id="notes"]    DTpending#(${DTResult}) with Escreen 
                Sleep    1s
                Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                Sleep    1s
            END
            IF    "${Alldatas}[dt_status_time_check]" != "BGV_updated" and "${Alldatas}[dt_status_time_check]" != "DT_BGV_updated"
                IF    "${Alldatas}[bgv_status]" == "pending"
                    Input Text When Element Is Visible    //*[@id="notes"]    BGV pending with HireRight
                    Sleep    1s
                    Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                    Sleep    1s
                END
            END
            # Submit
            Append To File    ${DTLog}    Click Submit.\n
            IF    "${Alldatas}[bgv_status]" == "pending"
                Append To File    ${BGVLog}    Click Submit.\n
            END
            Wait Until Element Is Visible
            ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
            ...    30s
            Click Element If Visible    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
            Sleep    2s
            TRY
                Handle Alert    ACCEPT
                Sleep    2s
            EXCEPT
                Log To Console    Pop closed
                Append To File    ${DTLog}    Fuse Submitted.\n
                IF    "${Alldatas}[bgv_status]" == "pending"
                    Append To File    ${BGVLog}    Fuse Submitted.\n
                END
            END
        ELSE
            IF    "${Alldatas}[dt_status]" == "Scheduled" or "${Alldatas}[dt_status]" == "Sent To Lab" or "${Alldatas}[dt_status]" == "Received At Lab" or "${Alldatas}[dt_status]" == "In Process With MRO" or "${Alldatas}[dt_status]" == "Remainder" or "${Alldatas}[dt_status]" == "In Process" or "${Alldatas}[dt_status]" == "Waiting"
                Input Text When Element Is Visible    //*[@id="Notedb"]    DTpending#(${DTResult}) with Escreen
                Sleep    1s
                Click Element If Visible
                ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                Sleep    1s
            END
            IF    "${Alldatas}[dt_status_time_check]" != "BGV_updated" and "${Alldatas}[dt_status_time_check]" != "DT_BGV_updated"
                IF    "${Alldatas}[bgv_status]" == "pending"
                    Input Text When Element Is Visible    //*[@id="Notedb"]    BGV pending with HireRight
                    Sleep    1s
                    Click Element If Visible
                    ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                    Sleep    1s
                END
            END
            # Submit
            Append To File    ${DTLog}    Click Submit.\n
            IF    "${Alldatas}[bgv_status]" == "pending"
                Append To File    ${BGVLog}    Click Submit.\n
            END
            Wait Until Element Is Visible
            ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
            ...    30s
            Click Element If Visible    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
            Sleep    2s
            TRY
                Handle Alert    ACCEPT
                Sleep    2s
            EXCEPT
                Log To Console    Pop closed
                Append To File    ${DTLog}    Fuse Submitted.\n
                IF    "${Alldatas}[bgv_status]" == "pending"
                    Append To File    ${BGVLog}    Fuse Submitted.\n
                END
            END
        END
        Append To file    ${BGVLog}    DT&BGV Status Updated in Fuse.\n
        IF    "${Alldatas}[dt_status]" == "Scheduled" or "${Alldatas}[dt_status]" == "Sent To Lab" or "${Alldatas}[dt_status]" == "Received At Lab" or "${Alldatas}[dt_status]" == "In Process With MRO" or "${Alldatas}[dt_status]" == "Remainder" or "${Alldatas}[dt_status]" == "In Process" or "${Alldatas}[dt_status]" == "Waiting"
            Append To file    ${DTLog}    DT&BGV ${DTResult} Updated in Fuse.\n
        END
        Log To Console    DT&BGV ${DTResult} Updated in Fuse.
        Execute Sql String
        ...    UPDATE onboarding SET dt_status_time_check = 'DT_BGV_updated' WHERE SSN = '${Alldatas}[ssn]'
        TRY
            Click Element If Visible    //*[@id="manage_modal"]/div/div/div[1]/button
            Sleep    1s
        EXCEPT
            Log To Console    pop closed
        END
        
    ELSE
        IF    "${Alldatas}[bgv_status]" == "pending"
            Append To file    ${BGVLog}    Fuse application not found.\n
        END
        IF    "${Alldatas}[dt_status]" == "Scheduled" or "${Alldatas}[dt_status]" == "Sent To Lab" or "${Alldatas}[dt_status]" == "Received At Lab" or "${Alldatas}[dt_status]" == "In Process With MRO" or "${Alldatas}[dt_status]" == "Remainder" or "${Alldatas}[dt_status]" == "In Process" or "${Alldatas}[dt_status]" == "Waiting"
            Append To file    ${DTLog}    Fuse application not found.\n
        END
        Log To Console    Fuse application not found.
    END
