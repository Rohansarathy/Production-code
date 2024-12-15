*** Settings ***
Documentation       COX_Onboarding Process-COX_DT_BGV_Initiating

Library             RPA.Browser.Selenium    auto_close=${False}
Library             DateTime
Library             RPA.Desktop
Library             RPA.JSON
Library             Sendmail.py
Library             Teams_Fail
Library             Teams_Pass
Resource            Infomart_login.robot
Resource            DT&BGV_initiation.robot
Resource            Fuselogin.robot
Resource            Techsearch.robot
Resource            Killtask.robot
Resource            EpassportExtract.robot
Resource            DT&BGVFuseupdate.robot
Library             Scope_dir.py

*** Variables ***
${doc}                  ${EMPTY}
${Body1}                ${EMPTY}
${Body2}                ${EMPTY}
${CC}                   ${EMPTY}
${Tech_found_flag}      ${EMPTY}


*** Tasks ***
Process
    DT&BGV_Initiation


*** Keywords ***
DT&BGV_Initiation
    # Vault
    ${credentials}    Load JSON from file    Infomart.json

    # DB Connect
    Connect To Database
    ...    psycopg2
    ...    ${credentials}[DB_NAME]
    ...    ${credentials}[DB_USERNAME]
    ...    ${credentials}[DB_PASSWORD]
    ...    ${credentials}[DB_HOST]
    ...    ${credentials}[DB_PORT]
    Log To Console    DB Connected
    ${result}    Query    SELECT * FROM public.cox_onboarding where status is Null OR status = '' LIMIT 1;
    FOR    ${row}    IN    @{result}
        ${Time}    Get Time
        ${year}    Set Variable    ${Time}[0:4]
        ${month}    Set Variable    ${Time}[5:7]
        ${day}    Set Variable    ${Time}[8:10]
        ${mint}    Set Variable    ${Time}[11:13]
        ${Sec}    Set Variable    ${Time}[14:16]
        ${Log}    Set Variable    ${credentials}[Logfile]\\DT&BGV_${day}${month}${year}_${mint}_${Sec}.txt
        Create File    ${Log}

        TRY
            Log To Console    *********************************Executing the Process*********************************
            Append To file
            ...    ${Log}
            ...    *********************************Executing the Process*********************************\n
            # FOR    ${element}    IN    3
            ${InfomartLogin}    Infomart_Login    ${credentials}    ${Log}
            #     IF    ${InfomartLogin} == True
            #         BREAK
            #     ELSE
            #         Kill Chrome Processes
            #     END 
            # END
            
            ${FuseLogin}    Fuse Login    ${credentials}    ${Log}
            IF    ${InfomartLogin} == True and ${FuseLogin} == True
                Log To Console    Connecting DB.....
                Append To file    ${Log}    DB Connected\n
                # Get column names
                ${columns}    Query
                ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'cox_onboarding' AND table_schema = 'public'
                @{column_names}    Create List
                FOR    ${col}    IN    @{columns}
                    Append To List    ${column_names}    ${col}[0]
                END
                # Get data rows
                ${result}    Query
                ...    SELECT * FROM public.cox_onboarding where status is Null OR status = '' LIMIT 2;
                # Combine headers and data rows
                FOR    ${row}    IN    @{result}
                    ${Alldatas}    Create Dictionary
                    ${num_columns}    Get Length    ${column_names}
                    FOR    ${i}    IN RANGE    ${num_columns}
                        Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
                    END

                    ${Tech_DOB}    Convert To String    ${Alldatas}[tech_dob]
                    ${date_components}    Split String    ${Tech_DOB}    -
                    ${DOBYear}    Get From List    ${date_components}    0
                    ${DOBMonth}    Get From List    ${date_components}    1
                    ${DOBDay}    Get From List    ${date_components}    2
                    ${DOB}    Set Variable    ${DOBDay}${DOBMonth}${DOBYear}

                    ${FIRST_NAME}    Set Variable    ${Alldatas}[first_name]
                    ${LAST_NAME}    Set Variable    ${Alldatas}[last_name]

                    ${first_name_words}    Split String    ${FIRST_NAME}
                    ${last_name_words}    Split String    ${LAST_NAME}

                    ${Firstname}    Set Variable    ${EMPTY}
                    ${Lastname}    Set Variable    ${EMPTY}

                    FOR    ${word}    IN    @{first_name_words}
                        ${Firstname}    Set Variable    ${Firstname}_${word}
                    END
                    ${Firstname}    Evaluate    "${Firstname}[1:]"
                    FOR    ${word}    IN    @{last_name_words}
                        ${Lastname}    Set Variable    ${Lastname}_${word}
                    END
                    ${Lastname}    Evaluate    "${Lastname}[1:]"
                    IF    "${Alldatas}[suffix]" != "" and "${Alldatas}[suffix]" != "None" and "${Alldatas}[suffix]" != " "
                        ${suffix}    Set Variable    ${Alldatas}[suffix]
                        ${full_name}    Set Variable    ${Firstname}_${Lastname}_${suffix}
                    ELSE
                        ${full_name}    Set Variable    ${Firstname}_${Lastname}
                    END

                    ${Epass_Path}    Set Variable    ${credentials}[Default_Path]\\${full_name}${DOB}
                    ${Epass_name}    Set Variable    ${Epass_Path}\\${full_name}${DOB}_DT.pdf
                    ${image}         Set Variable    ${Epass_Path}\\${full_name}${DOB}_DT.png

                    Append To File    ${Log}    clinic_zip_code=${Alldatas}[clinic_zip_code]\n
                    Log To Console    clinic_zip_code=${Alldatas}[clinic_zip_code]
                    ${Firstname}    set variable    ${Alldatas}[first_name]
                    ${Lastname}    Set Variable    ${Alldatas}[last_name]
                    ${PC_Number}    Set Variable    ${Alldatas}[pc_number]

                    Log To Console    dt_confirmation_number=${Alldatas}[dt_confirmation_number]
                    IF    "${Alldatas}[dt_confirmation_number]" == "" or "${Alldatas}[dt_confirmation_number]" == "None"
                        ${Process_Flag}    Set Variable    True
                    ELSE
                        IF    "${Alldatas}[dt_confirmation_number]" == "AlreadyExists" and "${Alldatas}[rescheduled]" == "reload"
                            ${Process_Flag}    Set Variable    True
                        ELSE
                            ${Process_Flag}    Set Variable    False
                        END
                    END
                    IF    ${Process_Flag} == True
                        Append To File
                        ...    ${Log}
                        ...    **************************Technician=${full_name}${DOB}**************************\n
                        Log To Console
                        ...    **************************Technician=${full_name}**************************
                        IF    "${Alldatas}[process]" == "pre_employment"
                            ${Tech_found_flag}    Techsearch    ${Alldatas}    ${credentials}    ${Log}
                            Append To file    ${Log}    Tech found=${Tech_found_flag}\n
                            Log To Console    Tech found=${Tech_found_flag}
                        ELSE
                            ${Tech_found_flag}    Set Variable    True
                        END
                        IF    ${Tech_found_flag} == True
                            ${DT_Start_time}    Get Time
                            Append To File    ${Log}    DT_Start_time=${DT_Start_time}.\n
                            Log To Console    DT_Start_time=${DT_Start_time}
                            Execute Sql String
                            ...    UPDATE cox_onboarding SET status = 'WIP' WHERE SSN = '${Alldatas}[ssn]'
                            Execute Sql String
                            ...    UPDATE cox_onboarding SET bgv_dt_initiated_date = '${DT_Start_time}' WHERE SSN = '${Alldatas}[ssn]'
                            ${Duplicates_Flag}
                            ...    ${Clinic_flag}
                            ...    ${TechMiles}
                            ...    ${AlreadyExists}
                            ...    Initiation
                            ...    ${Alldatas}
                            ...    ${credentials}
                            ...    ${Epass_Path}
                            ...    ${Epass_name}
                            ...    ${Log}
                            ...    ${image}
                            Log To Console    AlreadyExists=${AlreadyExists}
                            IF    ${AlreadyExists} == True
                                IF    "${Alldatas}[dt_confirmation_number]" != "AlreadyExists"
                                    Execute Sql String
                                    ...    UPDATE cox_onboarding SET dt_confirmation_number = 'AlreadyExists' WHERE SSN = '${Alldatas}[ssn]'
                                    Execute Sql String
                                    ...    UPDATE cox_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'
                                    Append to File    ${Log}    This Tech is AlreadyExists.\n
                                    Log To Console    This Tech is AlreadyExists.
                                    ${Recepients}    set variable
                                    ...    ${Alldatas}[hr_coordinator]
                                    ${CC}    set variable    ${credentials}[Recipient]
                                    ${Subject}    Set Variable    Tech Alread exists in Infomart
                                    ${Body}    Set Variable
                                    ...    The Tech "${full_name}" is alread exists in Infomart for "${Alldatas}[process]". Kindly check.
                                    ${Body1}    Set Variable    SSN=${Alldatas}[ssn]
                                    ${Attachment}    Set Variable    ${doc}
                                    ${Mailsent}    Run Keyword And Return Status
                                    ...    Sendmail
                                    ...    ${Recepients}
                                    ...    ${CC}
                                    ...    ${Subject}
                                    ...    ${Body}
                                    ...    ${Body1}
                                    ...    ${Body2}
                                    ...    ${Attachment}
                                    IF    ${Mailsent} == True
                                        Append To file    ${Log}    Mail sent for Tech AlreadExists.\n
                                        Log To Console    Mail sent
                                    ELSE
                                        Append To file    ${Log}    Mail not sent for Tech AlreadExists.\n
                                        Log To Console    Mail not sent
                                    END
                                END
                            ELSE
                                IF    ${Duplicates_Flag} == False
                                    IF    ${Clinic_flag} == True
                                        ${File_exist}    Run Keyword And Return Status
                                        ...    File Should Exist
                                        ...    ${Epass_name}
                                        IF    ${File_exist} == True
                                            Append To File    ${Log}    Epassport Extracting.\n
                                            Log To Console    Epassport Extracting
                                            ${Conformation_No}    ${ETA_Date}    ${PDF_Extract}    Epassport_Extract
                                            ...    ${Alldatas}
                                            ...    ${Epass_name}
                                            ...    ${Log}
                                            IF    "${PDF_Extract}" == "True"
                                                IF    "${Alldatas}[tax_term]" == "1099"
                                                    ${Term}    Set Variable
                                                    ...    ${Alldatas}[tax_term]| ${Alldatas}[company_name]
                                                ELSE
                                                    ${Term}    Set Variable    ${Alldatas}[tax_term]
                                                END
                                                ${Message}    Set Variable    DT & BGV <b>"initiated"</b> for
                                                ${Teams}    Run Keyword And Return Status
                                                ...    Teamspass
                                                ...    ${Firstname}
                                                ...    ${Lastname}
                                                ...    ${Message}
                                                ...    ${PC_Number}
                                                ...    ${Term}
                                                IF    ${Teams} == True
                                                    Append To File    ${Log}    Message sent for DT & BGV initiated.\n
                                                    Log To Console    Message sent for DT & BGV initiated
                                                ELSE
                                                    Append To File
                                                    ...    ${Log}
                                                    ...    Message not sent for DT & BGV initiated.\n
                                                    Log To Console    Message not sent for DT & BGV initiated
                                                END
                                                
                                                ${Recepients}    set variable    ${Alldatas}[supplier_mail]
                                                ${CC}    Set Variable
                                                ...    ${Alldatas}[approver_mail],${Alldatas}[cc_recipients],${credentials}[ybotID]
                                                Log To Console    ${Recepients}
                                                Log To Console    ${CC}
                                                Append To File    ${Log}    ${Recepients}\n
                                                Append To File    ${Log}    ${CC}\n
                                                IF    ${TechMiles} > 25
                                                    Append To File    ${Log}    TechMiles=${TechMiles}\n
                                                    ${Body2}    Set Variable
                                                    ...    *The nearest facility available for the given Zipcode (${Alldatas}[clinic_zip_code]) is ${TechMiles} miles from his current location.
                                                END
                                                IF    "${Alldatas}[tax_term]" == "1099"
                                                    ${Subject}    Set Variable
                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                                ELSE
                                                    ${Subject}    Set Variable
                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                                END
                                                ${Body}    Set Variable
                                                ...    DT is scheduled emailed and texted for ${Alldatas}[first_name] ${Alldatas}[last_name]. Make sure he receives it.
                                                ${Body1}    Set Variable
                                                ...    Confirmation Number = ${Conformation_No} & This order must be completed by:${ETA_Date}
                                                ${Attachment}    Set Variable    ${Epass_name}
                                                ${Mailsent}    Run Keyword And Return Status
                                                ...    Sendmail
                                                ...    ${Recepients}
                                                ...    ${CC}
                                                ...    ${Subject}
                                                ...    ${Body}
                                                ...    ${Body1}
                                                ...    ${Body2}
                                                ...    ${Attachment}
                                                IF    ${Mailsent} == True
                                                    Append To File    ${Log}    Mail sent for DT & BGV initiated.\n
                                                    Log To Console    Mail sent
                                                    Execute Sql String
                                                    ...    UPDATE cox_onboarding SET bgv_dt_mail_sent = 'Mail Sent' WHERE SSN = '${Alldatas}[ssn]'
                                                ELSE
                                                    Append To File    ${Log}    Mail not sent for DT & BGV initiated.\n
                                                    Log To Console    Mail not sent
                                                END
                                                IF    "${Alldatas}[process]" == "annual_drug_test" or "${Alldatas}[process]" == "supervisor_request"
                                                    Execute Sql String
                                                    ...    UPDATE cox_onboarding SET status = 'Initiated' WHERE SSN = '${Alldatas}[ssn]'
                                                END
                                                IF    "${Alldatas}[process]" == "pre_employment"
                                                    ${FuseUpdate_Flag}    DT&BGV_Fuse_Update
                                                    ...    ${Epass_name}
                                                    ...    ${Alldatas}
                                                    ...    ${credentials}
                                                    ...    ${ETA_Date}
                                                    ...    ${Conformation_No}
                                                    ...    ${Log}
                                                    ...    ${Firstname}
                                                    ...    ${Lastname}
                                                    Execute Sql String
                                                    ...    UPDATE cox_onboarding SET status = 'Initiated' WHERE SSN = '${Alldatas}[ssn]'
                                                    ${DT_Stop time}    Get Time
                                                    Append To File    ${Log}    DT_Bot Stop time=${DT_Stop time}.\n
                                                    Log To Console    DT_Bot Stop time=${DT_Stop time}

                                                    IF    ${FuseUpdate_Flag} == False
                                                        Append To File
                                                        ...    ${Log}
                                                        ...    DT&BGV initiated not updated in Fuse.\n
                                                        Log To Console    DT&BGV initiated not updated in Fuse
                                                        ${Recepients}    set variable    ${credentials}[cox_recipients]
                                                        ${CC}    Set Variable    ${credentials}[Recipient]
                                                        IF    "${Alldatas}[tax_term]" == "1099"
                                                            ${Subject}    Set Variable
                                                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                                        ELSE
                                                            ${Subject}    Set Variable
                                                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                                        END
                                                        ${Body}    Set Variable
                                                        ...    DT&BGV initiated not updated in Fuse for ${Alldatas}[first_name] ${Alldatas}[last_name].
                                                        ${Attachment}    Set Variable    ${doc}
                                                        ${Mailsent}    Run Keyword And Return Status
                                                        ...    Sendmail
                                                        ...    ${Recepients}
                                                        ...    ${CC}
                                                        ...    ${Subject}
                                                        ...    ${Body}
                                                        ...    ${Body1}
                                                        ...    ${Body2}
                                                        ...    ${Attachment}
                                                        IF    ${Mailsent} == True
                                                            Append To File
                                                            ...    ${Log}
                                                            ...    Mail sent for DT&BGV initiated not updated in Fuse.\n
                                                            Log To Console
                                                            ...    Mail sent for DT&BGV initiated not updated in Fuse.
                                                        ELSE
                                                            Append To File
                                                            ...    ${Log}
                                                            ...    Mail not sent for DT&BGV initiated not updated in Fuse.\n
                                                            Log To Console
                                                            ...    Mail not sent for DT&BGV initiated not updated in Fuse.
                                                        END
                                                    END
                                                END
                                            ELSE
                                                Append To File    ${Log}    Epassport extracting failed.\n
                                                Log To Console    Epassport extracting failed
                                                ${Recepients}    set variable    ${credentials}[cox_recipients]
                                                ${CC}    Set Variable    ${credentials}[Recipient]
                                                ${Subject}    Set Variable    Epassport Error
                                                ${Body}    Set Variable
                                                ...    Unable to extract the Epassport details for ${Alldatas}[first_name]_${Alldatas}[last_name]. Fuse not updated and Mail not sent for Supervisor.
                                                ${Attachment}    Set Variable    ${Epass_name}
                                                ${Mailsent}    Run Keyword And Return Status
                                                ...    Sendmail
                                                ...    ${Recepients}
                                                ...    ${CC}
                                                ...    ${Subject}
                                                ...    ${Body}
                                                ...    ${Body1}
                                                ...    ${Body2}
                                                ...    ${Attachment}
                                                IF    ${Mailsent} == True
                                                    Log To Console    Mail sent
                                                    Append To File    ${Log}    Mail sent
                                                    Execute Sql String
                                                    ...    UPDATE cox_onboarding SET status = 'PDF_Error' WHERE SSN = '${Alldatas}[ssn]'
                                                ELSE
                                                    Log To Console    Mail not sent
                                                    Append To File    ${Log}    Mail not sent
                                                END
                                            END
                                        ELSE
                                            Append To File    ${Log}    Epassport not Downloaded.\n
                                            Log To Console    Epassport not Downloaded
                                            ${Recepients}    set variable    ${credentials}[Recipient]
                                            ${CC}    Set Variable
                                            ${Subject}    Set Variable    Epassport not Downloaded - COX
                                            ${Body}    Set Variable
                                            ...    Unable to download DT initiate Epassport for ${Alldatas}[first_name]_${Alldatas}[last_name]. Kindly check the issue.
                                            ${Attachment}    Set Variable    ${doc}
                                            ${Mailsent}    Run Keyword And Return Status
                                            ...    Sendmail
                                            ...    ${Recepients}
                                            ...    ${CC}
                                            ...    ${Subject}
                                            ...    ${Body}
                                            ...    ${Body1}
                                            ...    ${Body2}
                                            ...    ${Attachment}
                                            IF    ${Mailsent} == True
                                                Log To Console    Mail sent
                                                Append To File    ${Log}    Mail sent
                                            ELSE
                                                Log To Console    Mail not sent
                                                Append To File    ${Log}    Mail not sent
                                            END
                                        END
                                    ELSE
                                        Append To File
                                        ...    ${Log}
                                        ...    Clinic not available in ZIP:${Alldatas}[zip_code] for ${Alldatas}[first_name]_${Alldatas}[last_name].\n
                                        ${Recepients}    set variable    ${credentials}[cox_recipients]
                                        ${CC}    Set Variable    ${credentials}[Recipient]
                                        ${Subject}    Set Variable    No Clinic Found - COX
                                        ${Body}    Set Variable
                                        ...    The mentioned Zip code(${Alldatas}[zip_code]) doen't have nearby clinic, Kindly send us another Zip code to processed DT.
                                        ${Attachment}    Set Variable    ${doc}
                                        ${Mailsent}    Run Keyword And Return Status
                                        ...    Sendmail
                                        ...    ${Recepients}
                                        ...    ${CC}
                                        ...    ${Subject}
                                        ...    ${Body}
                                        ...    ${Body1}
                                        ...    ${Body2}
                                        ...    ${Attachment}
                                        IF    ${Mailsent} == True
                                            Append To File    ${Log}    Mail sent for Clinic not available.\n
                                            Log To Console    Mail sent for Clinic not available.
                                            Execute Sql String
                                            ...    UPDATE cox_onboarding SET status = 'Noclinicfound' WHERE SSN = '${Alldatas}[ssn]'
                                        ELSE
                                            Append To File    ${Log}    Mail not sent for Clinic not available.\n
                                            Log To Console    Mail not sent for Clinic not available.
                                        END
                                    END
                                    # ELSE
                                    #    Append To File
                                    #    ...    ${Log}
                                    #    ...    No clinics found. Please try a different search criteria. ZIP:${Alldatas}[zip_code] for ${Alldatas}[first_name]_${Alldatas}[last_name].\n
                                    #    ${Recepients}    set variable
                                    #    ...    ${credentials}[Recipient],${Alldatas}[hr_coordinator]
                                    #    ${CC}    Set Variable
                                    #    IF    "${Alldatas}[tax_term]" == "1099"
                                    #    ${Subject}    Set Variable
                                    #    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                    #    ELSE
                                    #    ${Subject}    Set Variable
                                    #    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[first_name] ${Alldatas}[last_name]
                                    #    END
                                    #    ${Body}    Set Variable
                                    #    ...    The mentioned Zip code(${Alldatas}[zip_code]) No clinics found. Please try a different search criteria., Kindly send us another Zip code to processed DT.
                                    #    ${Attachment}    Set Variable    ${doc}
                                    #    ${Mailsent}    Run Keyword And Return Status
                                    #    ...    Sendmail
                                    #    ...    ${Recepients}
                                    #    ...    ${CC}
                                    #    ...    ${Subject}
                                    #    ...    ${Body}
                                    #    ...    ${Body1}
                                    #    ...    ${Body2}
                                    #    ...    ${Attachment}
                                    #    IF    ${Mailsent} == True
                                    #    Append To File
                                    #    ...    ${Log}
                                    #    ...    Mail sent for No clinics found. Please try a different search criteria.\n
                                    #    Log To Console
                                    #    ...    Mail sent for No clinics found. Please try a different search criteria.
                                    #    ELSE
                                    #    Append To File
                                    #    ...    ${Log}
                                    #    ...    Mail not sent for No clinics found. Please try a different search criteria.\n
                                    #    Log To Console
                                    #    ...    Mail not sent for No clinics found. Please try a different search criteria.
                                    #    END
                                    # END
                                ELSE
                                    Append To File
                                    ...    ${Log}
                                    ...    POSSIBLE DUPLICATES for ${Alldatas}[first_name]_${Alldatas}[last_name].\n
                                    Log To Console    POSSIBLE DUPLICATES
                                    ${Recepients}    set variable    ${credentials}[Recipient]
                                    ${CC}    Set Variable
                                    ${Subject}    Set Variable    Epassport POSSIBLE DUPLICATES - COX
                                    ${Body}    Set Variable
                                    ...    POSSIBLE DUPLICATES found in escreen for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly check the issue.
                                    ${Attachment}    Set Variable    ${doc}
                                    ${Mailsent}    Run Keyword And Return Status
                                    ...    Sendmail
                                    ...    ${Recepients}
                                    ...    ${CC}
                                    ...    ${Subject}
                                    ...    ${Body}
                                    ...    ${Body1}
                                    ...    ${Body2}
                                    ...    ${Attachment}
                                    IF    ${Mailsent} == True
                                        Append To File    ${Log}    Mail sent for POSSIBLE DUPLICATES.\n
                                        Log To Console    Mail sent
                                    ELSE
                                        Append To File    ${Log}    Mail not sent for POSSIBLE DUPLICATES.\n
                                        Log To Console    Mail not sent
                                    END
                                END
                            END
                        ELSE
                            Append To file    ${Log}    Technician not found.\n
                            Log To Console    Technician not found
                            ${Recepients}    Set variable    ${credentials}[cox_recipients]
                            ${CC}    Set Variable    ${credentials}[Recipient]
                            ${Subject}    Set Variable    Technician not found - COX
                            ${Body}    Set Variable
                            ...    Technician not found in Fuse for ${Alldatas}[first_name] ${Alldatas}[last_name]. Kindly check.
                            ${Attachment}    Set Variable    ${doc}
                            ${Mailsent}    Run Keyword And Return Status
                            ...    Sendmail
                            ...    ${Recepients}
                            ...    ${CC}
                            ...    ${Subject}
                            ...    ${Body}
                            ...    ${Body1}
                            ...    ${Body2}
                            ...    ${Attachment}
                            IF    ${Mailsent} == True
                                Append To file    ${Log}    Mail sent for Tech not found.\n
                                Log To Console    Mail sent
                            ELSE
                                Append To file    ${Log}    Mail not sent for Tech not found.\n
                                Log To Console    Mail not sent
                            END
                        END
                    END
                END
            ELSE
                Append To file    ${Log}    Infomart or Fuse Login Unsuccessful.\n
                Log To Console    Infomart or Fuse Login Unsuccessful.
                Close Browser
                ${Recepients}    set variable    ${credentials}[Recipient]
                ${CC}    Set Variable
                ${Subject}    Set Variable    Infomart or Fuse Login issue - COX
                ${Body}    Set Variable    Infomart or Fuse Login UnSuccessful. Kindly check the issue.
                ${Attachment}    Set Variable    ${doc}
                ${Mailsent}    Run Keyword And Return Status
                ...    Sendmail
                ...    ${Recepients}
                ...    ${CC}
                ...    ${Subject}
                ...    ${Body}
                ...    ${Body1}
                ...    ${Body2}
                ...    ${Attachment}
                IF    ${Mailsent} == True
                    Log To Console    Mail sent
                    Append To file    ${Log}    Mail sent for Infomart or Fuse Login UnSuccessful.\n
                ELSE
                    Log To Console    Mail not sent
                    Append To file    ${Log}    Mail not sent for Infomart or Fuse Login UnSuccessful.\n
                END
            END
            Disconnect From Database
            Kill Chrome Processes
            cleanup_temp_items
            Log To Console    @###############################Execution Completed###############################
            Append To file
            ...    ${Log}
            ...    @###############################Execution Completed###############################\n
        EXCEPT
            TRY
                Execute Sql String    UPDATE cox_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'
            EXCEPT
                Log To Console    Alldatas not found
            END
            Disconnect From Database
            # Kill Chrome Processes
            # cleanup_temp_items
            Append To file    ${Log}    -----------------Execution failed-----------------\n
            Log To Console    -----------------Execution failed-----------------
        END
    END
    Disconnect From Database
    Log To Console    DB Disconnected
