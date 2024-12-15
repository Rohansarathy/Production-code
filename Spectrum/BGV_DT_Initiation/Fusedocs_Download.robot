*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Desktop
Library     OperatingSystem
Library     String
Library     Sendmail
Library     RPA.JavaAccessBridge
Library     RPA.PDF
Library     Process
Library     PDFtoJPG.py


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

    ${DB_Check}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    //*[@id="submit_for_drug_test"]
    ...    10s
    IF    ${DB_Check} == True
        Log To Console    DL back
        ${Driving_Back}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //tr[td[normalize-space(text())='Drivers License (back)']]//a[text()='View']    5s
        IF    ${Driving_Back} == True
            Click Element If Visible
            ...    //tr[td[normalize-space(text())='Drivers License (back)']]//a[text()='View']
            Sleep    4s
            RPA.Desktop.Press Keys    CTRL    s
            Sleep    3s
            RPA.Desktop.Type Text    ${Epass_Path}\\DL_back
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
            # ${DL_back}    Run Keyword And Return Status
            # ...    File Should Exist
            # ...    ${Epass_Path}\\DL_back    5s
            # IF    ${DL_back} == True
            #    Append To File    ${Log}    Drivers License back side is downloaded\n
            #    Log To Console    Drivers License back side is downloaded
            #    ${back}    Set Variable    True
            # ELSE
            #    Append To File    ${Log}    Drivers License back side is not downloaded\n
            #    Log To Console    Drivers License back side is not downloaded
            #    ${back}    Set Variable    False
            # END
            ${handles}    Get Window Handles
            Switch window    ${handles}[2]
            Close Window
        ELSE
            Append To File    ${Log}    Drivers License back side is not found\n
            Log To Console    Drivers License back side is not found
            ${back}    Set Variable    False
        END
        ${handles}    Get Window Titles
        Switch window    ${handles}[1]
        Sleep    1s
        Log To Console    DL front
        ${Driving_Front}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //tr[td[normalize-space(text())='Drivers License (front)']]//a[text()='View']    10s
        IF    ${Driving_Front} == True
            Click Element If Visible
            ...    //tr[td[normalize-space(text())='Drivers License (front)']]//a[text()='View']
            Sleep    4s
            RPA.Desktop.Press Keys    CTRL    s
            Sleep    3s
            RPA.Desktop.Type Text    ${Epass_Path}\\DL_front
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
            # ${DL_front}    Run Keyword And Return Status
            # ...    File Should Exist
            # ...    ${Epass_Path}\\DL_front    10s
            # IF    ${DL_front} == True
            #    Append To File    ${Log}    Drivers License front side is downloaded\n
            #    Log To Console    Drivers License front side is downloaded
            #    ${front}    Set Variable    True
            # ELSE
            #    Append To File    ${Log}    Drivers License front side is not downloaded\n
            #    Log To Console    Drivers License front side is not downloaded
            #    ${front}    Set Variable    False
            # END
            ${handles}    Get Window Handles
            Switch window    ${handles}[2]
            Close Window
        ELSE
            Append To File    ${Log}    Drivers License front side is not found\n
            Log To Console    Drivers License front side is not found
            ${front}    Set Variable    False
        END
        # IF    ${front} == True and ${back} == True
        #    ${flag1}    Set Variable    True
        # ELSE
        #    ${flag1}    Set Variable    False
        # END
        ${handles}    Get Window Titles
        Switch window    ${handles}[1]
        Sleep    1s
        Log To Console    Headshot
        ${Picture}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //tr[td[normalize-space(text())='Head Shot Picture']]//a[text()='View']    10s
        IF    ${Picture} == True
            Click Element If Visible
            ...    //tr[td[normalize-space(text())='Head Shot Picture']]//a[text()='View']
            Sleep    4s
            RPA.Desktop.Press Keys    CTRL    s
            Sleep    3s
            RPA.Desktop.Type Text    ${Epass_Path}\\Headshot.jpeg
            Sleep    1s
            RPA.Desktop.Press Keys    Enter
            Sleep    1s
            TRY
                RPA.Desktop.Press Keys    Tab
                Sleep    1s
                RPA.Desktop.Press Keys    Enter
                Sleep    2s
            EXCEPT
                Log To Console    Headshot is Re-downloaded failed
            END
            ${Headshot}    Run Keyword And Return Status
            ...    File Should Exist
            ...    ${Epass_Path}\\Headshot.jpg    5s
            IF    ${Headshot} == True
                Append To File    ${Log}    Headshot is downloaded\n
                Log To Console    Headshot is downloaded
                ${flag5}    Set Variable    True
            ELSE
                Append To File    ${Log}    Headshot is not downloaded\n
                Log To Console    Headshot is not downloaded
                ${flag5}    Set Variable    False
            END
            ${handles}    Get Window Handles
            Switch window    ${handles}[2]
            Close Window
        ELSE
            Append To File    ${Log}    Headshot is not found\n
            Log To Console    Headshot is not found
            ${flag5}    Set Variable    False
        END

        ${handles}    Get Window Titles
        Switch window    ${handles}[1]
        Sleep    1s
        Log To Console    SSN
        ${SSN}    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //tr[td[normalize-space(text())='Social Security Account Number Card']]//a[text()='View']    10s
        IF    ${SSN} == True
            Click Element If Visible
            ...    //tr[td[normalize-space(text())='Social Security Account Number Card']]//a[text()='View']
            Sleep    10s
            RPA.Desktop.Press Keys    CTRL    s
            Sleep    3s
            RPA.Desktop.Type Text    ${Epass_Path}\\SSN
            Sleep    4s
            RPA.Desktop.Press Keys    Enter
            Sleep    3s
            TRY
                RPA.Desktop.Press Keys    Tab
                Sleep    1s
                RPA.Desktop.Press Keys    Enter
                Sleep    2s
            EXCEPT
                Log To Console    SSN is Re-downloaded failed
            END
            # ${Social}    Run Keyword And Return Status
            # ...    File Should Exist
            # ...    ${Epass_Path}\\SSN    5s
            # IF    ${Social} == True
            #    Append To File    ${Log}    SSN is downloaded\n
            #    Log To Console    SSN is downloaded
            #    ${flag3}    Set Variable    True
            # ELSE
            #    Append To File    ${Log}    SSN is not downloaded\n
            #    Log To Console    SSN is not downloaded
            #    ${flag3}    Set Variable    False
            # END
            ${handles}    Get Window Handles
            Switch window    ${handles}[2]
            Close Window
        ELSE
            Append To File    ${Log}    SSN is not found\n
            Log To Console    SSN is not found
            ${flag3}    Set Variable    False
        END
        ${handles}    Get Window Titles
        Switch window    ${handles}[1]
        Sleep    1s
        Log To Console    Crimshield
        IF    "${Alldatas}[tax_term]" == "1099"
            ${Crim}    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //tr[td[normalize-space(text())='C003C - Combined State Disclosures IC - Crimshield']]//a[text()='View']
            ...    10s
        ELSE
            ${Crim}    Run Keyword And Return Status
            ...    Wait Until Element Is Visible
            ...    //tr[td[normalize-space(text())='B003C - Combined State Disclosures - Crimshield']]//a[text()='View']
            ...    10s
        END
        IF    ${Crim} == True
            IF    "${Alldatas}[tax_term]" == "1099"
                Click Element If Visible
                ...    //tr[td[normalize-space(text())='C003C - Combined State Disclosures IC - Crimshield']]//a[text()='View']
            ELSE
                Click Element If Visible
                ...    //tr[td[normalize-space(text())='B003C - Combined State Disclosures - Crimshield']]//a[text()='View']
            END
            Sleep    6s
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
                Log To Console    Crimshield Authorization Form Re-downloaded failed
            END
            Log To Console    Crimshield Authorization Form downloaded
            ${Shield}    Run Keyword And Return Status
            ...    File Should Exist
            ...    ${Epass_Path}\\Crimshield.pdf
            IF    ${Shield} == True
                Append To File    ${Log}    Crimshield Authorization Form downloaded\n
                ${flag2}    Set Variable    True
            ELSE
                Append To File    ${Log}    Crimshield Authorization Form not downloaded\n
                ${flag2}    Set Variable    False
            END
            ${handles}    Get Window Handles
            Switch window    ${handles}[2]
            Close Window
        ELSE
            Append To File    ${Log}    Crimshield Authorization Form is not Found.\n
            Log To Console    Crimshield Authorization Form is not Found
            ${flag2}    Set Variable    False
        END
        ################################ PDF to IMAGE ################################
        TRY
            ${input_folder}    set Variable    ${Epass_Path}
            ${output_folder}    set Variable    ${Epass_Path}
            ${poppler_path}    set Variable
            ...    C:\\Users\\Administrator\\Downloads\\Release-24.08.0-0\\poppler-24.08.0\\Library\\bin
            ${files}    List Files In Directory    ${input_folder}
            FOR    ${file}    IN    @{files}
                ${full_path}    Join Path    ${input_folder}    ${file}
                ${is_pdf}    Evaluate    str(${file.lower().endswith(('ssn.pdf', 'dl_back.pdf', 'dl_front.pdf'))})
                IF    ${is_pdf}
                    Log To Console    ${is_pdf}
                    ${pdf_path}    Join Path    ${input_folder}    ${file}
                    convert_pdf_to_images    ${pdf_path}    ${output_folder}    ${poppler_path}
                    Log To Console    PDF to JPG converted.
                END
                ${is_jpeg}    Evaluate    str(${file.lower().endswith('.jpeg')})
                IF    ${is_jpeg}
                    Log To Console    ${is_jpeg}
                    ${image_path}    Join Path    ${input_folder}    ${file}
                    convert_jpeg_to_jpg    ${image_path}
                    Log To Console    JPEG to JPG converted.
                END
                ${is_png}    Evaluate    str(${file.lower().endswith('.png')})
                IF    ${is_png}
                    Log To Console    ${is_jpeg}
                    ${png_path}    Join Path    ${input_folder}    ${file}
                    convert_png_to_jpg    ${png_path}
                    Log To Console    PNG to JPG converted.
                END
            END
        EXCEPT
            Log To Console    Error occured while converting PDF to Image.
            Append To File    ${Log}    Error occured while converting PDF to Image.\n
        END
        ###############################################################################
        ${DL_back}    Run Keyword And Return Status
        ...    File Should Exist
        ...    ${Epass_Path}\\DL_back.jpg    5s
        IF    ${DL_back} == True
            Append To File    ${Log}    Drivers License back side is downloaded\n
            Log To Console    Drivers License back side is downloaded
            ${back}    Set Variable    True
        ELSE
            Append To File    ${Log}    Drivers License back side is not downloaded\n
            Log To Console    Drivers License back side is not downloaded
            ${back}    Set Variable    False
        END
        ${DL_front}    Run Keyword And Return Status
        ...    File Should Exist
        ...    ${Epass_Path}\\DL_front.jpg    10s
        IF    ${DL_front} == True
            Append To File    ${Log}    Drivers License front side is downloaded\n
            Log To Console    Drivers License front side is downloaded
            ${front}    Set Variable    True
        ELSE
            Append To File    ${Log}    Drivers License front side is not downloaded\n
            Log To Console    Drivers License front side is not downloaded
            ${front}    Set Variable    False
        END
        IF    ${front} == True and ${back} == True
            ${flag1}    Set Variable    True
        ELSE
            ${flag1}    Set Variable    False
        END
        ${Social}    Run Keyword And Return Status
        ...    File Should Exist
        ...    ${Epass_Path}\\SSN.jpg    5s
        IF    ${Social} == True
            Append To File    ${Log}    SSN is downloaded\n
            Log To Console    SSN is downloaded
            ${flag3}    Set Variable    True
        ELSE
            Append To File    ${Log}    SSN is not downloaded\n
            Log To Console    SSN is not downloaded
            ${flag3}    Set Variable    False
        END
    ELSE
        Append To File    ${Log}    D/B Check page is not Found.\n
        Log To Console    D/B Check page is not Found.
        ${flag1}    Set Variable    False
        ${flag2}    Set Variable    False
        ${flag3}    Set Variable    False
    END

    ${handles}    Get Window Titles
    Switch window    ${handles}[1]
    Sleep    2s
    Click Element If Visible    //*[@id="manage_modal"]/div/div/div[1]/button

    IF    ${flag1} == True and ${flag2} == True and ${flag3} == True
        ${Docflag}    Set Variable    True
        Append To File    ${Log}    All docs downloaded successfully from Fuse.\n
        Log To Console    All docs downloaded successfully from Fuse.
    ELSE
        Append To File    ${Log}    All docs are not downloaded from Fuse.\n
        Log To Console    All docs are not downloaded from Fuse.
        ${Docflag}    Set Variable    False
    END
    RETURN    ${Docflag}
