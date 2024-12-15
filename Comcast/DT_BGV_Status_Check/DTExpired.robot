*** Settings ***
Library     DateTime
Resource    Fuselogin.robot
Library     RPA.Windows
Library     DatabaseLibrary
Library     OperatingSystem
Library     String
Library     Teams_Fail.py
Library     Sendmail


*** Variables ***
${Fullname}     ${EMPTY}
${First}        ${EMPTY}
${Last}         ${EMPTY}
${Last2}        ${EMPTY}


*** Keywords ***
DT_Expired
    [Arguments]
    ...    ${Alldatas}
    ...    ${credentials}
    ...    ${doc}
    ...    ${Body1}
    ...    ${Body2}
    ...    ${DTLog}
    ...    ${Firstname}
    ...    ${Lastname}
    
    Log To Console    DT Expired Fuse update initiating
    Append To File    ${DTLog}    DT Expired Fuse update initiating.\n
    ${handles}=    Get Window Titles
    Switch window    ${handles}[1]
    ${F_Login_}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="topicons"]/ul/li[5]/a
    ...    30s
    IF    ${F_Login_} == True
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

        ${Firstname}=    Strip String    ${Alldatas}[first_name]
        ${Lastname}=    Strip String    ${Alldatas}[last_name]
        ${first_name}=    Convert To Lower Case    ${Firstname}
        ${last_name}=    Convert To Lower Case    ${Lastname}
        ${db_full_name}=    Set Variable    ${first_name} ${last_name}
        ${Date2}=    Get Time
        ${Today_date}=    Set Variable    ${Date2[0:10]}
        IF    "${Alldatas}[tax_term]" == "1099"
            Wait Until Element Is Visible    //*[@id="myNavbar"]/ul/li[8]/a    5s
            Click Element If Visible    //*[@id="myNavbar"]/ul/li[8]/a
            Wait Until Element Is Visible    //li/a[@href='/onb/contractor_recruiting.php']    5s
            Click Element If Visible    //li/a[@href='/onb/contractor_recruiting.php']
            Sleep    2s
            # In Process
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    4s
            Wait Until Element Is Visible    //*[@id="exampleRecruits_filter"]/label/input    10s
            Input Text
            ...    //*[@id="exampleRecruits_filter"]/label/input
            ...    ${db_full_name}
            Sleep    5s
            Click Button    (//*[@id="refresh_dt"])[1]
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
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Firstname}
                Sleep    5s
                Click Button    (//*[@id="refresh_dt"])[1]
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
                Input Text    //*[@id="exampleRecruits_filter"]/label/input    ${Lastname}
                Sleep    5s
                Click Button    (//*[@id="refresh_dt"])[1]
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
                Input Text
                ...    //*[@id="exampleRecruits_filter"]/label/input
                ...    ${db_full_name}
                Sleep    5s
                Click Button    (//*[@id="refresh_dt"])[1]
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
            # In Process
            Click Element If Visible    //*[@id="frm_filter_data"]/div[1]/span/label/div
            Sleep    10s
            Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
            Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
            Sleep    10s
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
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Firstname}
                Sleep    10s
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
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${Lastname}
                Sleep    10s
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
                Sleep    10s
                Wait Until Element Is Visible    //*[@id="exampleImport_filter"]/label/input    10s
                Input Text    //*[@id="exampleImport_filter"]/label/input    ${db_full_name}
                Sleep    10s
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
            ...    Bot failed to update the DT expired status in Fuse due to Tech name mismatch for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly update Manually.
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
                Append To file    ${DTLog}    Mail sent for DT expired status not update in Fuse.\n
                Log To Console    Mail sent DT expired status not update in Fuse.
            ELSE
                Append To file    ${DTLog}    Mail not sent for DT expired status not update in Fuse.\n
                Log To Console    Mail not sent DT expired status not update in Fuse.
            END
        END
        TRY
            ${Time}=    Get Time
            ${eta}=    set Variable    ${Time}[5:7]/${Time}[8:10]/${Time}[:4]
            Wait Until Element Is Visible    //*[@id="return_of_drug_test1"]    20s
            Input Text When Element Is Visible    //*[@id="return_of_drug_test1"]    ${eta}
            Sleep    2s
            # Notes Update
            IF    "${Alldatas}[tax_term]" == "w2"
                # ************DT************
                Wait Until Element Is Visible
                ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[6]/td[2]/label[2]/div
                ...    10s
                Click Element If Visible
                ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[6]/td[2]/label[2]/div
                Sleep    1s
                Input Text When Element Is Visible    //*[@id="notes"]    DT Expired# Hence Removed.
                Sleep    1s
                Log To Console    DT Expired# Hence Removed.
                Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                Sleep    1s
                IF    "${Time}[11:13]" == "${credentials}[FuseUpdateTime]"
                    IF    "${Alldatas}[dt_status_time_check]" != "BGV_updated" and "${Alldatas}[dt_status_time_check]" != "DT_BGV_updated"
                        Log To Console    BGV Status_update in fuse
                        IF    "${Alldatas}[bgv_status]" == "pending"
                            Input Text When Element Is Visible    //*[@id="notes"]    BGV pending with HireRight
                            Sleep    1s
                            Click Element If Visible    //*[@id="addnewnotform"]/table/tbody/tr/td[3]/input
                            Append To File    ${DTLog}    BGV pending status daily updating\n
                            Sleep    1s
                        END
                    END
                END
                TRY
                    # Submit
                    Append To File    ${DTLog}    Click Submit.\n
                    Wait Until Element Is Visible
                    ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
                    ...    30s
                    Click Element If Visible
                    ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td/input[2]
                    Sleep    2s
                    Handle Alert    ACCEPT
                    Sleep    2s
                EXCEPT
                    Append To File    ${DTLog}    Fuse Submitted.\n
                END
            ELSE
                # ************DT************
                Click Element If Visible
                ...    //*[@id="update_all_data_form"]/div[1]/div[1]/table/tbody/tr[7]/td[2]/label[2]/div
                Sleep    1s
                Input Text When Element Is Visible    //*[@id="Notedb"]    DT Expired# Hence Removed.
                Sleep    1s
                Click Element If Visible
                ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                IF    "${Time}[11:13]" >= "${credentials}[FuseUpdateTime]"
                    IF    "${Alldatas}[dt_status_time_check]" != "BGV_updated" and "${Alldatas}[dt_status_time_check]" != "DT_BGV_updated"
                        Log To Console    BGVStatus_update
                        IF    "${Alldatas}[bgv_status]" == "pending"
                            Input Text When Element Is Visible    //*[@id="Notedb"]    BGV pending with HireRight
                            Sleep    1s
                            Click Element If Visible
                            ...    //*[@id="dbcheck_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[3]/input
                            Append To File    ${DTLog}    BGV pending status daily updating\n
                            Sleep    1s
                        END
                    END
                END
                TRY
                    # Submit
                    Append To File    ${DTLog}    Click Submit.\n
                    Wait Until Element Is Visible
                    ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
                    ...    30s
                    Click Element If Visible
                    ...    //*[@id="update_all_data_form"]/div[2]/div[2]/table/tbody/tr/td[1]/input
                    Sleep    2s
                    Handle Alert    ACCEPT
                    Sleep    2s
                EXCEPT
                    Append To File    ${DTLog}    Fuse Submitted.\n
                END
            END
            Append To File    ${DTLog}    DT Expired Updated in Fuse.\n
            Log To Console    DT Expired Updated in Fuse.
            TRY
                Click Element If Visible    //*[@id="manage_modal"]/div/div/div[1]/button
            EXCEPT
                Log To Console    closed
            END
        EXCEPT
            Append To file    ${DTLog}    Fuse update failed.\n
            Log To Console    Fuse update failed.
            ${Body}=    Set Variable
            ...    Bot failed to update the DT ("Expired") status in Fuse for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly check.
            ${Body1}=    Set Variable  
            ${Body2}=    Set Variable   
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
                Append To file    ${DTLog}    Mail sent for DT expired status not update in Fuse.\n
                Log To Console    Mail sent DT expired status not update in Fuse.
            ELSE
                Append To file    ${DTLog}    Mail not sent for DT expired status not update in Fuse.\n
                Log To Console    Mail not sent DT expired status not update in Fuse.
            END
        END
    END
