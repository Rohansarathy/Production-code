*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem
Library     String
Library     Sendmail
Library     RPA.JavaAccessBridge
Library     RPA.PDF
Library     Process


*** Variables ***
${flag1}    ${EMPTY}
${flag2}    ${EMPTY}
${flag3}    ${EMPTY}
${flag4}    ${EMPTY}
${flag5}    ${EMPTY}


*** Keywords ***
Fusedocs_Download
    [Arguments]    ${Alldatas}    ${Epass_Path}    ${Log}

    Log To Console    Fuse Document downloading
    IF    "${Alldatas}[tax_term]" == "1099"
        ${Recruit_Data}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="recruit_data"]
        ...    5s 
        IF    ${Recruit_Data} == True
            Wait Until Element Is Visible    //*[@id="agreement_body"]/div/div[3]/div/div/input[3]    30s
            Click Element If Visible    //*[@id="agreement_body"]/div/div[3]/div/div/input[3]
            ${Uploading_Form}    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //*[@id="file_uplode_modal_body"]
            ...    5s
            IF    ${Uploading_Form} == True
                #################################Indentity Table#################################
                Log To Console    ----------------Indentity Table-------------------
                Wait Until Element Is Visible    //*[@id="filetype"]    5s
                Select From List By Value    //*[@id="filetype"]    6
                Sleep    2s
                ${IdentityTable}    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="filedetailsbody"]
                ...    5s
                IF    ${IdentityTable} == True
                    # Drivers_License
                    ${Driver_front}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (front)')]]//td[4]//a
                    ...    5s
                    IF    ${Driver_front} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (front)')]]//td[4]//a
                    ELSE
                        ${Driver_front}    Run Keyword And Return Status
                        ...    Wait Until Element Is Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers')]]//td[4]//a
                        ...    5s
                        IF    ${Driver_front} == True
                            Click Element If Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers')]]//td[4]//a
                        END
                    END
                    IF    ${Driver_front} == True
                        Sleep    3s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\DL_front.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Drivers License front side is Re-downloaded failed
                        END
                        Log To Console    Drivers License front side is downloaded
                        ${DL_front}    Run Keyword And Return Status
                        ...    File Should Exist
                        ...    ${Epass_Path}\\DL_front.jpg
                        IF    ${DL_front} == True
                            Append To File    ${Log}    Drivers License front side is downloaded\n
                            ${front}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Drivers License front side is not downloaded\n
                            ${front}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Drivers License front side is not found.
                        Append To File    ${Log}    Drivers License front side is not found\n
                        ${front}    Set Variable    False
                    END
                    
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${Driver_back}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (back)')]]//td[4]//a
                    ...    5s
                    IF    ${Driver_back} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (back)')]]//td[4]//a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\DL_back.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Drivers License back side is Re-downloaded failed
                        END
                        Log To Console    Drivers License back side is downloaded
                        ${DL_back}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\DL_back.jpg
                        IF    ${DL_back} == True
                            Append To File    ${Log}    Drivers License back side is downloaded\n
                            ${back}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Drivers License back side is not downloaded\n
                            ${back}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Drivers License back side is not found.
                        Append To File    ${Log}    Drivers License back side is not found\n
                        ${back}    Set Variable    False
                    END
                    IF    ${front} == True and ${back} == True
                        ${flag1}    Set Variable    True
                    ELSE
                        ${flag1}    Set Variable    False
                    END

                    # Crimshield Authorization Forms
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${Crimshield}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'crimshield')]]//td[4]//a
                    ...    5s
                    IF    ${Crimshield} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'crimshield')]]//td[4]//a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Crimshield Authorization Forms Re-downloaded failed
                        END
                        Log To Console    Crimshield Authorization Forms downloaded
                        ${Shield}    Run Keyword And Return Status
                        ...    File Should Exist
                        ...    ${Epass_Path}\\Crimshield.pdf
                        IF    ${Shield} == True
                            Append To File    ${Log}    Crimshield Authorization Forms downloaded\n
                            ${flag2}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Crimshield Authorization Forms downloaded\n
                            ${flag2}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Crimshield Authorization Forms not found.
                        Append To File    ${Log}    Crimshield Authorization Forms not found\n
                        ${flag2}    Set Variable    False
                        ${Shield}    Set Variable    False
                    END

                    # Headshot Picture
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${Picture}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'headshot')]]//td[4]//a
                    ...    5s
                    IF    ${Picture} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'headshot')]]//td[4]//a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\Headshot.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Headshot Picture Re-downloaded failed
                        END
                        Log To Console    Headshot Picture downloaded
                        ${Headshot}    Run Keyword And Return Status
                        ...    File Should Exist
                        ...    ${Epass_Path}\\Headshot.jpg
                        IF    ${Headshot} == True
                            Append To File    ${Log}    Headshot Picture downloaded\n
                            ${flag5}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Headshot Picture not downloaded\n
                            ${flag5}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Headshot Picture not found.
                        Append To File    ${Log}    Headshot Picture not found\n
                        ${flag5}    Set Variable    False
                    END

                    # Phase2_Doc
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${Phase2_Doc}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[4]//a
                    ...    5s
                    IF    ${Phase2_Doc} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[4]//a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\Phase2.pdf
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Phase2 doc Re-downloaded failed
                        END
                        Log To Console    Phase2 doc downloaded
                        ${Phase2}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\Phase2.pdf
                        IF    ${Phase2} == True
                            Append To File    ${Log}    Phase2 doc downloaded\n
                            ${flag4}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Phase2 doc not downloaded\n
                            ${flag4}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Phase2 doc not found.
                        Append To File    ${Log}    Phase2 doc not found\n
                        ${flag4}    Set Variable    False
                    END
                ELSE
                    Log To Console    Forms of Identity Table not found.
                    Append To File    ${Log}    Forms of Identity Table not found\n
                    ${Docflag}    Set Variable    False
                END

                #################################Mandatory Table#################################
                Log To Console    ----------------Mandatory Table-------------------
                ${handles}    Get Window Titles
                Switch window    ${handles}[1]
                Sleep    1s
                Wait Until Element Is Visible    //*[@id="filetype"]    5s
                Select From List By Value    //*[@id="filetype"]    8
                Sleep    2s
                ${MandatryTable}    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="mandatry_uplode_form"]
                ...    10s
                IF    ${MandatryTable} == True
                    # Social Security Number
                    ${SSN}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'social security')]]//td[4]//a
                    ...    5s
                    IF    ${SSN} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'social security')]]//td[4]//a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\SSN.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    SSN Re-downloaded failed
                        END
                        Log To Console    SSN downloaded
                        ${Social}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\SSN.jpg
                        IF    ${Social} == True
                            Append To File    ${Log}    SSN downloaded\n
                            ${flag3}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    SSN downloaded\n
                            ${flag3}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    SSN not found
                        Append To File    ${Log}    SSN not found\n
                        ${flag3}    Set Variable    False
                    END

                    # Driving License back side
                    IF    ${back} == False
                        ${handles}    Get Window Titles
                        Switch window    ${handles}[1]
                        Sleep    1s
                        ${Driver_back}    Run Keyword And Return Status
                        ...    Wait Until Element Is Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'dl back side')]]//td[4]//a
                        ...    5s
                        IF    ${Driver_back} == True
                            Click Element If Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'dl back side')]]//td[4]//a
                            Sleep    4s
                            RPA.Desktop.Press Keys    CTRL    s
                            Sleep    3s
                            RPA.Desktop.Type Text    ${Epass_Path}\\DL_back.jpg
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    1s
                            TRY
                                RPA.Desktop.Press Keys    Tab
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    2s
                            EXCEPT
                                Log To Console    Drivers License back side is Re-downloaded failed
                            END
                            Log To Console    Drivers License back side is downloaded
                            ${DL_back}    Run Keyword And Return Status
                            ...    File Should Exist
                            ...    ${Epass_Path}\\DL_back.jpg
                            IF    ${DL_back} == True
                                Append To File    ${Log}    Drivers License back side is downloaded\n
                                ${back}    Set Variable    True
                            ELSE
                                Append To File    ${Log}    Drivers License back side is not downloaded\n
                                ${back}    Set Variable    False
                            END
                            ${handles}    Get Window Handles
                            Switch window    ${handles}[2]
                            Close Window
                        ELSE
                            Log To Console    Drivers License back side is not found.
                            Append To File    ${Log}    Drivers License back side is not found\n
                            ${back}    Set Variable    False
                        END
                        IF    ${front} == True and ${back} == True
                            ${flag1}    Set Variable    True
                        ELSE
                            ${flag1}    Set Variable    False
                        END
                    END
                    
                    IF    ${flag5} == False
                        # Headshot Picture
                        ${handles}    Get Window Titles
                        Switch window    ${handles}[1]
                        Sleep    1s
                        ${Picture}    Run Keyword And Return Status
                        ...    Wait Until Element Is Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'headshot')]]//td[4]//a
                        ...    5s
                        IF    ${Picture} == True
                            Click Element If Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'headshot')]]//td[4]//a
                            Sleep    4s
                            RPA.Desktop.Press Keys    CTRL    s
                            Sleep    3s
                            RPA.Desktop.Type Text    ${Epass_Path}\\Headshot.jpg
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    1s
                            TRY
                                RPA.Desktop.Press Keys    Tab
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    2s
                            EXCEPT
                                Log To Console    Headshot Picture Re-downloaded failed
                            END
                            Log To Console    Headshot Picture downloaded
                            ${Headshot}    Run Keyword And Return Status
                            ...    File Should Exist
                            ...    ${Epass_Path}\\Headshot.jpg
                            IF    ${Headshot} == True
                                Append To File    ${Log}    Headshot Picture downloaded\n
                                ${flag5}    Set Variable    True
                            ELSE
                                Append To File    ${Log}    Headshot Picture not downloaded\n
                                ${flag5}    Set Variable    False
                            END
                            ${handles}    Get Window Handles
                            Switch window    ${handles}[2]
                            Close Window
                        ELSE
                            Log To Console    Headshot Picture not found.
                            Append To File    ${Log}    Headshot Picture not found\n
                            ${flag5}    Set Variable    False
                        END
                    END
                    # Phase2_Doc
                    IF    ${flag4} == False
                        ${handles}    Get Window Titles
                        Switch window    ${handles}[1]
                        Sleep    1s
                        ${Phase2_Doc}    Run Keyword And Return Status
                        ...    Wait Until Element Is Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[4]//a
                        ...    5s
                        IF    ${Phase2_Doc} == True
                            Click Element If Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[4]//a
                            Sleep    4s
                            RPA.Desktop.Press Keys    CTRL    s
                            Sleep    3s
                            RPA.Desktop.Type Text    ${Epass_Path}\\Phase2.pdf
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    1s
                            TRY
                                RPA.Desktop.Press Keys    Tab
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    2s
                            EXCEPT
                                Log To Console    Phase2 doc Re-downloaded failed
                            END
                            Log To Console    Phase2 doc downloaded
                            ${Phase2}    Run Keyword And Return Status
                            ...    File Should Exist
                            ...    ${Epass_Path}\\Phase2.pdf
                            IF    ${Phase2} == True
                                Append To File    ${Log}    Phase2 doc downloaded\n
                                ${flag4}    Set Variable    True
                            ELSE
                                Append To File    ${Log}    Phase2 doc not downloaded\n
                                ${flag4}    Set Variable    False
                            END
                            ${handles}    Get Window Handles
                            Switch window    ${handles}[2]
                            Close Window
                        ELSE
                            Log To Console    Phase2 doc not found.
                            Append To File    ${Log}    Phase2 doc not found\n
                            ${flag4}    Set Variable    False
                        END
                    ELSE
                        Log To Console   Driving License Back side already downloaded.
                        Append To File    ${Log}    Driving License Back side already downloaded.\n
                    END
                ELSE
                    Log To Console    Contractor tech application doc Table not found
                    Append To File    ${Log}    Contractor tech application doc Table not found\n
                    ${Docflag}    Set Variable    False
                END

                #################################Additional Table#################################
                IF    ${Shield} == False or ${flag4} == False
                    Log To Console    ----------------Additional Table-------------------
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    Wait Until Element Is Visible    //*[@id="filetype"]    5s
                    Select From List By Value    //*[@id="filetype"]    10
                    Sleep    2s
                    ${Additionaldoc}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //*[@id="filedetailsbody"]
                    ...    10s
                    IF    ${Additionaldoc} == True
                        # Crimshild Additional check
                        IF    ${Shield} == False
                            ${Crim}    Run Keyword And Return Status
                            ...    Wait Until Element Is Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'crimshield')]//td[4]//a[contains(text(), 'View File')]
                            ...    5s
                            IF    ${Crim} == True
                                Click Element If Visible
                                ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'crimshield')]//td[4]//a[contains(text(), 'View File')]
                                Sleep    4s
                                RPA.Desktop.Press Keys    CTRL    s
                                Sleep    3s
                                RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    1s
                                TRY
                                    RPA.Desktop.Press Keys    Tab
                                    Sleep    1s
                                    RPA.Desktop.Press Keys    Enter
                                    Sleep    2s
                                EXCEPT
                                    Log To Console    Crimshield Re-downloaded failed
                                END
                                Log To Console    Crimshield downloaded
                                ${Shield}    Run Keyword And Return Status
                                ...    File Should Exist
                                ...    ${Epass_Path}\\Crimshield.pdf
                                IF    ${Shield} == True
                                    Append To File    ${Log}    Crimshield downloaded\n
                                    ${flag2}    Set Variable    True
                                ELSE
                                    Append To File    ${Log}    Crimshield downloaded\n
                                    ${flag2}    Set Variable    False
                                END
                                ${handles}    Get Window Handles
                                Switch window    ${handles}[2]
                                Close Window
                            ELSE
                                Log To Console    Crimshield not found
                                Append To File    ${Log}    Crimshield not found\n
                                ${flag2}    Set Variable    False
                            END
                        ELSE
                            Log To Console    Crimshield already downloaded in Indentity table.
                            Append To File    ${Log}    Crimshield already downloaded in Indentity table.\n
                            ${Shield}    Set Variable    True
                        END

                        # Phase2_Doc
                        IF    ${flag4} == False
                            ${handles}    Get Window Titles
                            Switch window    ${handles}[1]
                            Sleep    1s
                            ${Phase2_Doc}    Run Keyword And Return Status
                            ...    Wait Until Element Is Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'phase')]//td[4]//a[contains(text(), 'View File')]
                            ...    5s
                            IF    ${Phase2_Doc} == True
                                Click Element If Visible
                                ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'phase')]//td[4]//a[contains(text(), 'View File')]
                                Sleep    4s
                                RPA.Desktop.Press Keys    CTRL    s
                                Sleep    3s
                                RPA.Desktop.Type Text    ${Epass_Path}\\Phase2.pdf
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    1s
                                TRY
                                    RPA.Desktop.Press Keys    Tab
                                    Sleep    1s
                                    RPA.Desktop.Press Keys    Enter
                                    Sleep    2s
                                EXCEPT
                                    Log To Console    Phase2 doc Re-downloaded failed
                                END
                                Log To Console    Phase2 doc downloaded
                                ${Phase2}    Run Keyword And Return Status
                                ...    File Should Exist
                                ...    ${Epass_Path}\\Phase2.pdf
                                IF    ${Phase2} == True
                                    Append To File    ${Log}    Phase2 doc downloaded\n
                                    ${flag4}    Set Variable    True
                                ELSE
                                    Append To File    ${Log}    Phase2 doc not downloaded\n
                                    ${flag4}    Set Variable    False
                                END
                                ${handles}    Get Window Handles
                                Switch window    ${handles}[2]
                                Close Window
                            ELSE
                                Log To Console    Phase2 doc not found.
                                Append To File    ${Log}    Phase2 doc not found\n
                                ${flag4}    Set Variable    False
                            END
                        END
                    ELSE
                        Log To Console    Additional doc not found
                        Append To File    ${Log}    Additional doc not found\n
                        ${Docflag}    Set Variable    False
                    END
                END
            ELSE
                Log To Console    Uploading Popup not found
                Append To File    ${Log}    Uploading Popup not found\n
                ${Docflag}    Set Variable    False
            END
        ELSE
            Log To Console    Contractor Recruit Data page not found
            Append To File    ${Log}    Contractor Recruit Data page not found\n
            ${Docflag}    Set Variable    False
        END
    ELSE
        ${Recruit_Data}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //*[@id="recruit_modal_body"]
        ...    5s
        IF    ${Recruit_Data} == True
            Wait Until Element Is Visible    //*[@id="recruit_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[4]/input    30s
            Click Element If Visible
            ...    //*[@id="recruit_modal_body"]/div[1]/div/div[2]/div[2]/table/tbody/tr/td[4]/input
            ${Uploading_Form}    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //*[@id="filetype"]
            # ...    //*[@id="file_uplode_modal_dialog"]/div
            ...    5s
            IF    ${Uploading_Form} == True
                #################################Indentity Table#################################
                Log To Console    ----------------Indentity Table-------------------
                Wait Until Element Is Visible    //*[@id="filetype"]    5s
                Select From List By Value    //*[@id="filetype"]    1
                Sleep    2s
                ${IdentityTable}    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="filedetailsbody"]
                ...    5s
                IF    ${IdentityTable} == True
                    # Drivers_License
                    ${Driver_front}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (front)')]]//td[5]//label/a
                    IF    ${Driver_front} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (front)')]]//td[5]//label/a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\DL_front.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Drivers License front side is Re-downloaded failed
                        END
                        ${DL_front}    Run Keyword And Return Status
                        ...    File Should Exist
                        ...    ${Epass_Path}\\DL_front.jpg
                        IF    ${DL_front} == True
                            Append To File    ${Log}    Drivers License front side is downloaded\n
                            Log To Console    Drivers License front side is downloaded
                            ${front}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Drivers License front side is not downloaded\n
                            Log To Console    Drivers License front side is not downloaded
                            ${front}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Drivers License front side is not found.
                        Append To File    ${Log}    Drivers License front side is not found\n
                        ${front}    Set Variable    False
                    END
                    Log To Console    front=${front}
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${Driver_back}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (back)')]]//td[5]//label/a
                    ...    5s
                    Log To Console    Driver_back=${Driver_back}
                    IF    ${Driver_back} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'drivers license (back)')]]//td[5]//label/a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\DL_back.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Drivers License back side is Re-downloaded failed
                        END
                        Log To Console    Drivers License back side is downloaded
                        ${DL_back}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\DL_back.jpg
                        IF    ${DL_back} == True
                            Append To File    ${Log}    Drivers License back side is downloaded\n
                            ${back}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Drivers License back side is not downloaded\n
                            ${back}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Drivers License back side is not found.
                        Append To File    ${Log}    Drivers License back side is not found\n
                        ${back}    Set Variable    False
                    END
                    IF    ${front} == True and ${back} == True
                        ${flag1}    Set Variable    True
                    ELSE
                        ${flag1}    Set Variable    False
                    END

                    # Social Security Account Number Card
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${SSN}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'social security account number card')]]//td[5]//label/a
                    ...    5s
                    IF    ${SSN} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'social security account number card')]]//td[5]//label/a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\SSN.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    SSN Re-downloaded failed
                        END
                        ${Social}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\SSN.jpg
                        IF    ${Social} == True
                            Append To File    ${Log}    SSN downloaded\n
                            Log To Console    SSN downloaded
                            ${flag3}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    SSN not downloaded\n
                            Log To Console    SSN not downloaded
                            ${flag3}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    SSN not found.
                        Append To File    ${Log}    SSN not found\n
                        ${flag3}    Set Variable    False
                    END

                    # Headshot Picture
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${Picture}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'head shot picture')]]//td[5]//a
                    ...    5s
                    IF    ${Picture} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'head shot picture')]]//td[5]//a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\Headshot.jpg
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Headshot Picture Re-downloaded failed
                        END
                        Log To Console    Headshot Picture downloaded
                        ${Headshot}    Run Keyword And Return Status
                        ...    File Should Exist
                        ...    ${Epass_Path}\\Headshot.jpg
                        IF    ${Headshot} == True
                            Append To File    ${Log}    Headshot Picture downloaded\n
                            ${flag5}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Headshot Picture not downloaded\n
                            ${flag5}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Headshot Picture not found.
                        Append To File    ${Log}    Headshot Picture not found\n
                        ${flag5}    Set Variable    False
                    END

                    # Phase2_Doc
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    ${Phase2_Doc}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[5]//label/a
                    ...    5s
                    IF    ${Phase2_Doc} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[5]//label/a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\Phase2.pdf
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Phase2 doc Re-downloaded failed
                        END
                        Log To Console    Phase2 doc downloaded
                        ${Phase2}    Run Keyword And Return Status    File Should Exist    ${Epass_Path}\\Phase2.pdf
                        IF    ${Phase2} == True
                            Append To File    ${Log}    Phase2 doc downloaded\n
                            ${flag4}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Phase2 doc not downloaded\n
                            ${flag4}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        Log To Console    Phase2 doc not found.
                        Append To File    ${Log}    Phase2 doc not found\n
                        ${flag4}    Set Variable    False
                    END
                ELSE
                    Log To Console    Forms of Identity Table not found.
                    Append To File    ${Log}    Forms of Identity Table not found\n
                    ${Docflag}    Set Variable    False
                END

                #################################Mandatory Table#################################
                Log To Console    ----------------Mandatory Table-------------------
                ${handles}    Get Window Titles
                Switch window    ${handles}[1]
                Sleep    1s
                Wait Until Element Is Visible    //*[@id="filetype"]    5s
                Select From List By Value    //*[@id="filetype"]    3
                Sleep    2s
                ${MandatryTable}    Run Keyword And Return Status
                ...    Wait Until Element Is Visible
                ...    //*[@id="mandatry_uplode_form"]
                ...    5s
                IF    ${MandatryTable} == True
                    # Crimshield Authorization Forms
                    ${Crim}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'crimshield')]]//td[5]//label/a
                    ...    5s
                    IF    ${Crim} == False
                        ${Crim}    Run Keyword And Return Status
                        ...    Wait Until Element Is Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'drug&background-crimshield')]]//td[5]//label/a
                        ...    5s
                    END
                    IF    ${Crim} == True
                        Click Element If Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'crimshield')]]//td[5]//label/a
                        Sleep    4s
                        RPA.Desktop.Press Keys    CTRL    s
                        Sleep    3s
                        RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                        Sleep    1s
                        RPA.Desktop.Press Keys    Enter
                        Sleep    1s
                        Log To Console    Crimshield Authorization Forms downloaded
                        TRY
                            RPA.Desktop.Press Keys    Tab
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    2s
                        EXCEPT
                            Log To Console    Crimshield Authorization Forms Re-downloaded failed
                        END
                        Log To Console    Crimshield Authorization Forms downloaded
                        ${Shield}    Run Keyword And Return Status
                        ...    File Should Exist
                        ...    ${Epass_Path}\\Crimshield.pdf
                        IF    ${Shield} == True
                            Append To File    ${Log}    Crimshield Authorization Forms downloaded\n
                            ${flag2}    Set Variable    True
                        ELSE
                            Append To File    ${Log}    Crimshield Authorization Forms downloaded\n
                            ${flag2}    Set Variable    False
                        END
                        ${handles}    Get Window Handles
                        Switch window    ${handles}[2]
                        Close Window
                    ELSE
                        # ${Crim2}    Run Keyword And Return Status
                        # ...    Wait Until Element Is Visible
                        # ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//input[@id='dynamicfile999_1' and contains(translate(@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'crimshield form')]]//td[5]//label/a
                        # ...    5s
                        # IF    ${Crim2} == True
                        #     Click Element If Visible
                        #     ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//input[@id='dynamicfile999_1' and contains(translate(@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'crimshield form')]]//td[5]//label/a
                        #     Sleep    4s
                        #     RPA.Desktop.Press Keys    CTRL    s
                        #     Sleep    3s
                        #     RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                        #     Sleep    1s
                        #     RPA.Desktop.Press Keys    Enter
                        #     Sleep    1s
                        #     Log To Console    Crimshield Authorization Forms downloaded
                        #     TRY
                        #         RPA.Desktop.Press Keys    Tab
                        #         Sleep    1s
                        #         RPA.Desktop.Press Keys    Enter
                        #         Sleep    2s
                        #     EXCEPT
                        #         Log To Console    Crimshield Authorization Forms Re-downloaded failed
                        #     END
                        #     Log To Console    Crimshield Authorization Forms downloaded
                        #     ${Shield}    Run Keyword And Return Status
                        #     ...    File Should Exist
                        #     ...    ${Epass_Path}\\Crimshield.pdf
                        #     IF    ${Shield} == True
                        #         Append To File    ${Log}    Crimshield Authorization Forms downloaded\n
                        #         ${flag2}    Set Variable    True
                        #     ELSE
                        #         Append To File    ${Log}    Crimshield Authorization Forms downloaded\n
                        #         ${flag2}    Set Variable    False
                        #     END
                        #     ${handles}    Get Window Handles
                        #     Switch window    ${handles}[2]
                        #     Close Window
                        # ELSE
                        #     Log To Console    Crimshield Authorization Forms not found
                        #     Append To File    ${Log}    Crimshield Authorization Forms not found\n
                        #     ${flag2}    Set Variable    False
                        #     ${Shield}    Set Variable    False
                        # END
                        Log To Console    Crimshield Authorization Forms not found
                        Append To File    ${Log}    Crimshield Authorization Forms not found\n
                        ${flag2}    Set Variable    False
                        ${Shield}    Set Variable    False
                    END

                    # Phase2_Doc
                    IF    ${flag4} == False
                        ${handles}    Get Window Titles
                        Switch window    ${handles}[1]
                        Sleep    1s
                        ${Phase2_Doc}    Run Keyword And Return Status
                        ...    Wait Until Element Is Visible
                        ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[5]//label/a
                        ...    5s
                        IF    ${Phase2_Doc} == True
                            Click Element If Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[2]//h4[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'phase')]]//td[5]//label/a
                            Sleep    4s
                            RPA.Desktop.Press Keys    CTRL    s
                            Sleep    3s
                            RPA.Desktop.Type Text    ${Epass_Path}\\Phase2.pdf
                            Sleep    1s
                            RPA.Desktop.Press Keys    Enter
                            Sleep    1s
                            TRY
                                RPA.Desktop.Press Keys    Tab
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    2s
                            EXCEPT
                                Log To Console    Phase2 doc Re-downloaded failed
                            END
                            Log To Console    Phase2 doc downloaded
                            ${Phase2}    Run Keyword And Return Status
                            ...    File Should Exist
                            ...    ${Epass_Path}\\Phase2.pdf
                            IF    ${Phase2} == True
                                Append To File    ${Log}    Phase2 doc downloaded\n
                                ${flag4}    Set Variable    True
                            ELSE
                                Append To File    ${Log}    Phase2 doc not downloaded\n
                                ${flag4}    Set Variable    False
                            END
                            ${handles}    Get Window Handles
                            Switch window    ${handles}[2]
                            Close Window
                        ELSE
                            Log To Console    Phase2 doc not found.
                            Append To File    ${Log}    Phase2 doc not found\n
                            ${flag4}    Set Variable    False
                        END
                    END
                ELSE
                    Log To Console    Contractor tech application doc Table not found
                    Append To File    ${Log}    Contractor tech application doc Table not found\n
                    ${Docflag}    Set Variable    False
                END

                #################################Additional Table#################################
                IF    ${Shield} == False or ${flag4} == False
                    Log To Console    ----------------Additional Table-------------------
                    ${handles}    Get Window Titles
                    Switch window    ${handles}[1]
                    Sleep    1s
                    Wait Until Element Is Visible    //*[@id="filetype"]    5s
                    Select From List By Value    //*[@id="filetype"]    7
                    Sleep    2s
                    ${Additionaldoc}    Run Keyword And Return Status
                    ...    Wait Until Element Is Visible
                    ...    //*[@id="filedetailsbody"]
                    ...    10s
                    IF    ${Additionaldoc} == True
                        # Crimshild Additional check
                        IF    ${Shield} == False
                            ${Crim}    Run Keyword And Return Status
                            ...    Wait Until Element Is Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'crimshield')]//td[4]//a[contains(text(), 'View File')]
                            ...    5s
                            IF    ${Crim} == True
                                Click Element If Visible
                                ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'Crimshield')]//td[4]//a[contains(text(), 'View File')]
                                Sleep    4s
                                RPA.Desktop.Press Keys    CTRL    s
                                Sleep    3s
                                RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    1s
                                TRY
                                    RPA.Desktop.Press Keys    Tab
                                    Sleep    1s
                                    RPA.Desktop.Press Keys    Enter
                                    Sleep    2s
                                EXCEPT
                                    Log To Console    Crimshield Re-downloaded failed
                                END
                                Log To Console    Crimshield downloaded
                                ${Shield}    Run Keyword And Return Status
                                ...    File Should Exist
                                ...    ${Epass_Path}\\Crimshield.pdf
                                IF    ${Shield} == True
                                    Append To File    ${Log}    Crimshield downloaded\n
                                    ${flag2}    Set Variable    True
                                ELSE
                                    Append To File    ${Log}    Crimshield downloaded\n
                                    ${flag2}    Set Variable    False
                                END
                                ${handles}    Get Window Handles
                                Switch window    ${handles}[2]
                                Close Window
                            ELSE
                                Log To Console    Crimshield not found
                                Append To File    ${Log}    Crimshield not found\n
                                ${flag2}    Set Variable    False
                            END
                            IF    ${flag2} == False
                                ${Crim}    Run Keyword And Return Status
                                ...    Wait Until Element Is Visible
                                ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[contains(translate(.//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'crimshield')]]//td[5]//a[contains(text(), 'View File')]
                                ...    5s
                                IF    ${Crim} == True
                                    Click Element If Visible
                                    ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[td[contains(translate(.//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'crimshield')]]//td[5]//a[contains(text(), 'View File')]
                                    Sleep    4s
                                    RPA.Desktop.Press Keys    CTRL    s
                                    Sleep    3s
                                    RPA.Desktop.Type Text    ${Epass_Path}\\Crimshield.pdf
                                    Sleep    1s
                                    RPA.Desktop.Press Keys    Enter
                                    Sleep    1s
                                    TRY
                                        RPA.Desktop.Press Keys    Tab
                                        Sleep    1s
                                        RPA.Desktop.Press Keys    Enter
                                        Sleep    2s
                                    EXCEPT
                                        Log To Console    Crimshield Re-downloaded failed
                                    END
                                    Log To Console    Crimshield downloaded
                                    ${Shield}    Run Keyword And Return Status
                                    ...    File Should Exist
                                    ...    ${Epass_Path}\\Crimshield.pdf
                                    IF    ${Shield} == True
                                        Append To File    ${Log}    Crimshield downloaded\n
                                        ${flag2}    Set Variable    True
                                    ELSE
                                        Append To File    ${Log}    Crimshield downloaded\n
                                        ${flag2}    Set Variable    False
                                    END
                                    ${handles}    Get Window Handles
                                    Switch window    ${handles}[2]
                                    Close Window
                                ELSE
                                    Log To Console    Crimshield not found
                                    Append To File    ${Log}    Crimshield not found\n
                                    ${flag2}    Set Variable    False
                                END
                            END
                        ELSE
                            Log To Console    Crimshield already downloaded in Indentity table.
                            Append To File    ${Log}    Crimshield already downloaded in Indentity table.\n
                            ${Shield}    Set Variable    True
                        END

                        # Phase2_Doc
                        IF    ${flag4} == False
                            ${handles}    Get Window Titles
                            Switch window    ${handles}[1]
                            Sleep    1s
                            ${Phase2_Doc}    Run Keyword And Return Status
                            ...    Wait Until Element Is Visible
                            ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'phase')]//td[4]//a[contains(text(), 'View File')]
                            ...    5s
                            IF    ${Phase2_Doc} == True
                                Click Element If Visible
                                ...    //div[@class='qc_mainPrat']//table[@id='dataTable']//tbody//tr[contains(translate(td[2]//input[@type='text']/@value, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'phase')]//td[4]//a[contains(text(), 'View File')]
                                Sleep    4s
                                RPA.Desktop.Press Keys    CTRL    s
                                Sleep    3s
                                RPA.Desktop.Type Text    ${Epass_Path}\\Phase2.pdf
                                Sleep    1s
                                RPA.Desktop.Press Keys    Enter
                                Sleep    1s
                                TRY
                                    RPA.Desktop.Press Keys    Tab
                                    Sleep    1s
                                    RPA.Desktop.Press Keys    Enter
                                    Sleep    2s
                                EXCEPT
                                    Log To Console    Phase2 doc Re-downloaded failed
                                END
                                Log To Console    Phase2 doc downloaded
                                ${Phase2}    Run Keyword And Return Status
                                ...    File Should Exist
                                ...    ${Epass_Path}\\Phase2.pdf
                                IF    ${Phase2} == True
                                    Append To File    ${Log}    Phase2 doc downloaded\n
                                    ${flag4}    Set Variable    True
                                ELSE
                                    Append To File    ${Log}    Phase2 doc not downloaded\n
                                    ${flag4}    Set Variable    False
                                END
                                ${handles}    Get Window Handles
                                Switch window    ${handles}[2]
                                Close Window
                            ELSE
                                Log To Console    Phase2 doc not found.
                                Append To File    ${Log}    Phase2 doc not found\n
                                ${flag4}    Set Variable    False
                            END
                        END
                    ELSE
                        Log To Console    Additional doc not found
                        Append To File    ${Log}    Additional doc not found\n
                        ${Docflag}    Set Variable    False
                    END
                END
            ELSE
                Log To Console    Uploading Popup not found
                Append To File    ${Log}    Uploading Popup not found\n
                ${Docflag}    Set Variable    False
            END
        ELSE
            Log To Console    Recruit Data page not found
            Append To File    ${Log}    Recruit Data page not found\n
            ${Docflag}    Set Variable    False
        END
    END
    ${handles}    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    Click Element If Visible    //div[@id='file_uplode_modal']//div[@class='modal-header']//button[@class='close']
    Sleep    2s
    Click Element If Visible    (//div[@class='modal-header']/button[@class='close'])[4]
    IF    ${flag1} == True and ${flag2} == True and ${flag3} == True
        ${Docflag}    Set Variable    True
        Append To File    ${Log}    All docs downloaded successfully from Fuse\n
    ELSE
        Append To File    ${Log}    All docs not downloaded from Fuse\n
        ${Docflag}    Set Variable    False
    END
    RETURN    ${Docflag}    ${flag4}
