*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     OperatingSystem


*** Keywords ***
Crimshield_login
    [Arguments]    ${credentials}    ${Log}

    Open Browser    ${credentials}[CrimShieldURL]    browser=chrome
    Maximize Browser Window
    Wait Until Element Is Visible    clientSecurityHtLogin    5s
    Execute JavaScript    document.getElementById('clientSecurityHtLogin').removeAttribute('readonly')
    Sleep    1s
    Input Text When Element Is Visible    clientSecurityHtLogin    ${credentials}[username]
    Wait Until Element Is Visible    clientSecurityHtPassword    5s
    Execute JavaScript    document.getElementById('clientSecurityHtPassword').removeAttribute('readonly')
    Sleep    1s
    Input Text When Element Is Visible    clientSecurityHtPassword    ${credentials}[password]
    Click Element If Visible   //button[@type='submit']
    Sleep    5s

    ${Verifications1}=    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //div[text()='APPLICATION RENEWAL']
    ...    80s
    IF    "${Verifications1}" == "True"
        Click Element If Visible    //span[text()='No']
        Log To Console    Application RENEWAL Appear
    END
    # ${Verifications2}=    Run Keyword And Return Status
    # ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    # ...    //span[text()='NOTICE OF UPCOMING PROCESS CHANGE']
    # ...    3s
    # IF    "${Verifications2}" == "True"
    #     Click Element If Visible    //*[@id="bg-page"]/div/div[2]/div[3]/div[2]/div[2]/a
    #     Log To Console    Go to Dashboard
    # END
    ${Verifications3}=    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //div[text()='No Tech ID']
    ...    3s
    IF    "${Verifications3}" == "True"
        Click Element If Visible    //*[@id="invalid-tech-div-dialog"]/div/div[3]/div/div[3]/div/a/span
        Log To Console    No Tech ID
    END
    ${CrimShield_login}=    Run Keyword And Return Status
    ...    RPA.Browser.Selenium.Wait Until Element Is Visible
    ...    //*[@id="main-content"]/div[1]/div[2]/div[4]/div
    ...    20s
    IF    "${CrimShield_login}" == "True"
        Append To File    ${Log}    CrimShield Login Successful.\n
        Log To Console    CrimShield Login Successful
        ${CrimShield_login}=    Set Variable    True
    ELSE
        Append To File    ${Log}    CrimShield Login UnSuccessful.\n
        Log to Console    CrimShield Login UnSuccessful
        ${CrimShield_login}=    Set Variable    False
    END

    RETURN    ${CrimShield_login}
