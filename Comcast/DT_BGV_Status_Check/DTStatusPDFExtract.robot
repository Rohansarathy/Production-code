*** Settings ***
Library     RPA.PDF
Library     String
Library     Sendmail.py
Library     OperatingSystem
Resource    DTStatus_Fuseupdate.robot
Library     Teams_Pass.py
Library     Teams_Fail.py


*** Variables ***
${DTStatusRemarks}      ${EMPTY}
${Marijuana}

*** Keywords ***
DTStatuspdfextract
    [Arguments]
    ...    ${Alldatas}
    ...    ${credentials}
    ...    ${DTEpass_name}
    ...    ${DTResult}
    ...    ${doc}
    ...    ${Body1}
    ...    ${Body2}
    ...    ${DTLog}
    ...    ${Firstname}
    ...    ${Lastname}

    ${PDF_exist}=    Run Keyword And Return Status    File Should Exist    ${DTEpass_name}
    ${Firstname}=    set variable    ${Alldatas}[first_name]
    ${Lastname}=    Set Variable    ${Alldatas}[last_name]
    ${PC_Number}=    Set Variable    ${Alldatas}[pc_number]
    ${Marijuana}    Set Variable    False
    IF    ${PDF_exist} == True
        ${text}=    Get Text From PDF    ${DTEpass_name}    trim=True
        @{extract3}=    Get Regexp Matches    ${text}[${1}]    Specimen Result CertificateID Number:(.{10})
        ${code1}=    Convert To String    @{extract3}
        ${IDNumber}=    Set Variable    ${code1}[37:]
        Log To Console    No=${IDNumber}
        Append To file    ${DTLog}    No=${IDNumber}\n

        @{extract4}=    Get Regexp Matches    ${text}[${1}]    Verification Date(.{16})
        ${date1}=    Convert To String    @{extract4}
        ${DTVerificationDate}=    Set Variable    ${date1}[17:]
        Log To Console    V-Date=${DTVerificationDate}
        Append To File    ${DTLog}    V-Date=${DTVerificationDate}\n
            
        IF    "${DTResult}" == "Positive Unable To Contact Donor"
            @{extract5}=    Get Regexp Matches    ${text}[${1}]    Final Result Disposition:(.{34})
            ${date1}=    Convert To String    @{extract5}
            ${DTStatusResult}=    Set Variable    ${date1}[25:]
            Log To Console    Status=${DTStatusResult}
            IF    "${DTStatusResult}" == "Positive - Unable to contact donor"
                IF    "${Alldatas}[state]" == "arizona" or "${Alldatas}[state]" == "connecticut" or "${Alldatas}[state]" == "delaware" or "${Alldatas}[state]" == "missouri" or "${Alldatas}[state]" == "new_mexico" or "${Alldatas}[state]" == "new_york" or "${Alldatas}[state]" == "oklahoma"
                    @{extract6}=    Get Regexp Matches    ${text}[${1}]    LaboratoryLaboratoryLaboratoryLaboratory(.{24})
                    ${result}=    Convert To String    @{extract6}
                    ${Result}=    Set Variable    ${result}[56:]
                    Log To Console    Status=${Result}
                    Append To File    ${DTLog}    Marijuana=${Result}\n
                    IF    "${Result}" == "Positive"
                        ${Marijuana}    Set Variable    True
                    ELSE
                        ${Marijuana}    Set Variable    False
                    END
                END
            END
        END
        IF    "${DTResult}" == "Negative" or "${DTResult}" == "Positive"
            @{extract5}=    Get Regexp Matches    ${text}[${1}]    Final Result Disposition:(.{8})
            ${date1}=    Convert To String    @{extract5}
            ${DTStatusResult}=    Set Variable    ${date1}[25:]
            Log To Console    Status=${DTStatusResult}
            IF    "${DTStatusResult}" == "Positive"
                IF    "${Alldatas}[state]" == "arizona" or "${Alldatas}[state]" == "connecticut" or "${Alldatas}[state]" == "delaware" or "${Alldatas}[state]" == "missouri" or "${Alldatas}[state]" == "new_mexico" or "${Alldatas}[state]" == "new_york" or "${Alldatas}[state]" == "oklahoma"
                    @{extract6}=    Get Regexp Matches    ${text}[${1}]    LaboratoryLaboratoryLaboratoryLaboratory(.{24})
                    ${result}=    Convert To String    @{extract6}
                    ${Result}=    Set Variable    ${result}[56:]
                    Log To Console    Status=${Result}
                    Append To File    ${DTLog}    Marijuana=${Result}\n
                    IF    "${Result}" == "Positive"
                        ${Marijuana}    Set Variable    True
                    ELSE
                        ${Marijuana}    Set Variable    False
                    END
                END
            END
        END
        IF    "${DTResult}" == "Substituted"
            @{extract5}=    Get Regexp Matches    ${text}[${1}]    Final Result Disposition:(.{28})
            ${date1}=    Convert To String    @{extract5}
            ${DTStatusResult}=    Set Variable    ${date1}[25:]
            Log To Console    Status=${DTStatusResult}
        END
        IF    "${DTResult}" == "Refusal To Test"
            @{extract5}=    Get Regexp Matches    ${text}[${1}]    Final Result Disposition:(.{15})
            ${date1}=    Convert To String    @{extract5}
            ${DTStatusResult}=    Set Variable    ${date1}[25:]
            Log To Console    Status=${DTStatusResult}
        END
        IF    "${DTResult}" == "Cancelled"
            @{extract5}=    Get Regexp Matches    ${text}[${1}]    Final Result Disposition:(.{8})
            ${date1}=    Convert To String    @{extract5}
            ${DTStatusResult}=    Set Variable    ${date1}[25:]
            Log To Console    Status=${DTStatusResult}

            # @{extract6}=    Get Regexp Matches    ${text}[${1}]    becauseAdulteratedSubstitutedREMARKS:(.{78})
            # ${Remarks}=    Convert To String    @{extract6}
            # ${DTStatusRemarks}=    Set Variable    ${Remarks}[37:]
            # Log To Console    Remarks=${DTStatusRemarks}
        END
        Append To File    ${DTLog}    Status=${DTStatusResult}\n

        ${DTreceivedDate}=    Get Time
        Execute Sql String
        ...    UPDATE onboarding SET dt_status_received_date = '${DTreceivedDate}' WHERE SSN = '${Alldatas}[ssn]'
        Execute Sql String    UPDATE onboarding SET dt_id_number = '${IDNumber}' WHERE SSN = '${Alldatas}[ssn]'
        Execute Sql String
        ...    UPDATE onboarding SET dt_verification_date = '${DTVerificationDate}' WHERE SSN = '${Alldatas}[ssn]'
        Execute Sql String    UPDATE onboarding SET dt_status = '${DTStatusResult}' WHERE SSN = '${Alldatas}[ssn]'
        IF    "${DTStatusResult}" == "Negative"
            ${Body}=    Set Variable    DT is "Cleared" for ${Alldatas}[first_name] ${Alldatas}[last_name].
            ${Body1}=    Set Variable
            ${Body2}=    Set Variable
            ${Message}=    set variable    DT is <b>"Cleared"</b> for
        END
        IF    "${DTStatusResult}" == "Positive" or "${DTStatusResult}" == "Positive - Unable to contact donor"
            IF    "${Marijuana}" == "True"
                ${Body}=    Set Variable
                ...    The technician ${Alldatas}[first_name] ${Alldatas}[last_name] failed drug test, if he would like to dispute or request further information he can contact ${Alldatas}[dt_confirmation_number].
                ${Body1}=    Set Variable    Escreen 800.881.0722.
                ${Body2}=    Set Variable    Please acknowledge receipt of this email.
                ${Message}=    set variable    DT is <b>"Failed"</b> due to Marijuana is <b>${Marijuana}</b> for
            ELSE
                ${Body}=    Set Variable
                ...    The technician ${Alldatas}[first_name] ${Alldatas}[last_name] failed drug test, if he would like to dispute or request further information he can contact ${Alldatas}[dt_confirmation_number].
                ${Body1}=    Set Variable    Escreen 800.881.0722.
                ${Body2}=    Set Variable    Please acknowledge receipt of this email.
                ${Message}=    set variable    DT is <b>"Failed"</b> for
                Execute Sql String    UPDATE onboarding SET status = 'Removed' WHERE SSN = '${Alldatas}[ssn]'
            END
        END
        IF    "${DTStatusResult}" == "Canceled"
            ${Body}=    Set Variable
            ...    DT has been "Canceled" for ${Alldatas}[first_name] ${Alldatas}[last_name]. Please let us know the tech available time to reshedule the DT.
            ${Body1}=    Set Variable
            ${Body2}=    Set Variable
            ${Message}=    set variable    DT is <b>"Canceled"</b> for
        END
        IF    "${DTStatusResult}" == "Refusel to test" or "${DTStatusResult}" == "Refusal to test: Substituted"
            ${Body}=    Set Variable    ${Alldatas}[first_name] ${Alldatas}[last_name] has failed drug test (${DTStatusResult}), if he/she would like to dispute or request further information he/she can contact Escreen 800.881.0722.
            ${Body1}=    Set Variable    Hence removing applicant from process.
            ${Body2}=    Set Variable    Please acknowledge receipt of this request and update this email thread upon completion of removal.
            ${Message}=    set variable    DT is failed - <b>"${DTStatusResult}"</b> for
            Execute Sql String    UPDATE onboarding SET status = 'Removed' WHERE SSN = '${Alldatas}[ssn]'
        END
        IF    "${Alldatas}[tax_term]" == "1099"
            ${Term}=    Set Variable    ${Alldatas}[tax_term]| ${Alldatas}[company_name]
        ELSE
            ${Term}=    Set Variable    ${Alldatas}[tax_term]
        END
        ${Teams}=    Run Keyword And Return Status
        ...    Teamspass
        ...    ${Firstname}
        ...    ${Lastname}
        ...    ${Message}
        ...    ${PC_Number}
        ...    ${Term}
        IF    ${Teams} == True
            Append To file    ${DTLog}    Message sent for DT status.\n
            Log To Console    Message sent for DT status
        ELSE
            Append To file    ${DTLog}    Message not sent for DT status.\n
            Log To Console    Message not sent for DT status
        END
        IF    "${Marijuana}" == "True"
            ${Recepients}=    set variable    ${credentials}[Team_mail]
            ${CC}    Set Variable    ${Alldatas}[hr_coordinator],${credentials}[ybotID]
        ELSE
            ${Recepients}    set variable    ${Alldatas}[supplier_mail]
            ${CC}    Set Variable
            ...    ${Alldatas}[approver_mail],${Alldatas}[cc_recipients],${credentials}[ybotID]
        END
        ${Attachment}=    Set Variable    ${doc}
        IF    "${Alldatas}[tax_term]" == "1099"
            ${Subject}=    Set Variable
            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
        ELSE
            ${Subject}=    Set Variable
            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
        END
            ${Mailsent}=    Run Keyword And Return Status
            ...    Sendmail
            ...    ${Recepients}
            ...    ${CC}
            ...    ${Subject}
            ...    ${Body}
            ...    ${Body1}
            ...    ${Body2}
            ...    ${Attachment}
            IF    ${Mailsent} == True
                Execute Sql String
                ...    UPDATE onboarding SET dt_status_mail_sent = 'Mail Sent' WHERE SSN = '${Alldatas}[ssn]'
                Append To file    ${DTLog}    Mail sent for DT status.\n
                Log To Console    Mail sent
            ELSE
                Append To file    ${DTLog}    Mail not sent for DT status.\n
                Log To Console    Mail not sent
            END
        IF    "${DTStatusResult}" == "Positive" or "${DTStatusResult}" == "Positive - Unable to contact donor"
            IF    "${Marijuana}" != "True"
                ${Recepients}=    set variable    ${credentials}[BGV_mail]    
                ${CC}    Set Variable    ${credentials}[ybotID],${Alldatas}[hr_coordinator]
                ${Attachment}=    Set Variable    ${doc}
                ${Body}=    Set Variable
                ...    ${Alldatas}[first_name] ${Alldatas}[last_name] failed his drug test. Kindly cancel the Background Verification for this tech.
                ${Body1}=    Set Variable
                ${Body2}=    Set Variable    
                IF    "${Alldatas}[tax_term]" == "1099"
                    ${Subject}=    Set Variable
                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                ELSE
                    ${Subject}=    Set Variable
                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                END
                ${Mailsent}=    Run Keyword And Return Status
                ...    Sendmail
                ...    ${Recepients}
                ...    ${CC}
                ...    ${Subject}
                ...    ${Body}
                ...    ${Body1}
                ...    ${Body2}
                ...    ${Attachment}
                IF    ${Mailsent} == True
                    Execute Sql String
                    ...    UPDATE onboarding SET dt_status_mail_sent = 'Mail Sent' WHERE SSN = '${Alldatas}[ssn]'
                    Append To file    ${DTLog}    Mail sent to Raphaela.\n
                    Log To Console    Mail sent
                ELSE
                    Append To file    ${DTLog}    Mail not sent to Raphaela.\n
                    Log To Console    Mail not sent
                END
            END
        END
        Log To Console    bgv_requested_id=${Alldatas}[bgv_requested_id],DTStatusResult=${DTStatusResult}
        IF    "${Alldatas}[bgv_status]" == "completed" and "${Alldatas}[bgv_requested_id]" != "None"
            IF    "${DTStatusResult}" == "Negative"
                Execute Sql String    UPDATE onboarding SET status = 'completed' WHERE SSN = '${Alldatas}[ssn]'
                Append To File
                ...    ${DTLog}
                ...    Initiation and Status check completed for ${Alldatas}[first_name]_${Alldatas}[last_name]\n
                Log To Console
                ...    Initiation and Status check completed for ${Alldatas}[first_name]_${Alldatas}[last_name]
            END
        END
            Append To File    ${DTLog}    Going for Fuse Update.\n 
            ${FuseUpdate_Flag}=    DTStatus_Fuseupdate
            ...    ${Alldatas}
            ...    ${credentials}
            ...    ${DTEpass_name}
            ...    ${DTVerificationDate}
            ...    ${DTStatusResult}
            ...    ${DTStatusRemarks}
            ...    ${DTLog}
            ...    ${Firstname}
            ...    ${Lastname}
            ...    ${Marijuana}   
        Append To File    ${DTLog}    FuseUpdate_Flag=${FuseUpdate_Flag}.\n 
        IF    "${FuseUpdate_Flag}" == "False"
            Log To Console    DT Status not updated in Fuse.
            Append To file    ${DTLog}    DT Status not updated in Fuse.\n
            ${Message}=    Set Variable    DT status not updated in Fuse for
            ${Teams}=    Run Keyword And Return Status    Teamsfail    ${Firstname}    ${Lastname}    ${Message}
            IF    ${Teams} == True
                Append To file    ${DTLog}    Message sent for DT status not updated in Fuse.\n
                Log To Console    Message sent for DT status not updated in Fuse.
            ELSE
                Append To file    ${DTLog}    Message not sent for DT status not updated in Fuse.\n
                Log To Console    Message not sent for DT status not updated in Fuse.
            END
        END
    END
