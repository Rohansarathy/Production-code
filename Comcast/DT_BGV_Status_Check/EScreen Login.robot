*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem


*** Variables ***
${PROFILE_PATH}     C:\\Users\\Administrator\\AppData\\Local\\Google\\Chrome\\User Data\\Profile


*** Keywords ***
Escreen Login
    [Arguments]    ${credentials}    ${DTLog}    ${BGVLog}

    ${options}=    Create Dictionary    arguments=${PROFILE_PATH}
    Open available Browser    ${credentials}[EScreen URL]    chrome    options=${options}
    Maximize Browser Window
    ${ES_Login1}=    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //*[@id="mainFrame"]
    ...    5s
    IF    ${ES_Login1} == True
        Append To File    ${DTLog}    EScreen Login Successful.\n
        Append To File    ${BGVLog}    EScreen Login Successful.\n
        Log To Console    EScreen Login Successful
        ${EscreenLogin}=    Set Variable    True
    ELSE
        RPA.Browser.Selenium.Wait Until Element Is Visible    //*[@id="signInName"]    30s
        Input Text When Element Is Visible    //*[@id="signInName"]    ${credentials}[Esusername]
        Sleep    1s
        Click Element If Visible    //*[@id="continue"]
        RPA.Browser.Selenium.Wait Until Element Is Visible    //*[@id="password"]    30s
        Input Text When Element Is Visible    //*[@id="password"]    ${credentials}[Espassword]
        Click Element If Visible    //*[@id="next"]
        ${ES_Login2}=    Run Keyword And Return Status
        ...    RPA.Browser.Selenium.Wait Until Element Is Visible
        ...    //*[@id="mainFrame"]
        ...    30s
        IF    ${ES_Login2} == True
            Append To File    ${DTLog}    EScreen Login Successful.\n
            Append To File    ${BGVLog}    EScreen Login Successful.\n
            Log To Console    EScreen Login Successful
            ${EscreenLogin}=    Set Variable    True
        ELSE
            Append To File    ${DTLog}    EScreen Login Unsuccessful.\n
            Append To File    ${BGVLog}    EScreen Login Unsuccessful.\n
            Log to Console    EScreen Login UnSuccessful
            ${EscreenLogin}=    Set Variable    False
        END
    END
    ${Choice}=    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //*[@id="truste-consent-content"]
    ...    5s
    TRY
        IF    ${Choice} == True
            Click Element If Visible    //*[@id="truste-show-consent"]
            Sleep    6s
            RPA.Desktop.Press Keys    Tab
            RPA.Desktop.Press Keys    Tab
            RPA.Desktop.Press Keys    Tab
            RPA.Desktop.Press Keys    Tab
            Sleep    1s
            RPA.Desktop.Press Keys    Enter
            Sleep    2s
            Reload Page
        END
    EXCEPT
        Log To Console    Consent not found
    END
    Return From Keyword    ${EscreenLogin}
