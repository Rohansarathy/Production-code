# *** Settings ***
# Documentation       cox_onboarding Process-COX DT_BGV_Initiating

# Library             RPA.Browser.Selenium    auto_close=${False}
# Library             DateTime
# Library             RPA.Desktop
# Library             RPA.JSON
# Resource            DT&BGV_initiation.robot
# Resource            Fuselogin.robot
# Resource            Techsearch.robot
# Resource            Killtask.robot
# Resource            EpassportExtract.robot
# Resource            DT&BGVFuseupdate.robot
# Resource    Infomart_login.robot


# *** Variables ***
# ${doc}              ${EMPTY}
# ${Body1}            ${EMPTY}
# ${Body2}            ${EMPTY}
# ${CC}               ${EMPTY}C:\Users\Administrator\OneDrive - ITG Communications, LLC\onboarding_data\Onboarding_COX\Technicians\1234.pdf
# ${Epass_Path}       C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Onboarding_COX\\Technicians
# ${Epass_name}       ${Epass_Path}\\1234.pdf
# # ${Alldatas}    {"license_state1": "prince_edward_island", "license_state2": "district_of_columbia"}


# *** Tasks ***
# Process
#     DT&BGV_Initiation


# *** Keywords ***
# DT&BGV_Initiation
#     # Vault
#     ${credentials}    Load JSON from file    Infomart.json

#     # DB Connect
#     Connect To Database
#     ...    psycopg2
#     ...    ${credentials}[DB_NAME]
#     ...    ${credentials}[DB_USERNAME]
#     ...    ${credentials}[DB_PASSWORD]
#     ...    ${credentials}[DB_HOST]
#     ...    ${credentials}[DB_PORT]
#     Log To Console    DB Connected
#     # Get column names
#     ${columns}    Query
#     ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'cox_onboarding' AND table_schema = 'public'
#     @{column_names}    Create List
#     FOR    ${col}    IN    @{columns}
#         Append To List    ${column_names}    ${col}[0]
#     END
#     # Get data rows
#     ${result}    Query
#     ...    SELECT * FROM public.cox_onboarding where ssn = '652092104'
#     # Combine headers and data rows
#     FOR    ${row}    IN    @{result}
#         ${Alldatas}    Create Dictionary
#         ${num_columns}    Get Length    ${column_names}
#         FOR    ${i}    IN RANGE    ${num_columns}
#             Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
#         END
#         Open Available Browser    ${credentials}[FuseURL]
#         Capture Page Screenshot    C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Onboarding_COX\\123.png
#     END
*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     OperatingSystem
Library    RPA.Desktop

*** Variables ***
${MAX_RETRIES}          12
${InfomartURL}    https://webasap.infomart-usa.net/?id=116815941
${username}    Ybot
${password}    infomart05!
*** Tasks ***
Process
    Infomart_Login
*** Keywords ***
Infomart_Login
    # [Arguments]    ${credentials}    ${DTLog}
    
    
    
    Open Available Browser    ${InfomartURL}    maximized=${True}  
    Sleep    5s
    
    ${site}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="main-message"]/h1/span
    IF    ${site} == True    
        # Log To Console    This site can't open is Appear (Attempt ${index + 1})  
        Log To Console    This site can't provide a secure connection - attempting refresh.
        Execute JavaScript    window.location.reload(true);
    ELSE
        Log To Console    Page loaded successfully
        # BREAK
    END
    
    
    
    