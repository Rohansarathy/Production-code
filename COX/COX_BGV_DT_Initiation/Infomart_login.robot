*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     OperatingSystem

*** Variables ***
${MAX_RETRIES}          12
*** Keywords ***
Infomart_Login
    [Arguments]    ${credentials}    ${DTLog}
    
    
    Open Available Browser    ${credentials}[InfomartURL]    maximized=${True}
    Sleep    5s
    TRY
        FOR    ${index}    IN RANGE    ${MAX_RETRIES}
            ${site}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //*[@id="main-message"]/h1/span
            IF    ${site} == True
                Execute JavaScript    window.location.reload(true);
                # RPA.Browser.Selenium.Press Keys    Ctrl+Shift+R
                Log To Console    This site can't open is Appear (Attempt ${index + 1})
                Append To File    ${DTLog}    This site can't open is Appear (Attempt ${index + 1}).\n
                
            ELSE
                Log To Console    Page loaded successfully on attempt ${index + 1}
                Append To File    ${DTLog}    Page loaded successfully on attempt ${index + 1}.\n
                BREAK
            END
    END
    EXCEPT    
        Log To Console    Application running
        Append To File    ${DTLog}    Application running
    END
    Wait Until Element Is Visible    //*[@id="login_username"]    10s
    Input Text When Element Is Visible    //*[@id="login_username"]    ${credentials}[username]
    Sleep    0.5s
    Input Text When Element Is Visible    //*[@id="login_password"]    ${credentials}[password]
    Sleep    0.5s
    ${input_field_value}=    RPA.Browser.Selenium .Get Value    //*[@id="login_acct_number"]
    IF    '${input_field_value}' == '101120863'
        Log    Value already entered. Proceeding to click the submit button.
    ELSE
        Log
        ...    Entering the value into the input field.
        ...    Clear Element Text
        ...    //*[@id="login_acct_number"]
        ...    Input Text
        ...    //*[@id="login_acct_number"]
        ...    101120863
    END
    Sleep    0.5s
    Click Element If Visible    //button[normalize-space(text())='Login']
    TRY
        ${certification_found}=    Run Keyword And Return Status
        ...    Element Should Be Visible
        ...    //div[@class='panel-body']/h3
        ...    5s
        IF    "${certification_found}" == "True"
            Click Element If Visible    //*[@id="Accept"]
            Log To Console    Certification of Permissible
        END
    EXCEPT
        Log To Console    Certificate not found
    END
    ${Infomart_Login2}=    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //*[@id="request-list-wrapper"]/div[1]/div/div[2]/div[3]/div/div/div[2]/div
    ...    5s
    IF    ${Infomart_Login2} == True
        Append To File    ${DTLog}    Infomart Login Successful.\n
        Log To Console    Infomart Login Successful
        ${Infomart_Login}=    Set Variable    True
    ELSE
        Append To File    ${DTLog}    EScreen Login UnSuccessful.\n
        Log to Console    Infomart Login UnSuccessful
        ${Infomart_Login}=    Set Variable    False
    END

    RETURN    ${Infomart_Login}
