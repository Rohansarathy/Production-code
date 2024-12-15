*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem
Library     String
Library     Sendmail.py
Library    DatabaseLibrary


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
DT&BGV_Fuse_Update
    [Arguments]
    ...    ${credentials}
    ...    ${Alldatas}
    ...    ${ETA_Date}
    ...    ${Log}
    ...    ${criminal_result}
    ...    ${drug_result}
    ...    ${drug_date}
    ...    ${MVR_result}


    ${handles}=    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    TRY
        ${Popup_exists}=    Run Keyword And Return Status
        ...    Element Should Be Visible
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
    ${F_Login_2}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    //*[@id="topicons"]/ul/li[5]/a
    ...    10s
    IF    ${F_Login_2} == True
        TRY
            ${Firstname}=    Strip String    ${Alldatas}[tech_first_name]
            ${Lastname}=    Strip String    ${Alldatas}[tech_last_name]
            ${first_name}=    Convert To Lower Case    ${Firstname}
            ${last_name}=    Convert To Lower Case    ${Lastname}
            ${db_full_name}=    Set Variable    ${first_name} ${last_name}
            ${Timing}=    Get Time
            Log To Console    tax_term=${Alldatas}[tax_term]
            IF    "${Alldatas}[tax_term]" == "1099"
                Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[8]/a    5s
                Click Element If Visible    //*[@id="myNavbar"]/ul/li[8]/a
                Wait Until Element Is Visible    //li/a[@href='/onb/contractor_recruiting.php']    5s
                Click Element If Visible    //li/a[@href='/onb/contractor_recruiting.php']
                TRY
                    ${Popup_exists}=    Run Keyword And Return Status
                    ...    Element Should Be Visible
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
                Sleep    7s
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    5s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Input Text
                ...    //*[@id="exampleRecruits_filter"]/label/input
                ...    ${db_full_name}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button   //*[@id="refresh_dt"]
                Sleep    7s
                ${row_index}=    Set Variable    ${EMPTY}
                ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                Log To Console    Row Count: ${row_count}
                Append To File    ${Log}    Row Count: ${row_count}\n
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
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${Log}    Matching Row Index: ${row_index}\n
                            Wait Until Element Is Visible
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${Log}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
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
                    Append To File    ${Log}    Fullname=${Fullname}\n
                    Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    5s
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                    Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Firstname}
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                    Click Button   //*[@id="refresh_dt"]
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
                            ...    ${Log}
                            ...    Name: '${full_name}' == '${db_full_name}'\n
                            IF    '${full_name}' == '${db_full_name}'
                                ${row_index}=    Set Variable    ${index}
                                Log To Console    Matching Row Index: ${row_index}
                                Append To File    ${Log}    Matching Row Index: ${row_index}\n
                                Wait Until Element Is Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ...    5s
                                ${element}=    Get WebElement
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${value}=    Get Element Attribute    ${element}    value
                                Log To Console    Value Attribute: ${value}
                                Append To File    ${Log}    Value Attribute: ${value}\n
                                IF    '${value}' == 'D/B Check'
                                    Click Element If Visible
                                    ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
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
                    Append To File    ${Log}    First=${First}\n
                    Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    5s
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                    Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Lastname}
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                    Click Button   //*[@id="refresh_dt"]
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
                            ...    ${Log}
                            ...    Name: '${full_name}' == '${db_full_name}'\n
                            IF    '${full_name}' == '${db_full_name}'
                                ${row_index}=    Set Variable    ${index}
                                Log To Console    Matching Row Index: ${row_index}
                                Append To File    ${Log}    Matching Row Index: ${row_index}\n
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
                                    Click Element If Visible
                                    ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
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
                    Sleep    7s
                    Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    5s
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                    Input Text
                    ...    //*[@id="exampleRecruits_filter"]/label/input
                    ...    ${db_full_name}
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                    Click Button   //*[@id="refresh_dt"]
                    Sleep    7s
                    ${row_index}=    Set Variable    ${EMPTY}
                    ${row_count}=    Get Element Count    //table[@id='exampleRecruits']/tbody/tr
                    Log To Console    Row Count: ${row_count}
                    Append To File    ${Log}    Row Count: ${row_count}\n
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
                                Log To Console    Matching Row Index: ${row_index}
                                Append To File    ${Log}    Matching Row Index: ${row_index}\n
                                Wait Until Element Is Visible
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ...    5s
                                ${element}=    Get WebElement
                                ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${value}=    Get Element Attribute    ${element}    value
                                Log To Console    Value Attribute: ${value}
                                Append To File    ${Log}    Value Attribute: ${value}\n
                                IF    '${value}' == 'D/B Check'
                                    Click Element If Visible
                                    ...    //table[@id='exampleRecruits']/tbody/tr[${row_index}]/td[3]/input[1]
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
                Wait Until Element Is Visible    (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7]    5s
                Click Element If Visible    (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7]
                Sleep    1s
                TRY
                    ${Popup_exists}=    Run Keyword And Return Status
                    ...    Element Should Be Visible
                    ...    //*[@id="example_main_notification"]/tbody/tr/td[1]
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
                Sleep    7s
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    5s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                Click Button    (//*[@id="refresh_dt"])[1]
                Sleep    7s
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
                        ...    ${Log}
                        ...    Name: '${full_name}' == '${db_full_name}'\n
                        IF    '${full_name}' == '${db_full_name}'
                            ${row_index}=    Set Variable    ${index}
                            Log To Console    Matching Row Index: ${row_index}
                            Append To File    ${Log}    Matching Row Index: ${row_index}\n
                            Wait Until Element Is Visible
                            ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                            ...    5s
                            ${element}=    Get WebElement
                            ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                            ${value}=    Get Element Attribute    ${element}    value
                            Log To Console    Value Attribute: ${value}
                            Append To File    ${Log}    Value Attribute: ${value}\n
                            IF    '${value}' == 'D/B Check'
                                Click Element If Visible
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
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
                    Append To File    ${Log}    Fullname=${Fullname}\n
                    Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    5s
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
                    Input Text    //*[@id="exampleImport_filter"]/label/input    ${Firstname}
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                    Click Button    (//*[@id="refresh_dt"])[1]
                    Sleep    7s
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
                            ...    ${Log}
                            ...    Name: '${full_name}' == '${db_full_name}'\n
                            IF    '${full_name}' == '${db_full_name}'
                                ${row_index}=    Set Variable    ${index}
                                Log To Console    Matching Row Index: ${row_index}
                                Append To File    ${Log}    Matching Row Index: ${row_index}\n
                                Wait Until Element Is Visible
                                ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                                ...    5s
                                ${element}=    Get WebElement
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${value}=    Get Element Attribute    ${element}    value
                                Log To Console    Value Attribute: ${value}
                                Append To File    ${Log}    Value Attribute: ${value}\n
                                IF    '${value}' == 'D/B Check'
                                    Click Element If Visible
                                    ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
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
                    Append To File    ${Log}    First=${First}\n
                    Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    5s
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
                    Input Text    //*[@id="exampleImport_filter"]/label/input    ${Lastname}
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                    Click Button    (//*[@id="refresh_dt"])[1]
                    Sleep    7s
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
                            ...    ${Log}
                            ...    Name: '${full_name}' == '${db_full_name}'\n
                            IF    '${full_name}' == '${db_full_name}'
                                ${row_index}=    Set Variable    ${index}
                                Log To Console    Matching Row Index: ${row_index}
                                Append To File    ${Log}    Matching Row Index: ${row_index}\n
                                Wait Until Element Is Visible
                                ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                                ...    5s
                                ${element}=    Get WebElement
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${value}=    Get Element Attribute    ${element}    value
                                Log To Console    Value Attribute: ${value}
                                Append To File    ${Log}    Value Attribute: ${value}\n
                                IF    '${value}' == 'D/B Check'
                                    Click Element If Visible
                                    ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
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
                    Sleep    7s
                    Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    5s
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    5s
                    Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                    Click Button    (//*[@id="refresh_dt"])[1]
                    Sleep    7s
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
                            ...    ${Log}
                            ...    Name: '${full_name}' == '${db_full_name}'\n
                            IF    '${full_name}' == '${db_full_name}'
                                ${row_index}=    Set Variable    ${index}
                                Log To Console    Matching Row Index: ${row_index}
                                Append To File    ${Log}    Matching Row Index: ${row_index}\n
                                Wait Until Element Is Visible
                                ...    //*[@id="exampleImport"]/tbody/tr[${row_index}]/td[3]/input[1]
                                ...    5s
                                ${element}=    Get WebElement
                                ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
                                ${value}=    Get Element Attribute    ${element}    value
                                Log To Console    Value Attribute: ${value}
                                Append To File    ${Log}    Value Attribute: ${value}\n
                                IF    '${value}' == 'D/B Check'
                                    Click Element If Visible
                                    ...    //table[@id='exampleImport']/tbody/tr[${row_index}]/td[3]/input[1]
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
        EXCEPT
            ${AllFullname}=    Set Variable    False
        END
            IF    "${AllFullname}" == "False"
                Log To Console    Tech not found for Fuse update
                Append To File    ${Log}    Tech not found in Fuse update.\n
                ${Recepients}=    set variable    ${credentials}[Spectrum_team]
                ${CC}=    set variable    ${credentials}[ybotID]
                IF    "${Alldatas}[tax_term]" == "1099"
                    ${Subject}=    Set Variable
                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                ELSE
                    ${Subject}=    Set Variable
                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                END
                ${Body}=    Set Variable
                ...    Technician not found, Bot didn't updated Spectrum DT&BGV status for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name] in Fuse. Kindly update manually.
                ${Body1}    Set Variable    DT : "${drug_result}"
                ${Body2}    Set Variable    BGV : "${criminal_result}" ####ETA : "${ETA_Date}"####.
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
            END
        TRY
            IF    "${Alldatas}[dt_status]" != "${drug_result}"
                IF    "${drug_result}" == "PASS" or "${drug_result}" == "FAIL" or "${drug_result}" == "EXPIRED"
                    # ************DT************
                    Log To Console    drug_date=${drug_date}
                    Append To File    ${Log}    drug_date=${drug_date}\n
                    Wait Until Element Is Visible    //*[@id="return_of_drug_test1"]    30s
                    Input Text When Element Is Visible    //*[@id="return_of_drug_test1"]    ${drug_date}
                    Sleep    1s
                    IF    "${Alldatas}[tax_term]" == "w2"
                        IF    "${drug_result}" == "PASS"
                            Click Element If Visible
                            ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[6]/td[2]/label[1]/div
                            Sleep    1s
                        ELSE
                            Click Element If Visible
                            ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[6]/td[2]/label[2]/div
                            Sleep    1s
                        END    
                    ELSE
                        IF    "${drug_result}" == "PASS"
                            Click Element If Visible
                            ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[7]/td[2]/label[1]/div
                            Sleep    1s
                        ELSE
                            Click Element If Visible
                            ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[7]/td[2]/label[2]/div
                            Sleep    1s
                        END
                    END
                    Append To File    ${Log}    Drug date updated in fuse.\n
                    Log To Console    Drug date updated in fuse
                    IF    "${Alldatas}[tax_term]" == "w2"
                        Wait Until Element Is Visible    //*[@id="notes"]    5s
                        IF    "${drug_result}" == "PASS"
                            Input Text When Element Is Visible    //*[@id="notes"]    DT cleared
                            Sleep    1s
                        ELSE
                            IF    "${drug_result}" == "FAIL"
                                Input Text When Element Is Visible    //*[@id="notes"]    DT failed
                                Sleep    1s
                            ELSE
                                Input Text When Element Is Visible    //*[@id="notes"]    DT expired
                                Sleep    1s
                            END
                        END
                        Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                        Sleep    1s
                    ELSE
                        Wait Until Element Is Visible    //*[@id="Notedb"]    5s
                        IF    "${drug_result}" == "PASS"
                            Input Text When Element Is Visible    //*[@id="Notedb"]    DT cleared
                            Sleep    1s
                        ELSE
                            IF    "${drug_result}" == "FAIL"
                                Input Text When Element Is Visible    //*[@id="Notedb"]    DT failed
                                Sleep    1s
                            ELSE
                                Input Text When Element Is Visible    //*[@id="Notedb"]    DT expired
                                Sleep    1s
                            END
                        END
                        Click Element If Visible
                        ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                        Sleep    1s
                    END
                END
            END
            # IF    "${criminal_result}" == "PASS"
            #     # ************Background************
            #     Input Text When Element Is Visible    //*[@id="submit_for_background_test"]    ${criminal_date}
            #     Sleep    1s
            #     Click Element If Visible
            #     ...    //*[@id="update_all_data_form"]/div[1]/div[2]/table/tbody/tr[6]/td[2]/label[1]/div
            #     Sleep    1s
            #     Choose File    (//input[@type="file"])[2]    ${Status_PDF}
            #     Sleep    1s
            #     Append To File    ${Log}    Background Updated in Fuse.\n
            #     Log To Console    Background Updated
            # END
            IF    "${MVR_result}" == "FAIL" 
                IF    "${Alldatas}[mvr_status]" != "${MVR_result}" 
                    IF    "${Alldatas}[tax_term]" == "w2"
                        Wait Until Element Is Visible    //*[@id="notes"]    5s
                        Input Text When Element Is Visible    //*[@id="notes"]    MVR Failed
                        Sleep    1s
                        Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                        Sleep    1s
                    ELSE
                        Wait Until Element Is Visible    //*[@id="Notedb"]    5s
                        Input Text When Element Is Visible    //*[@id="Notedb"]    MVR Failed
                        Sleep    1s
                        Click Element If Visible
                        ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                        Sleep    1s
                    END
                END
            END
            IF    "${criminal_result}" == "COMPLETED" 
                IF    "${Alldatas}[bgv_status]" != "${criminal_result}"
                    IF    "${Alldatas}[tax_term]" == "w2"
                        Wait Until Element Is Visible    //*[@id="notes"]    5s
                        Input Text When Element Is Visible    //*[@id="notes"]    BGV Completed
                        Sleep    1s
                        Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                        Sleep    1s
                    ELSE
                        Wait Until Element Is Visible    //*[@id="Notedb"]    5s
                        Input Text When Element Is Visible    //*[@id="Notedb"]    BGV Completed
                        Sleep    1s
                        Click Element If Visible
                        ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                        Sleep    1s
                    END
                END
                ${Update_time}    Get Time
                Execute Sql String
                ...    UPDATE spectrum_onboarding SET fuse_status_check = '${Update_time}' WHERE SSN = '${Alldatas}[ssn]'
            END
            IF    "${criminal_result}" == "PENDING" 
                IF    "${Alldatas}[tax_term]" == "w2"
                    Wait Until Element Is Visible    //*[@id="notes"]    5s
                    Input Text When Element Is Visible    //*[@id="notes"]    BGV ETA-${ETA_Date}
                    Sleep    1s
                    Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                    Sleep    1s
                ELSE
                    Wait Until Element Is Visible    //*[@id="Notedb"]    5s
                    Input Text When Element Is Visible    //*[@id="Notedb"]    BGV ETA-${ETA_Date}
                    Sleep    1s
                    Click Element If Visible
                    ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                    Sleep    1s
                END
                ${Update_time}    Get Time
                Execute Sql String
                ...    UPDATE spectrum_onboarding SET fuse_status_check = '${Update_time}' WHERE SSN = '${Alldatas}[ssn]'
            END
            # Submit
            Log To Console    Click Submit
            Append To File    ${Log}    Click Submit.\n
            Wait Until Element Is Visible
            ...    //input[@value='Save']
            ...    30s
            Click Element If Visible    //input[@value='Save']
            Sleep    2s
            TRY
                Handle Alert    ACCEPT
                Sleep    2s
            EXCEPT
                Log To Console    Popup not found
                Append To File    ${Log}    Fuse Submitted.\n
            END
            TRY
                Click Element If Visible    //*[@id="manage_modal"]/div/div/div[1]/button
                Sleep    1s
            EXCEPT
                Log To Console    pop not closed
            END
            Append To File    ${Log}    BGV & DT Initiation updated in Fuse.\n
            Log To Console    BGV & DT Initiation updated in Fuse.
            ${FuseUpdate_Flag}=    Set Variable    True
            RETURN    ${FuseUpdate_Flag}
        EXCEPT
            Log To Console    pop closed
            ${FuseUpdate_Flag}=    Set Variable    False
            RETURN    ${FuseUpdate_Flag}
        END
    ELSE
        Log To Console    Fuse page not found.
        Append To File    ${Log}    Fuse page not found.\n
        ${Recepients}=    set variable    ${credentials}[Spectrum_team]
        ${CC}=    set variable    ${credentials}[ybotID]
        IF    "${Alldatas}[tax_term]" == "1099"
            ${Subject}=    Set Variable
            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
        ELSE
            ${Subject}=    Set Variable
            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
        END
        ${Body}=    Set Variable
        ...    Fuse not found, Bot didn't updated Spectrum DT&BGV status for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name] in Fuse. Kindly update manually.
        ${Body1}    Set Variable    DT : "${drug_result}"
        ${Body2}    Set Variable    BGV : "${criminal_result}" ####ETA : "${ETA_Date}"####.
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
            Append To file    ${Log}    Mail sent for Fuse not found.\n
            Log To Console    Mail sent
        ELSE
            Append To file    ${Log}    Mail not sent for Fuse not found.\n
            Log To Console    Mail not sent
        END
    END
