*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem


*** Keywords ***
Fuse_Login
    [Arguments]    ${credentials}    ${DTLog}
    
    Execute Javascript    window.open('${credentials}[FuseURL]');
    Sleep    2s
    ${handles}    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    ${F_Login_1}    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    //*[@id="topicons"]/ul/li[5]/a
    ...    10s
    IF    ${F_Login_1} == True
        Append To File    ${DTLog}    Fuse Login Successful.\n
        Log To Console    Fuse Login Successful
        ${FuseLogin}    Set Variable    True
    ELSE
        Wait Until Element Is Visible    //*[@id='form']/div[1]/input    5s
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
            Append To File    ${DTLog}    Fuse Login Successful.\n
            Log To Console    Fuse Login Successful
            ${FuseLogin}    Set Variable    True
        ELSE
            Append To File    ${DTLog}    Fuse Login Unsuccessful.\n
            Log to Console    Fuse Login UnSuccessful
            ${FuseLogin}    Set Variable    False
        END
    END
    RETURN    ${FuseLogin}
