@echo off
REM Change directory to where Robot Framework script is located
cd /d "C:\Users\Administrator\OneDrive - ITG Communications, LLC\onboarding_data\Hire_Right\Hire_Right"

REM Check if changing directory was successful
if %ERRORLEVEL% neq 0 (
    echo Failed to change directory
    pause
    exit /b %ERRORLEVEL%
)


REM Execute Robot Framework with the correct Python executable
C:\Users\Administrator\AppData\Local\Programs\Python\Python311\python.exe "C:\Users\Administrator\OneDrive - ITG Communications, LLC\onboarding_data\Hire_Right\Hire_Right\HireRight_Main.py"

REM Check if Robot Framework execution was successful
if %ERRORLEVEL% neq 0 (
    echo Robot Framework execution failed
    pause
    exit /b %ERRORLEVEL%
)

REM If everything executed successfully
echo execution completed

REM Close Command Prompt window automatically
exit /b 0
