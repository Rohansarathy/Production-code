*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem
Library     String
Resource    Fuselogin.robot

*** Variables ***
${expected_text}    No data available in table
${Fullname}         ${EMPTY}
${First}            ${EMPTY}
${Last}             ${EMPTY}
${Last2}            ${EMPTY}
${AllFullname}      ${EMPTY}
${AllFullname2}     ${EMPTY}

*** Keywords ***
Techsearch
    [Arguments]    ${Alldatas}    ${credentials}    ${Log}
    
    ${handles}=    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    ${F_Login_}=    Run Keyword And Return Status    
    ...    Wait Until Element Is Visible    
    ...    //*[@id="myNavbar"]/ul/li[3]/a    
    ...    10s
    Log to console    ${F_Login_}
    IF    ${F_Login_} == True
        ${Firstname}    Strip String    ${Alldatas}[first_name] 
        ${Lastname}    Strip String    ${Alldatas}[last_name]
        ${first_name}=    Convert To Lower Case    ${Firstname}
        ${last_name}=    Convert To Lower Case    ${Lastname}
        ${db_full_name}=    Set Variable    ${first_name} ${last_name}
        ${Timing}=    Get Time
        IF    "${Alldatas}[tax_term]" == "1099"
            Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[8]/a    5s
            Click Element If Visible    //*[@id="myNavbar"]/ul/li[8]/a
            Wait Until Element Is Visible    //li/a[@href='/onb/contractor_recruiting.php']    5s
            Click Element If Visible    //li/a[@href='/onb/contractor_recruiting.php']
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    10s
            Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
            Wait Until Element Is Visible    (//*[@id="refresh_dt"])  10s
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
                                ${Tech_found_flag}=    Set Variable    True
                                ${Fullname}=    Set Variable    True
                                BREAK
                            ELSE
                                ${Tech_found_flag}=    Set Variable    False
                                ${Fullname}=    Set Variable    False
                            END
                        # ELSE
                        #     ${Tech_found_flag}=    Set Variable    False
                        #     ${Fullname}=    Set Variable    False
                        # END
                    ELSE
                        ${Tech_found_flag}=    Set Variable    False
                        ${Fullname}=    Set Variable    False
                    END
                EXCEPT
                    ${Tech_found_flag}=    Set Variable    False
                    ${Fullname}=    Set Variable    False
                END
            END
            IF    "${Fullname}" == "False"
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])  10s
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    10s
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
                                    ${Tech_found_flag}=    Set Variable    True
                                    ${First}=    Set Variable    True
                                    BREAK
                                ELSE
                                    ${Tech_found_flag}=    Set Variable    False
                                    ${First}=    Set Variable    False
                                END
                            # ELSE
                            #     ${Tech_found_flag}=    Set Variable    False
                            #     ${First}=    Set Variable    False
                            # END
                        ELSE
                            ${Tech_found_flag}=    Set Variable    False
                            ${First}=    Set Variable    False
                        END
                    EXCEPT
                        ${Tech_found_flag}=    Set Variable    False
                        ${First}=    Set Variable    False
                    END
                END
            END
            IF    "${First}" == "False"
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])  10s
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    //*[@id="refresh_dt"]    5s
                Click Button    //*[@id="refresh_dt"]
                Sleep    10s
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
                                    ${Tech_found_flag}=    Set Variable    True
                                    ${Last}=    Set Variable    True
                                    BREAK
                                ELSE
                                    ${Tech_found_flag}=    Set Variable    False
                                    ${Last}=    Set Variable    False
                                END
                            # ELSE
                            #     ${Tech_found_flag}=    Set Variable    False
                            #     ${Last}=    Set Variable    False
                            # END
                        ELSE
                            ${Tech_found_flag}=    Set Variable    False
                            ${Last}=    Set Variable    False
                        END
                    EXCEPT
                        ${Tech_found_flag}=    Set Variable    False
                        ${Last}=    Set Variable    False
                    END
                END
            END
            IF    "${Last}" == "False"
                #All Process
                Click Element If Visible    //*[@id="frm_filter_data"]/div[4]/span/label/div
                Sleep    10s
                Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])  10s
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
                                    ${Tech_found_flag}=    Set Variable    True
                                    ${AllFullname}=    Set Variable    True
                                    BREAK
                                ELSE
                                    ${Tech_found_flag}=    Set Variable    False
                                    ${AllFullname}=    Set Variable    False
                                END
                            # ELSE
                            #     ${Tech_found_flag}=    Set Variable    False
                            #     ${AllFullname}=    Set Variable    False
                            # END
                        ELSE
                            ${Tech_found_flag}=    Set Variable    False
                            ${AllFullname}=    Set Variable    False
                        END
                    EXCEPT
                        ${Tech_found_flag}=    Set Variable    False
                        ${AllFullname}=    Set Variable    False
                    END
                END
            END
        ELSE
            Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[8]/a    5s
            Click Element If Visible    //*[@id="myNavbar"]/ul/li[8]/a
            Wait Until Element Is Visible    (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7]     5s
            Click Element If Visible    (//*[@id="collapse_Top11"]/div/ul/div[1]/li[2]/a)[7] 
            Sleep    1s
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    10s
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
                                ${Tech_found_flag}=    Set Variable    True
                                ${Fullname}=    Set Variable    True
                                BREAK
                            ELSE
                                ${Tech_found_flag}=    Set Variable    False
                                ${Fullname}=    Set Variable    False
                            END
                        # ELSE
                        #     ${Tech_found_flag}=    Set Variable    False
                        #     ${Fullname}=    Set Variable    False
                        # END
                    ELSE
                        ${Tech_found_flag}=    Set Variable    False
                        ${Fullname}=    Set Variable    False
                    END
                EXCEPT
                    ${Tech_found_flag}=    Set Variable    False
                    ${Fullname}=    Set Variable    False
                END
            END
            IF    "${Fullname}" == "False"
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Firstname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                Click Button    (//*[@id="refresh_dt"])[1]
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
                                    ${Tech_found_flag}=    Set Variable    True
                                    ${First}=    Set Variable    True
                                    BREAK
                                ELSE
                                    ${Tech_found_flag}=    Set Variable    False
                                    ${First}=    Set Variable    False
                                END
                            ELSE
                                ${Tech_found_flag}=    Set Variable    False
                                ${First}=    Set Variable    False
                            END
                        # ELSE
                        #     ${Tech_found_flag}=    Set Variable    False
                        #     ${First}=    Set Variable    False
                        # END
                    EXCEPT
                        ${Tech_found_flag}=    Set Variable    False
                        ${First}=    Set Variable    False
                    END
                END
            END
            IF    "${First}" == "False"
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Lastname}
                Wait Until Element Is Visible    (//*[@id="refresh_dt"])[1]   5s
                Click Button    (//*[@id="refresh_dt"])[1]
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
                                    ${Tech_found_flag}=    Set Variable    True
                                    ${Last}=    Set Variable    True
                                    BREAK
                                ELSE
                                    ${Tech_found_flag}=    Set Variable    False
                                    ${Last}=    Set Variable    False
                                END
                            # ELSE
                            #     ${Tech_found_flag}=    Set Variable    False
                            #     ${Last}=    Set Variable    False
                            # END
                        ELSE
                            ${Tech_found_flag}=    Set Variable    False
                            ${Last}=    Set Variable    False
                        END
                    EXCEPT
                        ${Tech_found_flag}=    Set Variable    False
                        ${Last}=    Set Variable    False
                    END
                END
            END
            IF    "${Last}" == "False"
                #All Process
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
                                    ${Tech_found_flag}=    Set Variable    True
                                    ${AllFullname}=    Set Variable    True
                                    BREAK
                                ELSE
                                    ${Tech_found_flag}=    Set Variable    False
                                    ${AllFullname}=    Set Variable    False
                                END
                            # ELSE
                            #     ${Tech_found_flag}=    Set Variable    False
                            #     ${AllFullname}=    Set Variable    False
                            # END
                        ELSE
                            ${Tech_found_flag}=    Set Variable    False
                            ${AllFullname}=    Set Variable    False
                        END
                    EXCEPT
                        ${Tech_found_flag}=    Set Variable    False
                        ${AllFullname}=    Set Variable    False
                    END
                END
            END
        END
    ELSE
        Append To File    ${Log}    Fuse application not found for Tech search \n
        Log To Console    Fuse application not found for Tech search
    END

    RETURN    ${Tech_found_flag}
