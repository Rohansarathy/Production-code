*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     DateTime
Library     RPA.Desktop
Library     OperatingSystem
Library     String
Library     Collections
Library     DatabaseLibrary
Library    RPA.JavaAccessBridge
Library    RPA.Windows


*** Variables ***
@{days}                 Monday    Tuesday    Wednesday    Thursday    Friday
${Duplicates_Flag}      ${EMPTY}
${Clinic_flag}          ${EMPTY}
${Clinic_flag2}         ${EMPTY}
${TechMiles}            ${EMPTY}
   

*** Keywords ***
Initiation
    [Arguments]    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Epass_name}    ${Log}    ${image}

    ${handles}=    Get Window Titles
    Switch window    ${handles}[0]

    TRY
        ${certification_found}=    Run Keyword And Return Status
        ...    Element Should Be Visible
        ...    //div[@class='panel-body']/h3
        ...    10s
        IF    "${certification_found}" == "True"
            Click Element If Visible    //*[@id="Accept"]
            Log To Console    Certification of Permissible
        END
    EXCEPT
        Log To Console    Certificate not found
    END
    ${Infomart_Login1}=    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //*[@id="request-list-wrapper"]/div[1]/div/div[2]/div[3]/div/div/div[2]/div
    ...    5s
    IF    ${Infomart_Login1} == True
        ${element}=    Get WebElement    xpath=//a[@id='main_nav_new_req']
        ${href}=    Call Method    ${element}    get_attribute    href
        Go To    url=${href}
        Sleep    3s

        Log To Console    process=${Alldatas}[process]
        IF    "${Alldatas}[process]" == "pre_employment" or "${Alldatas}[process]" == "supervisor_request"
            Wait Until Element Is Visible    //button[@data-id='appl-info-request-purpose']
            Click Element If Visible    //button[@data-id='appl-info-request-purpose']
            Wait Until Element Is Visible    //ul[@class='dropdown-menu inner']
            Click Element If Visible    xpath=//li//a[span[text()='Pre-Employment']]
        ELSE
            Wait Until Element Is Visible    //button[@data-id='appl-info-request-purpose']
            Click Element If Visible    //button[@data-id='appl-info-request-purpose']
            Wait Until Element Is Visible    //ul[@class='dropdown-menu inner']
            Click Element If Visible    xpath=//li//a[span[text()='Annual Drug Test']]
        END
        Wait Until Element Is Visible    //*[@id="appl-info-request-ssn"]
        Input Text    //*[@id="appl-info-request-ssn"]    ${Alldatas}[ssn]
        Sleep    5s
        ${Profile_found}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="dialog-content"]
        ...    3s
        IF    "${Profile_found}" == "True"
            ###########################Popup check##################################
            ${text}    RPA.Browser.Selenium.Get Text    //*[@id="dialog-content"]
            ${matches}=    Get Regexp Matches    ${text}    Created By:\s*(.+)
            ${Created_By}=    Evaluate    "${matches}".strip("[]").strip("'")
            Log To Console    Created_BY Matches: ${Created_By}
            # IF    "${Created_By}" == "Created By: ybot"
            #     ${Created_By}=    Set Variable    True
            #     Log To Console    Created Ybot name is Match
            # ELSE
            #     ${Created_By}=    Set Variable    False
            #     Log To Console    Created Ybot name mismatch
            # END
            ${Created_On}=    Get Regexp Matches    ${text}    (\\d{1,2}/\\d{1,2}/\\d{4})
            ${Created_On}=    Evaluate    "${Created_On}".strip("[]").strip("'")
            Log To Console    date=${Created_On}
            ${current_date}=    Get Current Date    result_format=%m/%d/%Y
            Log To Console  Current Date: ${current_date}
            IF    "${Created_By}" == "Created By: ybot" and "${Created_On}" == "${current_date}"
                ${Load_flag}    Set Variable    True
                Log To Console    "Created date matches current date: ${current_date}"
            ELSE
                ${Load_flag}    Set Variable    False
                Log To Console    "Created date does not match current date: ${Created_On} != ${current_date}"
            END
            #########################################################################
        # IF    "${Profile_found}" == "True"
            IF    "${Alldatas}[process]" == "pre_employment"
                IF    "${Load_flag}" == "True"
                    Log To Console    Bot created on ${current_date}, Click load
                    Click Element If Visible    //button[text()='Load']
                    ${Proceed_Flag}    Set Variable    True
                ELSE
                    IF    "${Alldatas}[dt_confirmation_number]" == "AlreadyExists" and "${Alldatas}[rescheduled]" == "reload"
                        Click Element If Visible    //button[text()='Load']
                        ${AlreadyExists}    Set Variable    False
                        ${Proceed_Flag}    Set Variable    True
                    ELSE
                        Click Element If Visible    //button[text()='Cancel']
                        Log To Console    Load the entry=${Profile_found}
                        ${AlreadyExists}    Set Variable    True
                        ${Proceed_Flag}    Set Variable    False
                    END
                END
            ELSE
                Click Element If Visible    //button[text()='Load']
                ${AlreadyExists}    Set Variable    False
                ${Proceed_Flag}    Set Variable    True
            END
        ELSE
            ${Proceed_Flag}    Set Variable    True
            ${AlreadyExists}    Set Variable    False
        END
        Log To Console    Proceed_Flag=${Proceed_Flag}
        IF    "${Proceed_Flag}" == "True"
            ${AlreadyExists}=    Set Variable    False
            IF    "${Alldatas}[process]" == "pre_employment" or "${Alldatas}[process]" == "supervisor_request"
                Wait Until Element Is Visible    //button[@data-id='appl-info-request-purpose']
                Click Element If Visible    //button[@data-id='appl-info-request-purpose']
                Wait Until Element Is Visible    //ul[@class='dropdown-menu inner']
                Click Element If Visible    xpath=//li//a[span[text()='Pre-Employment']]
            ELSE
                Wait Until Element Is Visible    //button[@data-id='appl-info-request-purpose']
                Click Element If Visible    //button[@data-id='appl-info-request-purpose']
                Wait Until Element Is Visible    //ul[@class='dropdown-menu inner']
                Click Element If Visible    xpath=//li//a[span[text()='Annual Drug Test']]
            END
            Wait Until Element Is Visible    //input[@name='personal_first_name']    5s
            IF    "${Alldatas}[process]" == "pre_employment" or "${Alldatas}[process]" == "supervisor_request" or "${Alldatas}[process]" == "annual_drug_test"
                Input Text    //input[@name='personal_first_name']    ${Alldatas}[first_name]
                Sleep    1s
                Append To File    ${Log}    frist_name=${Alldatas}[first_name]\n
                IF    "${Alldatas}[middle_name]" != ""
                        Unselect Checkbox    //input[@type="checkbox" and @id="appl-info-request-no-middlename"]
                END
                IF    "${Alldatas}[middle_name]" == ""
                    Select Checkbox    //input[@type="checkbox" and @id="appl-info-request-no-middlename"]
                ELSE
                    Input Text    //input[@name='personal_middle_name']    ${Alldatas}[middle_name]
                    Append To File    ${Log}    middle_name${Alldatas}[middle_name]\n
                END
                Sleep    1s
                Input Text    //input[@name='personal_last_name']    ${Alldatas}[last_name]
                Append To File    ${Log}    ${Alldatas}[last_name]\n
                Sleep    1s
                Log To Console    suffix=${Alldatas}[suffix]
                IF    "${Alldatas}[suffix]" != ""
                    Click Element If Visible    (//span[@class='caret'])[4]
                    Click Element If Visible    //span[text()='${Alldatas}[suffix]']
                END
                ${Tech_DOB}=    Convert To String    ${Alldatas}[tech_dob]
                ${date_components}=    Split String    ${Tech_DOB}    -
                ${year}=    Get From List    ${date_components}    0
                ${month}=    Get From List    ${date_components}    1
                ${day}=    Get From List    ${date_components}    2
                Log To Console    ${month}/${day}/${year}
                ${tech_dob}=    Set Variable    ${month}/${day}/${year}
                TRY
                    Input Text    //input[@name='personal_dob']    ${tech_dob}
                EXCEPT
                    Input Text    //*[@id='personal_dob']    ${Alldatas}[tech_dob]
                    Log To Console    DOB=${Alldatas}[tech_dob]
                END
                Sleep    1s
                Input Text    //*[@id="appl-info-request-phone"]    ${Alldatas}[tech_phone_no]
                Sleep    1s
                Input Text    //*[@id="appl-info-request-email"]    ${Alldatas}[tech_mail_id]
                Sleep    1s
                Click Element If Visible    //*[@id="appl-info-field-wrapper-gender"]/div/div/button
                IF    "${Alldatas}[gender]" == "female"
                    Click Element If Visible    //*[@id="appl-info-field-wrapper-gender"]/div/div/div/ul/li[2]
                    Log To Console    Female
                ELSE
                    Click Element If Visible    //*[@id="appl-info-field-wrapper-gender"]/div/div/div/ul/li[3]
                    Log To Console    Male
                END
                Sleep    1s
                Input Text    //*[@id="appl-info-request-employment-location"]    ${Alldatas}[location_of_employment]
                IF    "${Alldatas}[tax_term]" == "1099" or "${Alldatas}[tax_term]" == "w2"
                    Input Text    //*[@id="appl-info-request-refnum"]    ${Alldatas}[company_name]
                    Log To Console    TaxTerm is 1099 or w2, provide input for companyName
                ELSE
                    TRY
                        RPA.Browser.Selenium.Execute JavaScript    document.querySelectorAll('#appl-info-request-refnum')[0].value = '';                  
                    EXCEPT
                        Set Focus To Element    //*[@id="appl-info-request-refnum"]
                        RPA.Browser.Selenium.Press Keys    //*[@id="appl-info-request-refnum"]    CTRL+A
                        Sleep    1s
                        RPA.Browser.Selenium.Press Keys    //*[@id="appl-info-request-refnum"]    DELETE
                        Sleep    1s
                        RPA.Browser.Selenium.Execute JavaScript    document.querySelectorAll('#appl-info-request-refnum')[0].value = ''; 
                        
                    END
                    Log To Console    No Company name found in the field.
                END
                Select Checkbox    //*[@id="appl-info-signed"]
            END
            Sleep    1s
            Click Element If Visible    //a[contains(@class, 'btn btn-primary pull-right form-submit-next')]
            Sleep    3s
            #########SelectService########
            Log To Console    SelectService
            Wait Until Element Is Visible
            ...    //*[@id="appl-services-form-package-selection"]/div[2]/div/div/div[1]/div/button
            ...    10s
            Click Element If Visible
            ...    //*[@id="appl-services-form-package-selection"]/div[2]/div/div/div[1]/div/button
            IF    "${Alldatas}[service_package]" == "driver"
                Click Element If Visible    //span[text()='+ Driver']
            ELSE
                Click Element If Visible    //span[text()='+ Non-Driver']
            END
            Sleep    1s
            Click Element If Visible    //a[contains(text(),'Next')]
            Sleep    2s
            #######################Address#######################
            IF    "${Alldatas}[process]" == "pre_employment" or "${Alldatas}[process]" == "supervisor_request" or "${Alldatas}[process]" == "annual_drug_test"
                Log To Console    address_type=${Alldatas}[address_type]
                IF    "${Alldatas}[address_type]" == "standard" or "${Alldatas}[address_type]" == "military"
                    IF    "${Alldatas}[address_type]" == "standard"
                        Click Element If Visible    (//span[@class='caret'])[1]
                        Click Element If Visible    //span[text()='Standard']
                        Sleep    1s
                        Append To File    ${Log}    address_type=${Alldatas}[address_type]\n
                    END
                    IF    "${Alldatas}[address_type]" == "military"
                        Click Element If Visible    (//span[@class='caret'])[1]
                        Click Element If Visible    //span[text()='Military']
                        Sleep    1s
                        Append To File    ${Log}    address_type=${Alldatas}[address_type]\n
                    END
                    Log To Console    tech_street_address_no=${Alldatas}[tech_street_address_no]
                    Wait Until Element Is Visible    //input[contains(@id, 'appl-prev-addr-street-num')]    10s
                    Input Text When Element Is Visible
                    ...    //input[contains(@id, 'appl-prev-addr-street-num')]
                    ...    ${Alldatas}[tech_street_address_no]
                    Append To File    ${Log}    tech_street_address_no=${Alldatas}[tech_street_address_no]
                    Sleep    1s

                    Log To Console    ${Alldatas}[pre_dir]
                    IF    "${Alldatas}[pre_dir]" != ""
                        Wait Until Element Is Visible    (//span[@class='caret'])[2]    5s
                        Click Element If Visible    (//span[@class='caret'])[2]
                        Wait Until Element Is Visible    (//ul[@class='dropdown-menu inner'])[2]    5s
                        Click Element If Visible    xpath=(//li//a[span[text()='${Alldatas}[pre_dir]']])[1]
                        Append To File    ${Log}    pre_dir=${Alldatas}[pre_dir]\n
                    END
                    IF    "${Alldatas}[pre_dir]" == ""
                        Click Element If Visible    (//span[@class='caret'])[2]
                        Click Element If Visible    (//span[text()='Pre Dir'])[1]
                        Append To File    ${Log}    pre_dir=${Alldatas}[pre_dir]\n
                    END
                    Sleep    1s
                    Log To Console    ${Alldatas}[tech_street_name]
                    Input Text When Element Is Visible    //*[@name="addr_street_name"]    ${Alldatas}[tech_street_name]
                    Append To File    ${Log}    tech_street_name=${Alldatas}[tech_street_name]\n
                    Sleep    1s

                    # Log To Console    ${Alldatas}[tech_street_suffix]
                    # ${suffix}    Set Variable    none
                    # Log To Console    suffix=${suffix}
                    ${string}=    set variable    ${Alldatas}[tech_street_suffix]
                    ${first_letter}=    Set Variable    ${string}[0]
                    ${first_letter_upper}=    Convert To Title Case    ${first_letter}
                    ${rest_of_string}=    Set Variable    ${string}[1:]
                    ${final_string}=    Set Variable    ${first_letter_upper}${rest_of_string}
                    Log To Console    ${final_string}
                    Append To File    ${Log}    tech_street_suffix=${final_string}\n
                    IF    "${final_string}" != "none"
                        Click Element If Visible    (//span[@class='caret'])[3]
                        Click Element If Visible    //span[text()='${final_string}']
                    END
                    IF    "${Alldatas}[tech_street_suffix]" == "none"
                        Click Element If Visible    (//span[@class='caret'])[3]
                        Click Element If Visible    (//span[text()='Street Ext'])[1]
                        Append To File    ${Log}    pre_dir=${Alldatas}[tech_street_suffix]\n
                    END

                    IF    "${Alldatas}[post_dir]" != ""
                        Wait Until Element Is Visible    (//span[@class='caret'])[4]    5s
                        Click Element If Visible    (//span[@class='caret'])[4]
                        Wait Until Element Is Visible    (//ul[@class='dropdown-menu inner'])[4]
                        Click Element If Visible    xpath=(//li//a[span[text()='${Alldatas}[post_dir]']])[2]
                        Append To File    ${Log}    post_dir=${Alldatas}[post_dir]\n
                    END
                    IF    "${Alldatas}[post_dir]" == ""
                        Wait Until Element Is Visible    (//span[@class='caret'])[4]    5s
                        Click Element If Visible    (//span[@class='caret'])[4]
                        Click Element If Visible    (//span[text()='Post Dir'])[1]
                    END
                    Sleep    1s
                    # Appt no
                    IF    "${Alldatas}[apt_no]" != ""
                        Input Text    //input[@name='addr_apt']    ${Alldatas}[apt_no]
                        Append To File    ${Log}    apt_no=${Alldatas}[apt_no]\n
                    END
                    IF    "${Alldatas}[apt_no]" == ""
                        Clear Element Text    //input[@name='addr_apt']
                        Log To Console    ${Alldatas}[apt_no]
                    END

                    Sleep    1s
                    Log To Console    ${Alldatas}[tech_zip_code]
                    Input Text    //input[@placeholder='ZIP/Postal Code']    ${Alldatas}[tech_zip_code]
                    Append To File    ${Log}    tech_zip_code=${Alldatas}[tech_zip_code]\n
                ELSE
                    Log To Console    ${Alldatas}[address_type]
                    IF    "${Alldatas}[address_type]" == "route_box"
                        Click Element If Visible    (//span[@class='caret'])[1]
                        Click Element If Visible    //span[text()='Route/Box']
                        Sleep    1s
                        Input Text    //input[@name='addr_route']    ${Alldatas}[rural_route]
                        Sleep    1s
                        Input Text    //input[@name='addr_po_box_number']    ${Alldatas}[po_box]
                        Sleep    1s
                        Input Text    //input[@placeholder='ZIP/Postal Code']    ${Alldatas}[tech_zip_code]
                        Append To File    ${Log}    address_type=${Alldatas}[address_type]\n
                    END
                END
            END
            Sleep    1s
            Click Element If Visible    //a[contains(text(),'Next')]
            Sleep    3s
            ###########################Criminal History######################
            Log To Console    Criminal History
            Wait Until Element Is Visible    //*[@id="appl-crim-zip-0"]    5s
            Input Text    //*[@id="appl-crim-zip-0"]    ${Alldatas}[tech_zip_code]
            Append To File    ${Log}    tech_zip_code=${Alldatas}[tech_zip_code]\n
            Sleep    2s
            ${Criminal_State}=    RPA.Browser.Selenium.Get Text
            ...    //*[@id="appl-crim-field-wrapper-state-0"]/div/div/button/span[1]
            Log To Console    Criminal_State=${Criminal_State}
            ${Techname}=    RPA.Browser.Selenium.Get Text    (//*[@class='crim-applicant-name-only'])[3]
            Log To Console    ${Techname}
            Click Element If Visible    //a[contains(text(),'Next')]
            Sleep    3s
            ###########################Federal Criminal History######################
            Log To Console    Federal Criminal History
            Wait Until Element Is Visible    //*[@id="appl-crim-zip-0"]    5s
            Input Text    //*[@id="appl-crim-zip-0"]    ${Alldatas}[tech_zip_code]
            Append To File    ${Log}    tech_zip_code=${Alldatas}[tech_zip_code]\n
            Sleep    2s
            ${Fedral_State}=    RPA.Browser.Selenium.Get Text
            ...    //*[@id="appl-crim-field-wrapper-state-0"]/div/div/button/span[1]
            Log To Console    Fedral_State=${Fedral_State}
            Click Element If Visible    //a[contains(text(),'Next')]
            Sleep    2s
            ###########################Motor Vehicle Reports######################
            
            IF    "${Alldatas}[process]" == "pre_employment" or "${Alldatas}[process]" == "supervisor_request" or "${Alldatas}[process]" == "annual_drug_test"
                IF    "${Alldatas}[service_package]" == "driver"
                    Log To Console   Driver is selected
                    Wait Until Element Is Visible    //input[@name='mvr_license_number']    5s
                    Input Text    //input[@name='mvr_license_number']    ${Alldatas}[license_number]
                    Append To File    ${Log}    license_number=${Alldatas}[license_number]\n
                    Sleep    1s
                    Click Element If Visible    //span[@class='caret']
                    Sleep    1s
                    ${tech_state1}=    Set Variable    ${Alldatas}[license_state]
                    ${tech_state1}=    Replace String    ${tech_state1}    _    ' '
                    ${Cleaned_String1}=    Replace String    ${tech_state1}    '    ${EMPTY}
                    ${tech_state1}=    Convert To Title Case    ${Cleaned_String1}
                    Log To Console    license_state=${tech_state1}
                    ${state_name}=    Set Variable    ${tech_state1}
                    IF    "${tech_state1}" == "District Of Columbia"
                        ${state_name}=    Replace String    ${tech_state1}    Of    of
                    END
                    ${Alldatas}[license_state]=    Set Variable    ${state_name}
                    Log To Console    license_state=${Alldatas}[license_state]
                    Click Element If Visible    //span[text()='${Alldatas}[license_state]']

                    IF    "${Alldatas}[commercial_license]" != ""
                        Select Checkbox    //input[@name='mvr_commercial_driver']
                    END
                    IF    "${Alldatas}[commercial_license]" != 'yes'
                        Unselect Checkbox    //input[@name='mvr_commercial_driver']
                    END
                    Log To Console    Non-Driver is selected
                    Wait Until Element Is Visible    //a[contains(text(),'Next')]    5s
                    Click Element If Visible    //a[contains(text(),'Next')]
                    Sleep    3s
                END
                
            END
            
            ##############################Occupational Health###################################
            Log To Console    Process=${Alldatas}[process]
            
            IF    "${Alldatas}[process]" == "pre_employment" or "${Alldatas}[process]" == "supervisor_request"
                    Wait Until Element Is Visible    //span[@class='caret']
                    Click Element If Visible    //span[@class='caret']
                    Wait Until Element Is Visible    //ul[@class='dropdown-menu inner']
                    Click Element If Visible    xpath=//li//a[span[text()='Pre-Employment']]
                    Append To File    ${Log}    Process=${Alldatas}[process]\n
            ELSE
                    Wait Until Element Is Visible    //span[@class='caret']
                    Click Element If Visible    //span[@class='caret']
                    Wait Until Element Is Visible    //ul[@class='dropdown-menu inner']
                    Click Element If Visible    xpath=//li//a[span[text()='Annual']]
                    Append To File    ${Log}    Process=${Alldatas}[process]\n
            END
            Select Checkbox    //*[@id="appl-info-drug-safety-sensitive"]
            Click Element If Visible    //a[contains(text(),'Next')]
            Sleep    3s
            #############################Review&Submit#########################
            Log To Console    Review&Submit
            Click Element If Visible    //a[text()='Submit Request']
            Append To File    ${Log}    Review&Submit clicked\n
            Sleep    3s

            ############Active Request ###############
            # ${Update Applicant Information:}=    Run Keyword And Return Status
            # ...    Element Should Be Visible
            # ...    //*[@class='finish-container-header']
            # ...    10s
            # IF    "${Update Applicant Information:}" == "True"
            #    Select Radio Button    radio    //*[@id='applist-dob']
            #    Click Element    //a[text()='Continue']
            #    Log To Console    Update Applicant Information:
            #    Append To File    ${Log}    Active request\n
            # END
            # Sleep    30s
            ############################FInished Request######################
            Log To Console    Finished Request
            Click Element If Visible    //button[text()='Schedule Now']
            Append To File    ${Log}    ScheduleButton Clicked\n
            Sleep    5s
            ########################################################DT-Initiation##################################################
            Append To File
            ...    ${Log}
            ...    *****************************DT Initiation Start******************************\n
            ${handles}=    Get Window Titles
            Switch window    ${handles}[2]
            Sleep    3s
            # ****REASON FOR TEST - DRUG TESTING****
            Log To Console    REASON FOR TEST - DRUG TESTING INITIATION
            Wait Until Element Is Visible    //*[@id="pnlDrugTest"]/div    20s
            Select Radio Button    rdReason    rdPreEmp
            Sleep    1s

            # **********************Drug Test*************************
            Wait Until Element Is Visible    //*[@id="chkService3"]
            Select Checkbox    //*[@id="chkService3"]

            # ****DONOR Details****
            Input Text When Element Is Visible    //*[@id="txtFirstName"]    ${Alldatas}[first_name]
            Input Text When Element Is Visible    //*[@id="txtMiddleName"]    ${Alldatas}[middle_name]
            Input Text When Element Is Visible    //*[@id="txtLastName"]    ${Alldatas}[last_name]
            Log To Console    ${Alldatas}[ssn]
            ${SSN}=    Convert To String    ${Alldatas}[ssn]
            ${SSN1}=    Evaluate    "${SSN}[0:3]"
            ${SSN2}=    Evaluate    "${SSN}[3:5]"
            ${SSN3}=    Evaluate    "${SSN}[5:]"
            Log To Console    ${SSN1},${SSN2},${SSN3}
            ${ssn}=    RPA.Browser.Selenium.Get Text    //*[@id="txtSSN3"]
            IF    "${ssn}" == "${SSN3}"
                Log To Console    SSN match
            ELSE
                Log To Console    SSN not match
            END
            # Input Text When Element Is Visible    //*[@id="txtSSN1"]    ${SSN1}
            # Input Text When Element Is Visible    //*[@id="txtSSN2"]    ${SSN2}
            # Input Text When Element Is Visible    //*[@id="txtSSN3"]    ${SSN3}
            # Log To Console    ${SSN1},${SSN2},${SSN3}

            Log To Console    ${Alldatas}[tech_dob]
            ${Tech_DOB}=    Convert To String    ${Alldatas}[tech_dob]
            ${date_components}=    Split String    ${Tech_DOB}    -
            ${DOBYear}=    Get From List    ${date_components}    0
            ${DOBMonth}=    Get From List    ${date_components}    1
            ${DOBDay}=    Get From List    ${date_components}    2
            Log To Console    ${DOBMonth},${DOBDay},${DOBYear}
            Input Text When Element Is Visible    //*[@id="txtMonthUSeiDateOfBirth"]    ${DOBMonth}
            Input Text When Element Is Visible    //*[@id="txtDayUSeiDateOfBirth"]    ${DOBDay}
            Input Text When Element Is Visible    //*[@id='txtYearUSeiDateOfBirth']    ${DOBYear}
            Log To Console    ${Alldatas}[tech_phone_no]

            ${Tech_Phone_No}=    Convert To String    ${Alldatas}[tech_phone_no]
            ${PH1}=    Get Substring    ${Tech_Phone_No}    0    3
            ${PH2}=    Get Substring    ${Tech_Phone_No}    3    6
            ${PH3}=    Get Substring    ${Tech_Phone_No}    6    10
            Log To Console    ${PH1},${PH2},${PH3}
            Input Text When Element Is Visible    //*[@id='txtAreaCodeUSeiDayPhone']    ${PH1}
            Input Text When Element Is Visible    //*[@id='txtPrefixUSeiDayPhone']    ${PH2}
            Input Text When Element Is Visible    //*[@id='txtStationCodeUSeiDayPhone']    ${PH3}
            Input Text When Element Is Visible    //*[@id="txtEmaileiEmail"]    ${Alldatas}[tech_mail_id]

            Click Element If Visible    //*[@id="cmdNext2"]
            Sleep    1s
            ${duplicates}=    RPA.Browser.Selenium.Get Text    //*[@id="lblTitle"]
            IF    "POSSIBLE DUPLICATES" == "${duplicates}"
                Execute Sql String
                ...    UPDATE cox_onboarding SET dt_confirmation_number = 'POSSIBLE DUPLICATES' WHERE SSN = '${Alldatas}[ssn]'
                ${Duplicates_Flag}=    Set Variable    True
                ${Clinic_flag}=    Set Variable    False
                ${Clinic_flag2}=    Set Variable    False
                RETURN    ${Duplicates_Flag}    ${Clinic_flag2}    ${Clinic_flag}
            ELSE
                ${Duplicates_Flag}=    Set Variable    False
                TRY
                    RPA.Browser.Selenium.Execute JavaScript    document.querySelector('#txtAddress').value = '';
                    RPA.Browser.Selenium.Execute JavaScript    document.querySelector('#txtCity').value = '';
                    Sleep    1s
                    Append To File    ${Log}    Javascript
                EXCEPT
                    Set Focus To Element    //*[@id="txtAddress"]
                    RPA.Browser.Selenium.Press Keys    //*[@id="txtAddress"]    CTRL+A
                    Sleep    1s
                    RPA.Browser.Selenium.Press Keys    //*[@id="txtAddress"]    DELETE
                    Sleep    1s
                    RPA.Browser.Selenium.Execute JavaScript    document.querySelector('#txtAddress').value = '';
                    
                    Set Focus To Element    //*[@id="txtCity"]
                    RPA.Browser.Selenium.Press Keys    //*[@id="txtCity"]    CTRL+A
                    Sleep    1s
                    RPA.Browser.Selenium.Press Keys    //*[@id="txtCity"]    DELETE
                    Sleep    1s
                    RPA.Browser.Selenium.Execute JavaScript    document.querySelector('#txtCity').value = '';
                    Append To File    ${Log}    Press keys
                END
                TRY
                    Select From List By Index    //select[@name='ddlStateUSeiState']    0
                    Log To Console    Index
                    Append To File    ${Log}    Index 
                EXCEPT
                    Click Element If Visible    //select[@name='ddlStateUSeiState']
                    Click Element If Visible    //*[@id="ddlStateUSeiState"]/option[1]
                    Log To Console    Click
                    Append To File    ${Log}    Click
                END
                Sleep    1s
                Log To Console    Search for clinic
                # ****Search for clinic****
                Append To File    ${Log}    clinic_zip_code=${Alldatas}[clinic_zip_code]
                Log To Console    clinic_zip_code=${Alldatas}[clinic_zip_code]
                Wait Until Element Is Visible    //*[@id="txtZipeiZipCode"]    30s
                Input Text When Element Is Visible    //*[@id="txtZipeiZipCode"]    ${Alldatas}[clinic_zip_code]
                Input Text When Element Is Visible    //*[@id="txtDistanceUSeiDistance"]    ${credentials}[Distance]
                Click Element If Visible    //*[@id="cmdSearch"]
                Sleep    5s

                ${Clinic_search}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="pnlClinicExcellence"]
                ...    10s
                Append To File    ${Log}    Clinic_search=${Clinic_search}\n
                Log To Console    Clinic_search=${Clinic_search}
                IF    ${Clinic_search} != True
                    # ${notfound}=    RPA.Browser.Selenium.Get Text    //*[@id="lblNothingFound"]
                    Log To Console    No clinics found
                    Append To File    ${Log}    No clinics found\n
                    # ${Clinic_flag2}=    Set Variable    False
                    ${Clinic_flag}=    Set Variable    False
                    Execute Sql String
                    ...    UPDATE cox_onboarding SET dt_confirmation_number = 'No clinics found' WHERE SSN = '${Alldatas}[ssn]'
                    RETURN    ${Duplicates_Flag}    ${Clinic_flag}
                ELSE
                    ${Clinic_flag2}=    Set Variable    True
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
                        ${GetMiles}=    RPA.Browser.Selenium.Get Text    //*[@id="gvClinicResult_${ctl}_lblDistance"]
                        ${Miles}=    Split String    ${GetMiles}
                        ${TechMiles}=    Get From List    ${Miles}    0
                        Log To Console    ${TechMiles} > ${credentials}[Distance]
                        IF    ${TechMiles} > ${credentials}[Distance]
                            ${MilesFlag}=    Set Variable    False
                        ELSE
                            ${MilesFlag}=    Set Variable    True
                        END
                        ###########################################
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
                        ################################################
                        # ****Check for available Hours****
                        Sleep    2s
                        Log to Console    ****Check for available Hours****
                        Click Element If Visible    (//*[text()='Show Details'])[${clinic_index}]
                        Sleep    2s
                        FOR    ${day}    IN    @{days}
                            ${hours}=    RPA.Browser.Selenium.Get Text
                            ...    xpath=//*[@id="gvClinicResult_${ctl}_lbl${day}"]
                            ${class}=    Get Element Attribute
                            ...    xpath=//*[@id="gvClinicResult_${ctl}_lbl${day}"]
                            ...    class
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
                            Append To File    ${Log}    TechMiles = ${TechMiles}\n
                            BREAK
                        END
                    END
                    IF    ${Clinic_flag} == True
                        # ****Confirm Schedule event****
                        Log To Console    Confirm Schedule event
                        Input Text    //input[@name='txtTime']    ${Alldatas}[eta_days]

                        Sleep    3s
                        IF    "${Alldatas}[business_days]" == "business_days"
                            Click Element If Visible    //*[@id="selTimeType"]
                            Select From List By Value    //*[@id="selTimeType"]    1
                        ELSE
                            Click Element If Visible    //*[@id="selTimeType"]
                            Select From List By Value    //*[@id="selTimeType"]    3
                        END
                        Log To Console    Notification
                        # ****Notification****
                        Select Checkbox    //*[@id="chkEmailCompleted"]
                        Select Checkbox    //*[@id="chkEmailFails"]
                        Select Checkbox    //*[@id="chkEmail2Hours"]
   
                        Input Text When Element Is Visible
                        ...    //*[@id="spanMultipleEmaileiMultiEmailAddress"]
                        ...    ${Alldatas}[supplier_mail];${Alldatas}[hr_coordinator];${credentials}[ybotID]

                        ${OffPhNo}=    Convert To String    ${credentials}[OffPhNo]
                        ${BN1}=    Get Substring    ${OffPhNo}    0    3
                        ${BN2}=    Get Substring    ${OffPhNo}    3    6
                        ${BN3}=    Get Substring    ${OffPhNo}    6    10

                        Input Text When Element Is Visible    //*[@id="txtAreaCodeUSeiContactPhone"]    ${BN1}
                        Input Text When Element Is Visible    //*[@id="txtPrefixUSeiContactPhone"]    ${BN2}
                        Input Text When Element Is Visible    //*[@id="txtStationCodeUSeiContactPhone"]    ${BN3}
                        Sleep    2s
                        Click Element If Visible    //*[@id="cmdConfirm"]
                        Log To Console    PRINT ePASSPORT
                        # ****PRINT ePASSPORT****
                        Append To File    ${Log}    ****PRINT ePASSPORT****.\n
                        Log To Console    ****PRINT ePASSPORT****

                        Wait Until Element Is Visible    //*[@id="pnlPassportOptions"]    40s
                        
                        # ****EPassport mail Notification****
                        # TRY
                        #     IF    "${Alldatas}[tax_term]" == "1099"
                        #         Input Text When Element Is Visible    //*[@id="spanMultipleEmaileiMultiEmailAddress"]    ${Alldatas}[tech_mail_id];${Alldatas}[supervisor_mail];${credentials}[ybotID]
                        #         Append To File    ${Log}    EPassport mail Notification sent.\n 
                        #     END                   
                        # EXCEPT
                        #     Append To File    ${Log}    EPassport mail Notification not sent.\n 
                        # END
                        Input Text When Element Is Visible    //*[@id="spanMultipleEmaileiMultiEmailAddress"]    ${Alldatas}[tech_mail_id];${Alldatas}[supplier_mail];${credentials}[ybotID]

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
                        Create Directory    ${Epass_Path}
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    2s
                        Append To File    ${Log}    Entering the path.\n
                        RPA.Desktop.Type Text    ${Epass_name}
                        Sleep    3s
                        RPA.Desktop.Press Keys    Enter
                        Append To File    ${Log}    click Entered.\n
                        Sleep    2s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    File downloaded
                        END
                        Append To File    ${Log}    File downloaded.\n
                        Sleep    3s
                        Go Back
                        sleep    5s
                        TRY
                            ${File_exist1}=    Run Keyword And Return Status    File Should Exist    ${Epass_name}
                            IF    ${File_exist1} != True
                                Append To File    ${Log}    Epassport ReDownloading-1.\n
                                Log To Console    Epassport ReDownloading-1.
                                RPA.Browser.Selenium.Go to    ${pdf_url}
                                Sleep    4s
                                Capture Page Screenshot    ${Epass_Path}\\2.png
                                RPA.Desktop.Press Keys    CTRL    s
                                Sleep    2s
                                RPA.Desktop.Type Text    ${Epass_name}
                                Append To File    ${Log}    Entering the path.\n
                                Sleep    3s
                                RPA.Desktop.Press Keys    Enter
                                Append To File    ${Log}    click Entered.\n
                                Sleep    2s
                                TRY
                                    RPA.Desktop.Press Keys    Tab
                                    Sleep    1s
                                    RPA.Desktop.Press Keys    Enter
                                    Sleep    2s
                                EXCEPT
                                    Log To Console    File downloaded
                                END
                                Append To File    ${Log}    File Redownloaded-1.\n
                                Sleep    3s
                                Go Back
                                sleep    5s
                            ELSE
                                Append To File    ${Log}    Epassport already Downloaded.\n
                                Log To Console    Epassport already Downloaded.
                            END
                        EXCEPT
                            Append To File    ${Log}    Epassport ReDownload-1 failed.\n
                            Log To Console    Epassport ReDownload-1 failed.
                        END
                        TRY
                            ${File_exist2}=    Run Keyword And Return Status    File Should Exist    ${Epass_name}
                            IF    ${File_exist2} != True
                                Append To File    ${Log}    Epassport ReDownloading-2.\n
                                Log To Console    Epassport ReDownloading-2.
                                RPA.Browser.Selenium.Go to    ${pdf_url}
                                Sleep    4s
                                Capture Page Screenshot    ${Epass_Path}\\3.png
                                RPA.Desktop.Press Keys    CTRL    s
                                Sleep    2s
                                RPA.Desktop.Type Text    ${Epass_name}
                                Append To File    ${Log}    Entering the path.\n
                                Sleep    3s
                                RPA.Desktop.Press Keys    Enter
                                Append To File    ${Log}    click Entered.\n
                                Sleep    2s
                                TRY
                                    RPA.Desktop.Press Keys    Tab
                                    Sleep    1s
                                    RPA.Desktop.Press Keys    Enter
                                    Sleep    2s
                                EXCEPT
                                    Log To Console    File downloaded
                                END
                                Append To File    ${Log}    File Redownloaded-2.\n
                                Sleep    3s
                                Go Back
                                sleep    5s
                            ELSE
                                Append To File    ${Log}    Epassport already Downloaded.\n
                                Log To Console    Epassport already Downloaded.
                            END
                        EXCEPT
                            Append To File    ${Log}    Epassport ReDownload-2 failed.\n
                            Log To Console    Epassport ReDownload-2 failed.
                        END
                        TRY
                            Click Element If Visible    //*[@id="cmdDone"]
                            Log To Console    Done clicked
                            Append To File    ${Log}    Done clicked\n
                            sleep    2s
                        EXCEPT  
                            Log To Console    Done not clicked
                            Append To File    ${Log}    Done not clicked\n
                        END
                        
                    ELSE
                        ${Clinic_flag}=    Set Variable    False
                        Append To File    ${Log}    Clinic not found.\n
                        Log To Console    Clinic not found
                        RETURN    ${Duplicates_Flag}    ${Clinic_flag}    ${TechMiles}    ${AlreadyExists}
                    END
                END
            END
        END
        RETURN    ${Duplicates_Flag}    ${Clinic_flag}    ${TechMiles}    ${AlreadyExists}
    ELSE
        Append To File    ${Log}    Infomart page not found.\n
        Log to Console    Infomart page not found
    END
