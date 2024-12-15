*** Settings ***
Library     String
Library     RPA.PDF
Library     DateTime
Library     DatabaseLibrary
Library     OperatingSystem

*** Keywords ***
BGVPDFExtract
    [Arguments]    ${Alldatas}    ${BGV_PDF}    ${BGVLog}

    ${PDFtext}=    Get Text From Pdf    ${BGV_PDF}    trim=True
    ${text_content}=    Evaluate    list(${PDFtext}.values())[0]
    ${text_content}=    Convert To String    ${text_content}
    Log To Console    ${PDFtext}
    # Extract Request ID
    @{extract2}=    Get Regexp Matches    ${text_content}    Request ID:(.{15})
    ${ID}=    Convert To String    ${extract2[0]}
    ${BGV_Request_ID}=    Set Variable    ${ID[11:]}
    Log To Console    ${BGV_Request_ID}
    Append To File    ${BGVLog}    BGV_Request_ID=${BGV_Request_ID}.\n
    
    # Extract Issued Date
    ${date_pattern}=    Set Variable
    ...    Issued:\\s*(\\w+\\s+\\d{1,2},\\s+\\d{4}\\s+\\d{1,2}:\\d{2}\\s+(AM|PM)\\s+(PDT|PST))
    @{date}=    Get Regexp Matches    ${text_content}    ${date_pattern}
    IF    len(${date}) == 0    Fail    Issued date not found in the document
    ${date1}=    Evaluate    "${date}".strip("[]").strip("'")
    ${BGV_IssuedDate}=    Set Variable    ${date1}[7:]
    Log To Console    ${BGV_IssuedDate}
    Append To File    ${BGVLog}    BGV_IssuedDate=${BGV_IssuedDate}.\n

    # Extract Date
    ${Month}=    Get Substring    ${BGV_IssuedDate}    0    3
    ${Month1}=    Evaluate    datetime.datetime.strptime($Month, "%b").month
    Log To Console    Month=${Month}

    ${Day}=    Get Substring    ${BGV_IssuedDate}    4    6
    ${Day}=    Should Match Regexp    ${Day}    \\d{1,2}
    IF    ${Day} < 10
        ${Day}=    Set Variable     0${Day}
        ${Year}=    Get Substring    ${BGV_IssuedDate}    7    11
        Log To Console    Year=${Year}
    ELSE
        ${Year}=    Get Substring    ${BGV_IssuedDate}    8    12
        Log To Console    Year=${Year}
    END
    Log To Console    Day=${Day}
    ${BGV_IssuedDate1}=    Set Variable    ${Month1}/${Day}/${Year}
    Log To Console    ${BGV_IssuedDate1}
    Append To File    ${BGVLog}    BGV_IssuedDate1=${BGV_IssuedDate1}.\n
    
    Return From Keyword    ${BGV_IssuedDate1}    ${BGV_Request_ID}    ${BGV_IssuedDate}