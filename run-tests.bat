@echo off
:loop
echo ==================================================
echo Stopping containers...
echo ==================================================
docker compose down -v
echo ==================================================
echo Building and starting containers...
echo ==================================================
docker compose up --build -d
:wait_loop
echo Waiting for service...
curl -s -I http://localhost:8080 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    timeout /t 1 /nobreak >nul
    goto wait_loop
)
echo ==================================================
echo Service is ready!
echo ==================================================
cd test
echo ==================================================
echo Building tests...
echo ==================================================
call npm install
if %ERRORLEVEL% neq 0 (
    echo ==================================================
    echo TEST BUILD FAILED!
    echo ==================================================
    cd ..
    pause
    goto loop
)
echo ==================================================
echo Running tests...
echo ==================================================
call npm test
set TEST_STATUS=%ERRORLEVEL%
cd ..
if %TEST_STATUS% equ 0 (
    echo ==================================================
    echo ALL TESTS PASS!
    echo ==================================================
) else (
    echo ==================================================
    echo SOME TESTS FAILED...
    echo ==================================================
)
echo Press any key to run again...
pause >nul
goto loop