*** Settings ***
Library     RPA.Browser.Selenium
Library     String
Library     Sendmail
Library     OperatingSystem
Library     DateTime
Library     DatabaseLibrary


*** Variables ***
${Fullname}         ${EMPTY}
${First}            ${EMPTY}
${Last}             ${EMPTY}
${AllFullname}      ${EMPTY}
${doc}              ${EMPTY}


*** Keywords ***
 Fuse_Updates
    [Arguments]
    ...    ${Alldatas}
    ...    ${credentials}
    ...    ${output_pdf_path}
    ...    ${DTLog}
    ...    ${TechStatus}
    ...    ${date}

    ${handles}=    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    TRY
        ${Popup_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="example_main_notification"]/tbody/tr/td[1]
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
        Append To File    ${DTLog}    Popup not found\n
    END
    ${F_Login_}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="topicons"]/ul/li[5]/a
    ...    5s
    Log To Console    F_Login_=${F_Login_}
    IF    ${F_Login_} == True
        Append To File    ${DTLog}    Searching the Tech\n
        ${Firstname}=    Strip String    ${Alldatas}[first_name]
        ${Lastname}=    Strip String    ${Alldatas}[last_name]
        ${first_name}=    Convert To Lower Case    ${Firstname}
        ${last_name}=    Convert To Lower Case    ${Lastname}
        ${db_full_name}=    Set Variable    ${first_name} ${last_name}
        ${Timing}=    Get Time
        TRY
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
                    ...    //*[@id="example_main_notification"]/tbody/tr/td[1]
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
                Sleep    4s
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                Input Text
                ...    //*[@id="exampleRecruits_filter"]/label/input
                ...    ${db_full_name}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Element    //*[@id="refresh_dt"]
                Sleep    5s
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
                    Sleep    4s
                    Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    10s
                    Input Text
                    ...    //*[@id="exampleRecruits_filter"]/label/input
                    ...    ${db_full_name}
                    Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                    Click Element    //*[@id="refresh_dt"]
                    Sleep    5s
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
                    ...    //*[@id="example_main_notification"]/tbody/tr/td[1]
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
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                Click Element    (//*[@id="refresh_dt"])[1]
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
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
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
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                    Click Element    (//*[@id="refresh_dt"])[1]
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
                    Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                    Click Element    (//*[@id="refresh_dt"])[1]
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
        EXCEPT
            Log To Console    Tech not found
            ${AllFullname}=    Set Variable    False
        END
        IF    "${AllFullname}" == "False"
            Log To Console    Tech not found in Fuse update
            Append To File    ${DTLog}    Tech not found in Fuse update.\n
            IF    "${TechStatus}" == "Complete"
                ${Body}=    Set Variable
                ...    Bot failed to update the BGV/DT status#(Complete) in Fuse due to Tech Name mismatch for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly update Manually.
            ELSE
                ${Body}=    Set Variable
                ...    Bot failed to update the BGV/DT status#(Pending) in Fuse due to Tech Name mismatch for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly update Manually.
            END
            # ${Recepients}=    set variable    ${credentials}[Recipient]
            # # ${CC}=    set variable
            ${Recepients}=    set variable    ${Alldatas}[hr_coordinator]
            ${CC}=    Set Variable    ${credentials}[Recipient]
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
            ...    ${Attachment}
            IF    ${Mailsent} == True
                Append To file    ${DTLog}    Mail sent for BGV/DT status not Updated in Fuse.\n
                Log To Console    Mail sent not Updated in Fuse
            ELSE
                Append To file    ${DTLog}    Mail not sent for BGV/DT status not Updated in Fuse.\n
                Log To Console    Mail not sent not Updated in Fuse
            END
            ${Tech_found}=    Set Variable    False
        ELSE
            ${Tech_found}=    Set Variable    True
        END
        IF    ${Tech_found} == True
            TRY
                Log To Console    Going for Fuse updates.
                Append To File    ${DTLog}    Going for Fuse updates.\n
                ${status_check_date}=    Get Time
                Log To Console    status_check_date: ${status_check_date}
                Append To File    ${DTLog}    Date=${date}\n
                Log To Console    Date=${date}
                IF    "${Alldatas}[tax_term]" == "w2"
                    IF    "${TechStatus}" == "Complete"
                        #DT
                        Input Text When Element Is Visible    //*[@id="return_of_drug_test1"]    ${date}
                        Sleep    1s
                        Click Element If Visible
                        ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[6]/td[2]/label[1]/div
                        Sleep    1s
                        #BG
                        Input Text When Element Is Visible    //*[@id="return_of_background_test"]    ${date}
                        Sleep    1s
                        Click Element If Visible
                        ...    //*[@id="update_all_data_form"]/div[1]/div[2]/table/tbody/tr[6]/td[2]/label[1]/div
                        Sleep    1s
                        Append To File    ${DTLog}    Date updated.\n
                        Choose File    (//input[@type="file"])[2]    ${output_pdf_path}
                        Sleep    1s
                        Append To File    ${DTLog}    file uploded.\n
                        #BYPASS
                        Click Element If Visible    
                        ...    //*[@id="update_all_data_form"]/div[1]/div[3]/table/tbody/tr[6]/td[2]/label[5]/div
                        Input Text When Element Is Visible    //*[@id="notes"]    DT/BG Completed Bypass to HR
                        Sleep    1s
                    ELSE
                        Input Text When Element Is Visible    //*[@id="notes"]    Pending infomart results
                        Sleep    1s
                    END
                    Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                    Sleep    1s
                    Append To File    ${DTLog}    Notes updated.\n
                    Log To Console    Notes updated.
                    # Submit
                    TRY
                        Wait Until Element Is Visible
                        ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
                        ...    10s
                        Click Element If Visible
                        ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
                        Sleep    2s
                        Append To File    ${DTLog}    Click Submit.\n
                        Handle Alert    ACCEPT
                        Sleep    2s
                        Execute Sql String
                        ...    UPDATE cox_onboarding SET fuse_status_check = '${status_check_date}' WHERE SSN = '${Alldatas}[ssn]'
                    EXCEPT
                        Log To Console    Fuse not submitted
                        Append To File    ${DTLog}    Fuse not submitted.\n
                    END
                ELSE
                    IF    "${TechStatus}" == "Complete"
                        #DT
                        Input Text When Element Is Visible    //*[@id="return_of_drug_test1"]    ${date}
                        Sleep    1s
                        Click Element If Visible
                        ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[7]/td[2]/label[1]/div
                        Sleep    1s
                        #BG
                        Input Text When Element Is Visible    //*[@id="return_of_background_test"]    ${date}
                        Sleep    1s
                        Click Element If Visible
                        ...    //*[@id="update_all_data_form"]/div[1]/div[2]/table/tbody/tr[6]/td[2]/label[1]/div
                        Sleep    1s
                        Append To File    ${DTLog}    Date updated.\n
                        Choose File    (//input[@type="file"])[2]    ${output_pdf_path}
                        Sleep    1s
                        Append To File    ${DTLog}    file uploded.\n
                        Input Text When Element Is Visible
                        ...    //*[@id="Notedb"]
                        ...    DT/BG Completed Pending for Credentials
                        Sleep    1s
                    ELSE
                        Input Text When Element Is Visible    //*[@id="Notedb"]    Pending infomart results
                        Sleep    1s
                    END
                    Click Element If Visible
                    ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                    Sleep    1s
                    Append To File    ${DTLog}    Notes updated.\n
                    Log To Console    Notes updated.
                    # Submit
                    TRY
                        Wait Until Element Is Visible
                        ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
                        ...    10s
                        Click Element If Visible
                        ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
                        Sleep    2s
                        Append To File    ${DTLog}    Click Submit.\n
                        Handle Alert    ACCEPT
                        Sleep    2s
                        Execute Sql String
                        ...    UPDATE cox_onboarding SET fuse_status_check = '${status_check_date}' WHERE SSN = '${Alldatas}[ssn]'
                    EXCEPT
                        Log To Console    Fuse not submitted
                        Append To File    ${DTLog}    Fuse not submitted.\n
                    END
                END
                TRY
                    Click Element If Visible    //*[@id="manage_modal"]/div/div/div[1]/button
                    Sleep    1s
                EXCEPT
                    Log To Console    pop not closed
                END
            EXCEPT
                Append To File    ${DTLog}    Error occured while fuse update\n
                IF    "${TechStatus}" != "Complete"
                    ${TechStatus}=    Set Variable    Pending
                END
                IF    "${TechStatus}" == "Complete"
                    ${Body}=    Set Variable
                    ...    Bot failed to update the BGV/DT status#(Complete) in Fuse due to Tech Name mismatch for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly update Manually.
                ELSE
                    ${Body}=    Set Variable
                    ...    Bot failed to update the BGV/DT status#(Pending) in Fuse due to Tech Name mismatch for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly update Manually.
                END
                ${Recepients}=    set variable    ${Alldatas}[hr_coordinator]
                ${CC}=    Set Variable    ${credentials}[Recipient]
                ${Body1}=    Set Variable
                ${Body2}=    Set Variable
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
                ...    ${Attachment}
                IF    ${Mailsent} == True
                    Append To file    ${DTLog}    Mail sent for Fuse status not updated.\n
                    Log To Console    Mail sent for Fuse status not updated.
                ELSE
                    Append To file    ${DTLog}    Mail not sent for Fuse status not updated.\n
                    Log To Console    Mail not sent for Fuse status not updated.
                END
            END
        END
    ELSE
        Append To file    ${DTLog}    Fuse application not found.\n
        Log To Console    Fuse application not found.
    END
