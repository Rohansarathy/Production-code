*** Settings ***
Library    RPA.PDF
Library    String
Library    DatabaseLibrary
Library    OperatingSystem


*** Keywords ***
Epassport Extract
    [Arguments]    ${Alldatas}    ${Epass_name}    ${Log}
    
    TRY
        ${PDFtext} =    Get Text From PDF    ${Epass_name}    trim=True
        ${PDFtext}=    Convert To String    ${PDFtext}

        @{barcode_matches}=    Get Regexp Matches    ${PDFtext}    \\*([A-Z0-9]+)\\*
        ${barcode_count}=    Get Length    ${barcode_matches}
        ${Conformation_No}=    Set Variable If    ${barcode_count} > 0    ${barcode_matches[0]}    No barcode found
        ${Conformation_No}=    Replace String    ${Conformation_No}    *    ${EMPTY}
        Log To Console    ${Conformation_No}
        Append To File  ${Log}  Conformation_No=${Conformation_No}\n
        Execute Sql String    UPDATE spectrum_onboarding SET dt_confirmation_number = '${Conformation_No}' WHERE SSN = '${Alldatas}[ssn]'


        ${date_pattern}=    Set Variable    This order must be completed by:\\s*(\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2} (AM|PM) \\((CT|ET|PT|MT|MDT|MST)\\))
        ${date}=    Get Regexp Matches    ${PDFtext}    ${date_pattern}
        ${date1}=    Evaluate    "${date}".strip("[]").strip("'")
        ${ETA_Date}=    Set Variable     ${date1}[32:]    
        Append To File  ${Log}  ETA_Date=${ETA_Date}\n
        Log To Console    ${ETA_Date}
        Execute Sql String    UPDATE spectrum_onboarding SET dt_eta = '${ETA_Date}' WHERE SSN = '${Alldatas}[ssn]'
        Execute Sql String    UPDATE spectrum_onboarding SET dt_status = 'Scheduled' WHERE SSN = '${Alldatas}[ssn]'
        ${PDF_Extract}    Set Variable    True
        Return From Keyword    ${Conformation_No}    ${ETA_Date}    ${PDF_Extract}
    EXCEPT
        Append To File  ${Log}  PDF Extractinng failed\n
        Log To Console    PDF Extractinng failed.
        ${PDF_Extract}    Set Variable    False
        ${Conformation_No}    Set Variable
        ${ETA_Date}    Set Variable
        Return From Keyword    ${Conformation_No}    ${ETA_Date}    ${PDF_Extract}
    END