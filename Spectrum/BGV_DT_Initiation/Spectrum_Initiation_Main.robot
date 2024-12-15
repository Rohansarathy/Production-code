*** Settings ***
Documentation       OnBoarding Process-Spectrum BGV_DT_Initiating

Library             OperatingSystem
Library             RPA.JSON
Resource            Crimshield_login.robot
Resource            Fuselogin.robot
Resource            Techsearch.robot
Resource            Killtask.robot
Resource            Techsearch.robot
Resource            Fusedocs_Download.robot
Resource            BGV_Initiation.robot
Resource            DT_Renewal.robot
Library             DateTime
Library             Sendmail.py
Library             Phase2doc.py
Resource            DT&BGVFuseupdate.robot
Resource            DT_BGV_Renewal.robot
Library             Scope_dir.py

*** Variables ***
${doc}      ${EMPTY}
${Body1}    ${EMPTY}
${Body2}    ${EMPTY}
${CC}       ${EMPTY}


*** Tasks ***
Process
    Onboarding process


*** Keywords ***
Onboarding Process
    # Vault
    ${credentials}    Load JSON from file    credentials.json
    # DB Connect
    Connect To Database
    ...    psycopg2
    ...    ${credentials}[DB_NAME]
    ...    ${credentials}[DB_USERNAME]
    ...    ${credentials}[DB_PASSWORD]
    ...    ${credentials}[DB_HOST]
    ...    ${credentials}[DB_PORT]
    Log To Console    DB Connected
    ${result}    Query    SELECT * FROM public.spectrum_onboarding where status is Null OR status = '' LIMIT 1;
    FOR    ${row}    IN    @{result}
        ${Time}    Get Time
        ${year}    Set Variable    ${Time}[0:4]
        ${month}    Set Variable    ${Time}[5:7]
        ${day}    Set Variable    ${Time}[8:10]
        ${mint}    Set Variable    ${Time}[11:13]
        ${Sec}    Set Variable    ${Time}[14:16]
        ${Log}    Set Variable    ${credentials}[Logfile]\\DT&BGV_${day}${month}${year}_${mint}_${Sec}.txt
        Create File    ${Log}
        Log To Console    *********************************Executing the Process*********************************
        Append To file
        ...    ${Log}
        ...    *********************************Executing the Process*********************************\n
        # TRY
        Log To Console    Connecting DB.....
        Append To file    ${Log}    DB Connected\n
        # Get column names
        ${columns}    Query
        ...    SELECT column_name FROM information_schema.columns WHERE table_name = 'spectrum_onboarding' AND table_schema = 'public'
        @{column_names}    Create List
        FOR    ${col}    IN    @{columns}
            Append To List    ${column_names}    ${col}[0]
        END
        # Get data rows
        ${result}    Query    SELECT * FROM public.spectrum_onboarding where status is Null OR status = '' LIMIT 1;
        FOR    ${row}    IN    @{result}
            ${Alldatas}    Create Dictionary
            ${num_columns}    Get Length    ${column_names}
            FOR    ${i}    IN RANGE    ${num_columns}
                Set To Dictionary    ${Alldatas}    ${column_names}[${i}]    ${row}[${i}]
            END
            IF    "${Alldatas}[dt_confirmation_number]" == "None" or "${Alldatas}[dt_confirmation_number]" == ""
                ${Bot_Start_time}    Get Time
                Append To File    ${Log}    Bot_Start_time=${Bot_Start_time}.\n
                Log To Console    Bot_Start_time=${Bot_Start_time}
                ${date}    Set Variable    ${Alldatas}[license_exp_date]
                ${year}    Evaluate    '${date}'[:4]
                ${month}    Evaluate    '${date}'[5:7]
                ${day}    Evaluate    '${date}'[8:10]
                ${Exp_date}    Set Variable    ${year}-${Month}-${Day}
                ${Formatted_Exp_Date}    Convert Date
                ...    ${Exp_date}
                ...    result_format=%Y-%m-%d
                ...    date_format=%Y-%m-%d
                ${Current_Date}    Get Current Date    result_format=%Y-%m-%d
                ${Target_Date}    Add Time To Date    ${Current_Date}    5d    result_format=%Y-%m-%d
                Log To Console    "${Formatted_Exp_Date}" > "${Target_Date}"
                Append To File    ${Log}    "${Formatted_Exp_Date}" > "${Target_Date}"\n
                IF    "${Formatted_Exp_Date}" > "${Target_Date}"
                    Log To Console    License is good
                    Append To File    ${Log}    License is good\n
                    IF    "${Alldatas}[process]" == "renewal_dt" or "${Alldatas}[process]" == "renewal_bgv_dt"
                        ${CrimShield_login}    Crimshield_login    ${credentials}    ${Log}
                        IF    ${CrimShield_login} == True
                            ${login}    Set Variable    True
                        ELSE
                            ${login}    Set Variable    False
                        END
                    ELSE
                        ${CrimShield_login}    Crimshield_login    ${credentials}    ${Log}
                        ${FuseLogin}    Fuse Login    ${credentials}    ${Log}
                        IF    ${CrimShield_login} == True and ${FuseLogin} == True
                            ${login}    Set Variable    True
                        ELSE
                            ${login}    Set Variable    False
                        END
                    END
                    IF    ${login} == True
                        Append To File
                        ...    ${Log}
                        ...    @............................................Technician=${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]............................................\n
                        Log To Console
                        ...    *********************************${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]*********************************
                        ${DT_Start_time}    Get Time
                        Execute Sql String
                        ...    UPDATE spectrum_onboarding SET status = 'WIP' WHERE SSN = '${Alldatas}[ssn]'
                        Execute Sql String
                        ...    UPDATE spectrum_onboarding SET bgv_dt_initiated_date = '${DT_Start_time}' WHERE SSN = '${Alldatas}[ssn]'
                        ${Tech_DOB}    Convert To String    ${Alldatas}[tech_dob]
                        ${date_components}    Split String    ${Tech_DOB}    -
                        ${DOBYear}    Get From List    ${date_components}    0
                        ${DOBMonth}    Get From List    ${date_components}    1
                        ${DOBDay}    Get From List    ${date_components}    2
                        ${DOB}    Set Variable    ${DOBDay}${DOBMonth}${DOBYear}

                        ${FIRST_NAME}    Set Variable    ${Alldatas}[tech_first_name]
                        ${LAST_NAME}    Set Variable    ${Alldatas}[tech_last_name]

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
                        ${full_name}    Set Variable    ${Firstname}_${Lastname}

                        ${Epass_Path}    Set Variable    ${credentials}[Default_Path]\\${full_name}${DOB}
                        ${Epass_name}    Set Variable    ${Epass_Path}\\${full_name}${DOB}_DT.pdf
                        Create Directory    ${Epass_Path}
                        
                        ${Firstname}    set variable    ${Alldatas}[tech_first_name]
                        ${Lastname}    Set Variable    ${Alldatas}[tech_last_name]
                        ${PC_Number}    Set Variable    ${Alldatas}[pc_number]

                        Log To Console    process=${Alldatas}[process]
                        IF    "${Alldatas}[process]" == "renewal_dt" or "${Alldatas}[process]" == "renewal_bgv_dt"
                            IF    "${Alldatas}[process]" == "renewal_dt"
                                DT_Renewal    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Epass_name}    ${Log}
                            END
                            IF    "${Alldatas}[process]" == "renewal_bgv_dt"
                                BGV_DT_Renewal    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Epass_name}    ${Log}
                            END
                        ELSE
                            Log To Console    process=${Alldatas}[process]
                            ${Tech_found_flag}    Techsearch    ${Alldatas}    ${credentials}    ${Log}
                            IF    ${Tech_found_flag} == True
                                IF    "${Alldatas}[dt_status_received_date]" != "Doc_downloaded"
                                    IF    "${Alldatas}[process]" == "pre_employment"
                                        ${Docflag}    Fusedocs_Download    ${Alldatas}    ${Epass_Path}    ${Log}
                                    END
                                ELSE
                                    ${Docflag}    Set Variable    True
                                END
                                IF    ${Docflag} == True
                                    Log To Console    Fuse Identity Documnets downloaded successfully.
                                    Execute Sql String    UPDATE spectrum_onboarding SET dt_status_received_date = 'Doc_downloaded' WHERE SSN = '${Alldatas}[ssn]'
                                    ${Crimshield_exist}    Run Keyword And Return Status
                                    ...    File Should Exist
                                    ...    ${Epass_Path}\\Crimshield.pdf
                                    IF    ${Crimshield_exist} == True
                                        # BGV Initiation 
                                        ${file_falg}    ${Drug_test}    ${data_flag}    ${error}    ${Error_message}    BGV_Initiation    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Log}    ${OUTPUT_PDF_PATH}
                                        Log To Console    error=${error} 
                                        IF    ${error} != True
                                            IF    ${data_flag} == True
                                                IF    ${file_falg} == False
                                                    ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                                    ${CC}    Set Variable    ${credentials}[ybotID]
                                                    IF    "${Alldatas}[tax_term]" == "1099"
                                                        ${Subject}    Set Variable
                                                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                    ELSE
                                                        ${Subject}    Set Variable
                                                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                    END
                                                    ${Body}    Set Variable    Files not uploaded in Employess Control Center for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check and update manually.
                                                    ${Body1}    Set Variable
                                                    ${Body2}    Set Variable
                                                    ${Attachment}    Set Variable
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
                                                        Append To File    ${Log}    Mail sent for Files not uploaded in Employess Control Center.\n
                                                        Log To Console    Mail sent for Files not uploaded in Employess Control Center
                                                    ELSE
                                                        Append To File    ${Log}    Mail not sent for Files not uploaded in Employess Control Center.\n
                                                        Log To Console    Mail not sent for Files not uploaded in Employess Control Center
                                                    END
                                                END
                                                Log To Console    Drug_test=${Drug_test}
                                                IF    ${Drug_test} == True
                                                    Log To Console    DT initiation Start
                                                    ${handles}    Get Window Titles
                                                    Switch window    ${handles}[2]
                                                    Sleep    2s
                                                    ${dt_error}    ${Duplicates_Flag}    ${Clinic_flag}    ${Clinic_flag2}    DT Initiation    ${Alldatas}    ${credentials}    ${Epass_Path}    ${Epass_name}    ${Log}
                                                    Append To File    ${Log}    dt_error=${dt_error}\n
                                                    Log To Console    dt_error=${dt_error}
                                                    IF    ${dt_error} == False
                                                        IF    ${Duplicates_Flag} == False
                                                            IF    ${Clinic_flag} == True and ${Clinic_flag2} == True
                                                                ${File_exist}    Run Keyword And Return Status
                                                                ...    File Should Exist
                                                                ...    ${Epass_name}
                                                                IF    ${File_exist} == True
                                                                    Append To File    ${Log}    Epassport Extracting.\n
                                                                    Log To Console    Epassport Extracting
                                                                    ${Conformation_No}
                                                                    ...    ${ETA_Date}
                                                                    ...    ${PDF_Extract}
                                                                    ...    Epassport Extract
                                                                    ...    ${Alldatas}
                                                                    ...    ${Epass_name}
                                                                    ...    ${Log}
                                                                    IF    "${PDF_Extract}" == "True"
                                                                            ${Recepients}    set variable    ${Alldatas}[supplier_mail]
                                                                            ${CC}    Set Variable
                                                                            ...    ${Alldatas}[approver_mail],${Alldatas}[cc_recipients],${credentials}[ybotID]
                                                                            IF    "${Alldatas}[tax_term]" == "1099"
                                                                                ${Subject}    Set Variable
                                                                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                            ELSE
                                                                                ${Subject}    Set Variable
                                                                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                            END
                                                                            ${Body}    Set Variable
                                                                            ...    BG has been processed and DT is scheduled emailed and texted for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Make sure the tech receives it.
                                                                            ${Body1}    Set Variable
                                                                            ...    Confirmation Number = ${Conformation_No}
                                                                            ${Body2}    Set Variable
                                                                            ...    This order must be completed by: ${ETA_Date}
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
                                                                                Log To Console    Mail sent for DT & BGV initiated
                                                                                Execute Sql String
                                                                                ...    UPDATE spectrum_onboarding SET bgv_dt_initiate_mail_sent = 'Mail Sent' WHERE SSN = '${Alldatas}[ssn]'
                                                                            ELSE
                                                                                Append To File
                                                                                ...    ${Log}
                                                                                ...    Mail not sent for DT & BGV initiated.\n
                                                                                Log To Console    Mail not sent for DT & BGV initiated
                                                                            END
                                                                        # IF    "${Alldatas}[tax_term]" == "w2"
                                                                            ${FuseUpdate_Flag}    DT&BGV_Fuse_Update
                                                                            ...    ${Epass_name}
                                                                            ...    ${Alldatas}
                                                                            ...    ${credentials}
                                                                            ...    ${ETA_Date}
                                                                            ...    ${Conformation_No}
                                                                            ...    ${Log}
                                                                            Execute Sql String
                                                                            ...    UPDATE spectrum_onboarding SET status = 'Initiated' WHERE SSN = '${Alldatas}[ssn]'
                                                                            Execute Sql String
                                                                            ...    UPDATE spectrum_onboarding SET dt_status_received_date = NULL WHERE SSN = '${Alldatas}[ssn]'
                                                                            ${Bot_Stop_time}    Get Time
                                                                            Append To File    ${Log}    Bot_Stop_time=${Bot_Stop_time}.\n
                                                                            Log To Console    Bot_Stop_time=${Bot_Stop_time}

                                                                            IF    ${FuseUpdate_Flag} == False
                                                                                Append To File
                                                                                ...    ${Log}
                                                                                ...    DT&BGV initiated not updated in Fuse.\n
                                                                                Log To Console    DT&BGV initiated not updated in Fuse
                                                                                ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                                                                ${CC}    Set Variable    ${credentials}[ybotID]
                                                                                IF    "${Alldatas}[tax_term]" == "1099"
                                                                                    ${Subject}    Set Variable
                                                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                                ELSE
                                                                                    ${Subject}    Set Variable
                                                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                                END
                                                                                ${Body1}    Set Variable
                                                                                ${Body2}    Set Variable
                                                                                ${Body}    Set Variable
                                                                                ...    DT&BGV initiated not updated in Fuse for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name].
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
                                                                        # ELSE
                                                                        #     Execute Sql String
                                                                        #     ...    UPDATE spectrum_onboarding SET status = 'Initiated' WHERE SSN = '${Alldatas}[ssn]'
                                                                        #     Execute Sql String
                                                                        #     ...    UPDATE spectrum_onboarding SET dt_status_received_date = NULL WHERE SSN = '${Alldatas}[ssn]'
                                                                        # END
                                                                    ELSE
                                                                        Append To File    ${Log}    Epassport extracting failed.\n
                                                                        Log To Console    Epassport extracting failed
                                                                        ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                                                        ${CC}    Set Variable    ${credentials}[ybotID]
                                                                        IF    "${Alldatas}[tax_term]" == "1099"
                                                                            ${Subject}    Set Variable
                                                                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                        ELSE
                                                                            ${Subject}    Set Variable
                                                                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                        END
                                                                        ${Body}    Set Variable    Spectrum Process
                                                                        ${Body2}    Set Variable
                                                                        ...    Unable to extract the Epassport details for ${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]. Fuse not updated and Mail not sent for Supervisor.
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
                                                                            Log To Console    Mail sent for PDF error
                                                                            Append To File    ${Log}    Mail sent for PDF error
                                                                            Execute Sql String
                                                                            ...    UPDATE spectrum_onboarding SET status = 'PDF_Error' WHERE SSN = '${Alldatas}[ssn]'
                                                                        ELSE
                                                                            Log To Console    Mail not sent for PDF error
                                                                            Append To File    ${Log}    Mail not sent for PDF error
                                                                        END
                                                                    END
                                                                ELSE
                                                                    Append To file    ${Log}    Epassport not Downloaded.\n
                                                                    Log To Console    Epassport not Downloaded
                                                                    ${Recepients}    set variable    ${credentials}[ybotID]
                                                                    ${CC}    Set Variable
                                                                    IF    "${Alldatas}[tax_term]" == "1099"
                                                                        ${Subject}    Set Variable
                                                                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                    ELSE
                                                                        ${Subject}    Set Variable
                                                                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                    END
                                                                    ${Body}    Set Variable    Spectrum Process
                                                                    ${Body2}    Set Variable
                                                                    ...    Epassport not Downloaded for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check the issue.
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
                                                                        Append To file
                                                                        ...    ${Log}
                                                                        ...    Mail sent for Epassport not Downloaded.\n
                                                                        Log To Console    Mail sent for Epassport not Downloaded
                                                                    ELSE
                                                                        Append To file
                                                                        ...    ${Log}
                                                                        ...    Mail not sent for Epassport not Downloaded.\n
                                                                        Log To Console    Mail not sent for Epassport not Downloaded
                                                                    END
                                                                END
                                                            ELSE
                                                                ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                                                ${CC}    Set Variable    ${credentials}[ybotID]
                                                                IF    "${Alldatas}[tax_term]" == "1099"
                                                                    ${Subject}    Set Variable
                                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                ELSE
                                                                    ${Subject}    Set Variable
                                                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                                END
                                                                ${Body}    Set Variable    Spectrum Process
                                                                ${Body2}    Set Variable
                                                                ...    Clinic not available in the ZIP:${Alldatas}[clinic_zip_code] for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly share another ZIP code.
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
                                                                    Append To file
                                                                    ...    ${Log}
                                                                    ...    Mail sent for Clinic not available.\n
                                                                    Log To Console    Mail sent
                                                                    Execute Sql String
                                                                    ...    UPDATE spectrum_onboarding SET status = 'No Clinic Found' WHERE SSN = '${Alldatas}[ssn]'
                                                                ELSE
                                                                    Append To file
                                                                    ...    ${Log}
                                                                    ...    Mail not sent for Clinic not available.\n
                                                                    Log To Console    Mail not sent
                                                                END
                                                            END
                                                        ELSE
                                                            Append To file
                                                            ...    ${Log}
                                                            ...    DT initiation POSSIBLE DUPLICATES for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name].\n
                                                            Log To Console
                                                            ...    POSSIBLE DUPLICATES for ${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name].
                                                            ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                                            ${CC}    Set Variable    ${credentials}[ybotID]
                                                            IF    "${Alldatas}[tax_term]" == "1099"
                                                                ${Subject}    Set Variable
                                                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                            ELSE
                                                                ${Subject}    Set Variable
                                                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                            END
                                                            ${Body1}    Set Variable
                                                            ${Body2}    Set Variable
                                                            ${Body}    Set Variable
                                                            ...    DT initiation POSSIBLE DUPLICATES for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check the issue.
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
                                                                Append To file
                                                                ...    ${Log}
                                                                ...    Mail sent for DT initiation POSSIBLE DUPLICATES.\n
                                                                Log To Console    Mail sent for DT initiation POSSIBLE DUPLICATES
                                                            ELSE
                                                                Append To file
                                                                ...    ${Log}
                                                                ...    Mail not sent for DT initiation POSSIBLE DUPLICATES.\n
                                                                Log To Console    Mail not sent for DT initiation POSSIBLE DUPLICATES
                                                            END
                                                        END
                                                    ELSE
                                                        Append To file
                                                        ...    ${Log}
                                                        ...    Error occured in DT initiation for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name].\n
                                                        Log To Console
                                                        ...    Error occured in DT initiation for ${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name].
                                                        ${Recepients}    set variable    ${credentials}[ybotID]
                                                        ${CC}    Set Variable
                                                        IF    "${Alldatas}[tax_term]" == "1099"
                                                            ${Subject}    Set Variable
                                                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                        ELSE
                                                            ${Subject}    Set Variable
                                                            ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                                        END
                                                        ${Body1}    Set Variable
                                                        ${Body2}    Set Variable
                                                        ${Body}    Set Variable
                                                        ...    Error occured in DT initiation for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check the issue.
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
                                                            Append To file
                                                            ...    ${Log}
                                                            ...    Mail sent for Error occured in DT initiation.\n
                                                            Log To Console    Mail sent for Error occured in DT initiation
                                                        ELSE
                                                            Append To file
                                                            ...    ${Log}
                                                            ...    Mail not sent for Error occured in DT initiation.\n
                                                            Log To Console    Mail not sent for Error occured in DT initiation
                                                        END
                                                        Execute Sql String    UPDATE spectrum_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'
                                                    END
                                                ELSE
                                                    Append To file    ${Log}    BGV failed, not able to initiate DT.\n
                                                    Log To Console    BGV failed, not able to initiate DT.
                                                    Execute Sql String    UPDATE spectrum_onboarding SET dt_status = 'BG_Processed' WHERE SSN = '${Alldatas}[ssn]'
                                                    Execute Sql String    UPDATE spectrum_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'
                                                END
                                            ELSE
                                                Append To file    ${Log}    Unable to enter the details for BG.\n
                                                Log To Console    Unable to enter the details for BG. 
                                                Execute Sql String    UPDATE spectrum_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'  
                                            END
                                        ELSE
                                            ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                            ${CC}    Set Variable    ${credentials}[ybotID]
                                            IF    "${Alldatas}[tax_term]" == "1099"
                                                ${Subject}    Set Variable
                                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                            ELSE
                                                 ${Subject}    Set Variable
                                                ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                            END
                                            IF    ${Error_message} == ''
                                                ${Body}    Set Variable    Upload Documents File size limit exceed 10 mb for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name] due to error message appears in Crimshield.
                                                ${Body1}    Set Variable    
                                                ${Body2}    Set Variable 
                                            ELSE
                                                ${Body}    Set Variable    BGV/DT not able to process for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name] due to error message appears in Crimshield.
                                                ${Body1}    Set Variable    ${Error_message}
                                                ${Body2}    Set Variable    This person is currently not authorized to receive a certification, please contact your Charter representative for additional information.
                                            END
                                            ${Attachment}    Set Variable
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
                                                Append To File    ${Log}    Mail sent for BGV/DT not able to process due to error message in in Crimshield.\n
                                                Log To Console    Mail sent for BGV/DT not able to process due to error message in Crimshield
                                            Execute Sql String
                                            ...    UPDATE spectrum_onboarding SET status = 'BGV_Error' WHERE SSN = '${Alldatas}[ssn]'
                                            ELSE
                                                Append To File    ${Log}    Mail not sent for BGV/DT not able to process due to error message in Crimshield.\n
                                                Log To Console    Mail not sent for BGV/DT not able to process due to error message in Crimshield
                                            END
                                        END
                                    ELSE
                                        Append To File    ${Log}    Crimshield PDF not found.\n
                                        Log To Console    Crimshield PDF not found
                                        ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                        ${CC}    Set Variable    ${credentials}[ybotID]
                                        ${Subject}    Set Variable    Crimshield PDF not found - Spectrum
                                        ${Body1}    Set Variable
                                        ${Body2}    Set Variable
                                        ${Body}    Set Variable
                                        ...    Crimshield PDF not found for ${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]. Kindly check the issue.
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
                                            Log To Console    Mail sent Crimshield PDF not found
                                            Append To File    ${Log}    Mail sent Crimshield PDF not found
                                        ELSE
                                            Log To Console    Mail not sent Crimshield PDF not found
                                            Append To File    ${Log}    Mail not sent Crimshield PDF not found
                                        END
                                    END
                                ELSE
                                    Log To Console    Fuse Identity Documnets failed to download.
                                    Append To File    ${Log}    Fuse Identity Documnets failed to download.\n
                                    ${Recepients}    set variable    ${credentials}[ybotID]
                                    ${CC}    Set Variable    
                                    ${Subject}    Set Variable    Fuse Docs download failed - Spectrum
                                    ${Body1}    Set Variable
                                    ${Body2}    Set Variable
                                    ${Body}    Set Variable
                                    ...    Unable to download Identity Documnets from Fuse for ${Alldatas}[tech_first_name]_${Alldatas}[tech_last_name]. Kindly check the issue.
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
                                    Execute Sql String    UPDATE spectrum_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'
                                END
                            ELSE
                                Append To file    ${Log}    Technician not found.\n
                                Log To Console    Technician not found
                                Execute Sql String    UPDATE spectrum_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'
                                ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                                ${CC}    Set variable    ${credentials}[ybotID]
                                IF    "${Alldatas}[tax_term]" == "1099"
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                ELSE
                                    ${Subject}    Set Variable
                                    ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                                END
                                ${Body1}    Set Variable
                                ${Body2}    Set Variable
                                ${Body}    Set Variable
                                ...    Technician not found in Fuse for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check.
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
                    ELSE
                        Log To Console    CrimShield or Fuse application login unsuccessful.
                        Append To file    ${Log}    CrimShield or Fuse application login unsuccessful.\n
                        Close Browser
                        ${Recepients}    set variable    ${credentials}[ybotID]
                        ${CC}    Set Variable
                        ${Subject}    Set Variable    CrimShield or Fuse Login UnSuccessful.
                        ${Body1}    Set Variable
                        ${Body2}    Set Variable
                        ${Body}    Set Variable    CrimShield or Fuse Login UnSuccessful. Kindly check the issue.
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
                            Append To file    ${Log}    Mail sent for CrimShield or Fuse Login UnSuccessful.\n
                        ELSE
                            Log To Console    Mail not sent
                            Append To file    ${Log}    Mail not sent for CrimShield or Fuse Login UnSuccessful.\n
                        END
                    END
                ELSE
                    Log To Console    Need to renewal the License
                    Append To File    ${Log}    Need to renewal the License\n
                    ${Recepients}    set variable    ${Alldatas}[hr_coordinator]
                    ${CC}    Set variable    ${credentials}[ybotID]
                    IF    "${Alldatas}[tax_term]" == "1099"
                        ${Subject}    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term] - ${Alldatas}[company_name]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                    ELSE
                        ${Subject}    Set Variable
                        ...    PC-${Alldatas}[pc_number]|${Alldatas}[tax_term]|${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]
                    END
                    ${Body1}    Set Variable
                    ${Body}    Set Variable
                    ...    License need to renewal for ${Alldatas}[tech_first_name] ${Alldatas}[tech_last_name]. Kindly check.
                    ${Body2}    Set Variable    License_Exp_Date = ${Alldatas}[license_exp_date]
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
                        Append To file    ${Log}    Mail sent for License Renewal not found.\n
                        Log To Console    Mail sent
                        Execute Sql String
                        ...    UPDATE spectrum_onboarding SET status = 'License_Expired' WHERE SSN = '${Alldatas}[ssn]'
                    ELSE
                        Append To file    ${Log}    Mail not sent for License Renewal not found.\n
                        Log To Console    Mail not sent
                    END
                END
            END
        END
        Disconnect From Database
        Kill Chrome Processes
        cleanup_temp_items
        Log To Console    @###############################Execution Completed###############################
        Append To file
        ...    ${Log}
        ...    @###############################Execution Completed###############################\n
        # EXCEPT
        #    Kill Chrome Processes
        #    cleanup_temp_items
        #    Execute Sql String    UPDATE spectrum_onboarding SET status = NULL WHERE SSN = '${Alldatas}[ssn]'
        #    Disconnect From Database
        #    Append To file    ${Log}    -----------------Execution failed-----------------\n
        #    Log To Console    -----------------Execution failed-----------------
        # END
    END
    Disconnect From Database
    Log To Console    DB Disconnected
