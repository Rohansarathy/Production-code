*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem
Library     RPA.JSON


*** Keywords ***
Fuse Login
    [Arguments]    ${credentials}    ${Log}
    
    # ${credentials}    Load JSON from file    credentials.json
    # Open Browser    browser=chrome
    # Maximize Browser Window
    Execute Javascript    window.open('${credentials}[Fuse URL]');
    ${handles}    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    ${F_Login_1}    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    //*[@id="topicons"]/ul/li[5]/a
    ...    10s
    IF    ${F_Login_1} == True
        Append To File    ${Log}    Fuse Login Successful.\n
        Log To Console    Fuse Login Successful
        ${FuseLogin}    Set Variable    True
    ELSE
        Wait Until Element Is Visible    //*[@id='form']/div[1]/input    30s
        Input Text When Element Is Visible    //*[@id='form']/div[1]/input    ${credentials}[Fusername]
        Sleep    0.5s
        Input Text When Element Is Visible    multi_user_timeout_pin    ${credentials}[Fpassword]
        Sleep    0.5s
        RPA.Browser.Selenium.Click Element    //*[@id="form"]/div[3]/a
        Sleep    3s
        ${F_Login_2}    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    //*[@id="topicons"]/ul/li[5]/a
        ...    10s
        IF    ${F_Login_2} == True
            Append To File    ${Log}    Fuse Login Successful.\n
            Log To Console    Fuse Login Successful
            ${FuseLogin}    Set Variable    True
        ELSE
            Append To File    ${Log}    Fuse Login UnSuccessful.\n
            Log to Console    Fuse Login UnSuccessful
            ${FuseLogin}    Set Variable    False
        END
    END
    ${Popup_exists}    Run Keyword And Return Status
    ...    Element Should Be Visible
    ...    //*[@id="example_main_notification"]/tbody/tr/td[1]    5s
    TRY
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
    Return From Keyword    ${FuseLogin}
