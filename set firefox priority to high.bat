@echo off

:: ---------- USER SETTINGS -----------------

:: New priority for the requested process. The following table shows all valid values and their IDs:
:: Priority Level ID 	Priority Level Name
:: 256 	                Realtime
:: 128 	                High
:: 32768 	            Above normal
:: 32 	                Normal
:: 16384 	            Below normal
:: 64 	                Low
:: NOTE: Using priority "Realtime" will dedicate ALL available resources to a process.
::       If the process requires more than 100% of CPU, your computer will freeze. 
::       It is HIGHLY 
SET newPriority=128

:: Process whose priority will be periodically set to the defined value. All currently
:: running processes and their names can be found in "Task Manager" -> "Details".
SET process="firefox.exe"

:: How many minutes should the script wait before running the priority change again.
:: Windows seems to revert the priority of the process to its default value after a while.
SET updatePeriod=5

:: ------------------------------------------


:: Perform some hextech magic to enable line overwriting
setlocal enableextensions enabledelayedexpansion
for /f %%a in ('copy /Z "%~dpf0" nul') do set "ASCII_13=%%a"

:: The main loop. It runs infinitely until the console window is closed.
:MAIN_LOOP
	:: Perform the priority update. Once the function is executed, the script returns here.
	CALL :SET_PROCESS_PRIORITY
	
	:: Wait before performing another priority update. The priority must be updated regularly,
    :: otherwise Windows reverts the priority of the process to its default value.
	ECHO.
	ECHO To exit the script, press CTRL+C or close the command prompt.
	
	SET nextUpdate=%updatePeriod%
	:: Call the wait function. Once again, the function returns here once it's done executing.
	CALL :WAIT_BEFORE_NEXT_UPDATE
	
	:: Return back to the start of the main loop.
    GOTO :MAIN_LOOP

:: The core of this script. Performs the main feature of changing the priority of the requested process.
:SET_PROCESS_PRIORITY
	ECHO Updating priority of %process% to %newPriority%
	
	:: Perform some hextech magic with WMIC and suppress all standard and error outputs by dumping them into nul (where it is thrown away)
	WMIC process where name=%process% CALL setpriority %newPriority% >nul 2>nul
	
	:: Check if the priority update raised any errors and print a message
	IF ERRORLEVEL 0 (ECHO Update successful) ELSE (ECHO Update failed)
EXIT /B 0

:: Wait for the set number of minutes.
:WAIT_BEFORE_NEXT_UPDATE
	:WAIT_LOOP
		:: Perform some hextech magic to print text without a new line. The most important character is !ASCII_13!,
		:: which returns the console cursor back to the start of the line. This allows the next print statement
		:: to overwrite whatever text was present in the line before. Useful for countdowns and percentage loading screens.
		SET /p dummyName=" Next priority update in %nextUpdate% minutes     !ASCII_13!" <nul
		
		:: Wait 60 seconds, don't interrupt the timeout on user input and don't print your default output.
		TIMEOUT 60 /nobreak >nul
		
		:: Exit the countdown only if this loop ran enough times. 1 loop = 1 minute of waiting.
		SET /a nextUpdate=%nextUpdate%-1
		IF %nextUpdate% GTR 0 GOTO :WAIT_LOOP
EXIT /B 0