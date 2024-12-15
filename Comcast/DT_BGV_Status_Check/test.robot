
*** Settings ***
Documentation       OnBoarding Process-Comcast DT_BGV_Status_Check

Library             RPA.Browser.Selenium    auto_close=${False}
Library             DatabaseLibrary
Library             RPA.JSON
Resource            EScreen Login.robot
Resource            DTStatus_Check.robot
Resource            DTExpired.robot
Library             Sendmail.py
Library             Collections
Resource            BGVPDFExtract.robot
Resource            BGVStatusFuseupdate.robot
Resource            Killtask.robot
Resource            Fuselogin.robot
Resource            BGVStatus_Check.robot


*** Variables ***
${doc}              ${EMPTY}
${Body1}            ${EMPTY}
${Body2}            ${EMPTY}
${Initi_time}       ${EMPTY}
${CC}               ${EMPTY}
*** Tasks ***
process
    Check file
*** Keywords ***
Check file

    ${DTEpass_name}    Set Variable    C:\\Users\\Administrator\\Desktop\\Edward_Fowler\\Edward_Fowler15091993_DTstatus.pdf
    ${File_exist1}=    Run Keyword And Return Status    File Should Exist    ${DTEpass_name}
    IF   ${File_exist1} == True
        Remove File       ${DTEpass_name}
        Log To Console    File removed
    ELSE
        
        Log To Console    File not remove
    END
   
