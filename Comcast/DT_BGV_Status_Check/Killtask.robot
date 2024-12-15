*** Settings ***
Library    RPA.Robocorp.Process
Library  Process

*** Keywords ***
Kill Chrome Processes
    [Documentation]    Kills residual Chrome driver and browser processes on Windows
    Run Process    cmd.exe    /c    taskkill /IM chrome.exe /F
    Run Process    cmd.exe    /c    taskkill /IM chromedriver.exe /F