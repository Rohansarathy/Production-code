*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem
Library     String
Library     RPA.RobotLogListener
Resource    EpassportExtract.robot
Resource    Fuselogin.robot
Library     Teams_Fail.py
Library     Sendmail.py


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
    ...    ${Epass_name}
    ...    ${Alldatas}
    ...    ${credentials}
    ...    ${ETA_Date}
    ...    ${Conformation_No}
    ...    ${Log}
    ...    ${Firstname}
    ...    ${Lastname}

    ${handles}=    Get Window Titles
    Switch window    ${handles}[1]
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
    TRY
        ${Firstname}=    Strip String    ${Alldatas}[first_name]
        ${Lastname}=    Strip String    ${Alldatas}[last_name]
        ${first_name}=    Convert To Lower Case    ${Firstname}
        ${last_name}=    Convert To Lower Case    ${Lastname}
        ${db_full_name}=    Set Variable    ${first_name} ${last_name}
        ${Timing}=    Get Time
        IF    "${Alldatas}[tax_term]" == "1099"
            # Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[3]/a    5s
            # Click Element If Visible    //*[@id="myNavbar"]/ul/li[3]/a
            # Wait Until Element Is Visible    //*[@id="collapse_Top11"]/div/ul/div[2]/li/a    5s
            # Click Element If Visible    //*[@id="collapse_Top11"]/div/ul/div[2]/li/a
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
            Sleep    4s
            Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
            Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
            Input Text
            ...    //*[@id="exampleRecruits_filter"]/label/input
            ...    ${db_full_name}
            Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
            Click Button    //*[@id="refresh_dt"]
            Sleep    15s
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
                        Append To File    ${Log}    Value Attribute: ${value}\n
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
                Append To File    ${Log}    Fullname=${Fullname}\n
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    5s
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
                            Append To File    ${Log}    Value Attribute: ${value}\n
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
                Append To File    ${Log}    First=${First}\n
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    5s
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
                            Append To File    ${Log}    Value Attribute: ${value}\n
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
                Sleep    4s
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                Input Text
                ...    //*[@id="exampleRecruits_filter"]/label/input
                ...    ${db_full_name}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    15s
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
                            Append To File    ${Log}    Value Attribute: ${value}\n
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
            # Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[3]/a    5s
            # Click Element If Visible    //*[@id="myNavbar"]/ul/li[3]/a
            # Wait Until Element Is Visible    //*[@id="collapse_Top11"]/div/ul/div[1]/li/a    5s
            # Click Element If Visible    //*[@id="collapse_Top11"]/div/ul/div[1]/li/a
            # Sleep    1s
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
            Sleep    4s
            Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
            Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
            Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
            Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
            Click Button    (//*[@id="refresh_dt"])[1]
            Sleep    15s
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
                        Append To File    ${Log}    Value Attribute: ${value}\n
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
                Append To File    ${Log}    Fullname=${Fullname}\n
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                Click Button    (//*[@id="refresh_dt"])[1]
                Sleep    5s
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
                            Append To File    ${Log}    Value Attribute: ${value}\n
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
                Append To File    ${Log}    First=${First}\n
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                Click Button    (//*[@id="refresh_dt"])[1]
                Sleep    5s
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
                            Append To File    ${Log}    Value Attribute: ${value}\n
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
                Sleep    4s
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                Click Button    (//*[@id="refresh_dt"])[1]
                Sleep    15s
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
                            Append To File    ${Log}    Value Attribute: ${value}\n
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
            Log To Console    Tech not found for Fuse update
            Append To File    ${Log}    Tech not found in Fuse update.\n
            ${Recepients}=    set variable    ${credentials}[Recipient],${Alldatas}[hr_coordinator]
            IF    "${Alldatas}[tax_term]" == "1099"
                ${Subject}=    Set Variable
                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
            ELSE
                ${Subject}=    Set Variable
                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
            END
            ${Subject}=    Set Variable
            ...    Tech not found in Fuse update,
            ${Body}=    Set Variable
            ...    Technician not found, Bot didn't updated COX-DT&BGV Initiation details for ${Alldatas}[first_name] ${Alldatas}[last_name] in Fuse. Kindly check.
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
        # Drug & Backgraound
        ${Date}=    Get Time
        ${date_and_time}=    Split String    ${Date}    ${SPACE}
        ${date_parts}=    Split String    ${date_and_time[0]}    -
        ${year}=    Set Variable    ${date_parts[0]}
        ${month}=    Set Variable    ${date_parts[1]}
        ${day}=    Set Variable    ${date_parts[2]}
        ${Date}=    Set Variable    ${month}/${day}/${year}
        
        IF    "${Alldatas}[process]" == "pre_employment"
            # ************DT************
            Wait Until Element Is Visible    //*[@id="submit_for_drug_test"]    30s
            Input Text When Element Is Visible    //*[@id="submit_for_drug_test"]    ${Date}
            Sleep    1s
            IF    "${Alldatas}[tax_term]" == "w2"
                Click Element If Visible
                ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[6]/td[2]/label[3]/div
                Sleep    1s
            ELSE
                Click Element If Visible
                ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[7]/td[2]/label[3]/div
                Sleep    1s
            END
            Choose File    (//input[@type="file"])[1]    ${Epass_name}
            Sleep    1s
            Append To File    ${Log}    Drug Updated in Fuse.\n
            Log To Console    Drug Updated

            # ************Background************
            Input Text When Element Is Visible    //*[@id="submit_for_background_test"]    ${Date}
            Sleep    1s
            Click Element If Visible    //*[@id="update_all_data_form"]/div[1]/div[2]/table/tbody/tr[6]/td[2]/label[3]/div
            Sleep    1s
            Append To File    ${Log}    Background Updated in Fuse.\n
            Log To Console    Background Updated

       
            # Notes Update
            IF    "${Alldatas}[tax_term]" == "w2"
                Input Text When Element Is Visible    //*[@id="notes"]    DT/BG submitted in InfoMart
                Sleep    1s
                Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                Sleep    1s
                # Submit
                Append To File    ${Log}    Click Submit.\n
                Wait Until Element Is Visible
                ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
                ...    30s
                Click Element If Visible    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
                Sleep    2s
                TRY
                    Handle Alert    ACCEPT
                    Sleep    2s
                EXCEPT
                    Log To Console    Popup not found
                    Append To File    ${Log}    Fuse Submitted.\n
                END
            ELSE
                Input Text When Element Is Visible    //*[@id="Notedb"]    DT/BG submitted in InfoMart.
                Sleep    1s
                Click Element If Visible
                ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                Sleep    1s
                # Submit
                Append To File    ${Log}    Click Submit.\n
                Wait Until Element Is Visible
                ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
                ...    30s
                Click Element If Visible    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
                Sleep    2s
                TRY
                    Handle Alert    ACCEPT
                    Sleep    2s
                EXCEPT
                    Log To Console    Popup not found
                    Append To File    ${Log}    Fuse Submitted.\n
                END
            END
        END
        Append To File    ${Log}    DT & BGV Initiation updated in Fuse.\n
        Log To Console    DT & BGV Initiation updated in Fuse.
        TRY
            Click Element If Visible    //*[@id="manage_modal"]/div/div/div[1]/button
            Sleep    1s
        EXCEPT
            Log To Console    pop closed
        END
        ${FuseUpdate_Flag}=    Set Variable    True
        RETURN    ${FuseUpdate_Flag}
    EXCEPT
        Log To Console    pop closed
        ${FuseUpdate_Flag}=    Set Variable    False
        RETURN    ${FuseUpdate_Flag}
    END
