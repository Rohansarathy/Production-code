*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     OperatingSystem
Library     String


*** Keywords ***
Employee_search
    [Arguments]    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Log}

    Log To Console    *********************Employee_Search*********************.
    Append To File    ${Log}    *********************Employee_Search***********************\n
    ${handles}    Get Window Titles
    Switch window    ${handles}[0]
    Sleep    2s
    ${Firstname}    Strip String    ${Alldatas}[tech_first_name]
    ${Lastname}    Strip String    ${Alldatas}[tech_last_name]
    ${first_name}    Convert To Lower Case    ${Firstname}
    ${last_name}    Convert To Lower Case    ${Lastname}
    IF    "${Alldatas}[tech_middle_name]" != " " and "${Alldatas}[tech_middle_name]" != "None" and "${Alldatas}[tech_middle_name]" != ""
        ${Middlename}    Strip String    ${Alldatas}[tech_middle_name]
        ${middle_name}    Convert To Lower Case    ${Middlename}
        ${db_full_name}    Set Variable    ${first_name} ${middle_name} ${last_name}
        Log To Console    db_full_name1=${db_full_name}
    ELSE
        ${db_full_name}    Set Variable    ${first_name} ${last_name}
        ${db_full_name1}    Set Variable    ${first_name} none ${last_name}
        Log To Console    db_full_name2=${db_full_name}
        Log To Console    db_full_name2=${db_full_name1}
    END
    Click Element If Visible    (//i[@class='uk-icon-users'])[3]
    Wait Until Element Is Visible    //*[@id="fname"]    20s
    Input Text When Element Is Visible    //*[@id="fname"]    ${Firstname}
    Input Text When Element Is Visible    //*[@id="lname"]    ${Lastname}
    Select From List By Value    //*[@id="statusOptions"]    1
    Select From List By Value    //*[@id="search-days"]    0
    Sleep    1s
    Click Element If Visible    //*[@id="searchBtn-desktop"]
    Sleep    10s
    Click Element If Visible    //*[@id="searchBtn-desktop"]
    Sleep    3s
    Wait Until Element Is Visible    //div[@class='data-table']    20s
    ${no_records_visible1}    Run Keyword And Return Status
    ...    Element Should Be Visible
    ...    //li[contains(text(), 'No records to show.')]
    ...    5s
    Append To file    ${Log}    no_records_visible1=${no_records_visible1}.\n
    IF    ${no_records_visible1} == True
        Click Element If Visible    //*[@id="searchBtn-desktop"]
        Sleep    4s
        Wait Until Element Is Visible    //div[@class='data-table']    20s
        ${no_records_visible2}    Run Keyword And Return Status
        ...    Element Should Be Visible
        ...    //li[contains(text(), 'No records to show.')]
        ...    5s
        Append To file    ${Log}    no_records_visible2=${no_records_visible2}.\n
        Log To Console    no_records_visible2=${no_records_visible2}
    ELSE
        ${no_records_visible2}    Set Variable    False
    END
    IF    ${no_records_visible2} == False
        ${li_elements}    Get WebElements    //div[@class='data-table']//li
        ${row_count}    Get Length    ${li_elements}
        Log To Console    1.Number of <li> Elements Found: ${row_count}
        Append To file    ${Log}    1.Number of <li> Elements Found: ${row_count}.\n
        IF    ${row_count} >= 2
            Click Element If Visible    //*[@id="searchBtn-desktop"]
            Sleep    4s
            Wait Until Element Is Visible    //div[@class='data-table']    20s
            ${li_elements}    Get WebElements    //div[@class='data-table']//li
            ${row_count}    Get Length    ${li_elements}
            Log To Console    2.Number of <li> Elements Found: ${row_count}
            Append To file    ${Log}    2.Number of <li> Elements Found: ${row_count}.\n
        END
        FOR    ${index}    IN RANGE    1    ${row_count + 1}
            Log To Console    index=${index}
            TRY
                Wait Until Element Is Visible    (//div[@class='data-table']//li)[${index}]    3s
                ${applicant_name}    Get Text
                ...    (//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span
                Log To Console    applicant_name=${applicant_name}
                ${applicant_name}    Strip String    ${applicant_name}
                ${applicant_name}    Convert To Lower Case    ${applicant_name}
                Log To Console    ${applicant_name} == ${db_full_name}
                Log To Console    ${applicant_name} == ${db_full_name1}
            EXCEPT
                Log To Console    No records to show
                ${applicant_name}    Set Variable    None
                ${record_flag}    Set Variable    False
            END
            IF    '${applicant_name}' == '${db_full_name}' or '${applicant_name}' == '${db_full_name1}'
                Log To Console    Tech search Found
                ${Picture}    Get Text    (//div[@class='data-table']//li)[${index}]//td[4]
                Log To Console    Picture=${Picture}
                ${Progress}    Get Text    (//div[@class='data-table']//li)[${index}]//td[5]
                Log To Console    Progress=${Progress}
                Append To file    ${Log}    Picture=${Picture}.\n
                IF    "${Progress}" == "IN PROGRESS"
                    Click Element If Visible
                    ...    (//div[@class='data-table']//li)[${index}]//td[contains(@class, 'dashtb-td')]/span
                    Wait Until Element Is Visible
                    ...    //li[${index}]//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color']
                    ...    5s
                    ${status}    Get Text
                    ...    //li[${index}]//i[contains(@class, 'uk-icon-star')]//span[@class='uk-content-label-18-danger-color']
                    Log To Console    status= ${status}
                    IF    "${status}" == "INACTIVE"
                        ${Tech_flag}    Set Variable    True
                        ${Not_certified}    Get Text
                        ...    //li[${index}]//i[contains(@class, 'uk-icon-certificate') and contains(@class, 'uk-icon-small') and contains(@class, 'icon-gold')]/span[contains(@class, 'uk-content-label-18-danger-color')]
                        IF    "${Not_certified}" == "Not Currently Certified - PENDING"
                            ${non_certified}    Set Variable    True
                            Log To Console    non_certified= ${non_certified}
                            ${record_flag}    Set Variable    True
                        ELSE
                            ${record_flag}    Set Variable    False
                            Append To file
                            ...    ${Log}
                            ...    Record found in Employee control center but Not_certified is ${Not_certified}.\n
                            Log To Console
                            ...    Record found in Employee control center but Not_certified is ${Not_certified}.
                        END
                    ELSE
                        ${record_flag}    Set Variable    False
                        Append To file    ${Log}    Record found in Employee control center but status is ${status}.\n
                        Log To Console    Record found in Employee control center but status is ${status}.
                    END
                ELSE
                    ${record_flag}    Set Variable    False
                    Append To file    ${Log}    Record found in Employee control center but it is in ${Progress}.\n
                    Log To Console    Record found in Employee control center but it is in ${Progress}.
                END
            ELSE
                ${record_flag}    Set Variable    False
                Append To file    ${Log}    Record found in Employee control but name mismatch(${applicant_name}).\n
                Log To Console    Record found in Employee control center but name mismatch(${applicant_name}).
            END
        END
    ELSE
        ${record_flag}    Set Variable    False
        Append To file    ${Log}    No record found in Employee control center.\n
        Log To Console    No record found in Employee control center.
    END
    RETURN    ${record_flag}
