*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}                http://example.com   # Replace with your actual URL
${XPATH_ROW}          //*[@id="applicant483534-result"]/table/tbody/tr
${XPATH_STATUS}       //*[@id="applicant483534-result"]/table/tbody/tr[${row_index}]/td/div[1]/div[3]/i
${ACTIVE_STATUS}     Active
${INACTIVE_STATUS}   Inactive

*** Test Cases ***
Interact With HTML Elements
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    
    # Wait for the first element to be visible and click to expand details
    Wait Until Element Is Visible    xpath=//ul[@id='ccenter-results']//li[1]//td[@width='22%']    10s
    Click Element    xpath=//ul[@id='ccenter-results']//li[1]//td[@width='22%']
    
    # Retrieve details of the first applicant
    ${full_name}            Get Element Attribute    xpath=//input[@id='applicant-info-457676']    fullname
    ${driver_license}      Get Element Attribute    xpath=//input[@id='applicant-info-457676']    driverslicense
    ${dmv_last_ordered_date} Get Element Attribute    xpath=//input[@id='applicant-info-457676']    dmv_last_ordered_date
    ${mvr_state_code}     Get Element Attribute    xpath=//input[@id='applicant-info-457676']    mvr_state_code
    ${company}            Get Element Attribute    xpath=//input[@id='applicant-info-457676']    company
    
    # Log the details to console
    Log To Console    Full Name: ${full_name}
    Log To Console    Driver's License: ${driver_license}
    Log To Console    DMV Last Ordered Date: ${dmv_last_ordered_date}
    Log To Console    MVR State Code: ${mvr_state_code}
    Log To Console    Company: ${company}
    
    # Perform actions on the expanded details
    Wait Until Element Is Visible    xpath=//div[@id='applicant457676-result']//div[@class='uk-content-label'][contains(text(), 'Applicant Information:')]    10s
    ${applicant_email}    Get Text    xpath=//div[@id='applicant457676-result']//div[contains(text(), 'Email:')]/following-sibling::div/span
    
    # Log the applicant email to console
    Log To Console    Applicant Email: ${applicant_email}
    
    # Check status for each row in the table
    ${number_of_rows}=    Get Element Count    ${XPATH_ROW}
    
    :FOR    ${row_index}    IN RANGE    1    ${number_of_rows}
    \    ${status_element}=    Get Element Attribute    xpath=${XPATH_STATUS}    class
    \    ${status}=    Get Status Text    ${status_element}
    \    Run Keyword If    '${status}' == '${ACTIVE_STATUS}'
    \    \    Log    Applicant in row ${row_index} is Active
    \    \    # Add logic to interact with the Active applicant
    \    Run Keyword If    '${status}' == '${INACTIVE_STATUS}'
    \    \    Log    Applicant in row ${row_index} is Inactive
    \    \    # Move to the next row if Inactive

    # Close the browser
    Close Browser

*** Keywords ***
Get Status Text
    [Arguments]    ${status_element}
    # Modify this function if needed to extract and return the status text from the status element
    ${status_text}=    Get Element Attribute    ${status_element}    title
    [Return]    ${status_text}
