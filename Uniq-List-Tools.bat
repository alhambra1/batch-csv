@echo off
mode con lines=40 cols=96

REM SET PATH CONFIGURATIONS
set GNUWIN_PATH=C:\Program Files\GnuWin32\Bin
set UNIQ_LIST_TOOLS_PATH=C:\Documents and Settings\User\Desktop\CSV-Utilities
set UNIQ_LIST_SUMS_PATH=C:\Documents and Settings\User\Desktop\CSV-Utilities\Awk files\uniq-list-sums.awk
set UNIQ_LIST_SUMS_BATCH_PATH=C:\Documents and Settings\User\Desktop\CSV-Utilities\Awk files\uniq-list-sums-batch.awk

REM CHECK FOR CORRECT CONFIGURATION
if not exist "%GNUWIN_PATH%" set gnu_not=true
if not exist "%UNIQ_LIST_TOOLS_PATH%" set uniq_list_tools_not=true
if not exist "%UNIQ_LIST_SUMS_PATH%" set uniq_list_sums_not=true
if not exist "%UNIQ_LIST_SUMS_BATCH_PATH%" set uniq_list_sums_batch_not=true

if /I "%gnu_not%"=="true" (
  @echo. & @echo Cannot find the GnuWin32 folder, please configure the correct path.
)
if /I "%uniq_list_tools_not%"=="true" (
  @echo. & @echo Cannot find the CSV-Utilities folder, please configure the correct path.
  set ext=true
)
if /I "%uniq_list_sums_not%"=="true" (
  @echo. & @echo Cannot find the file, "uniq-list-sums.awk," please configure the correct path.
  set ext=true
)
if /I "%uniq_list_sums_batch_not%"=="true" (
  @echo. & @echo Cannot find the file, "uniq-list-sums-batch.awk," please configure the correct path.
  set ext=true
)
if "%ext%"=="true" ( 
  @echo. & echo Press any key to exit...
  pause > nul
  exit
) 

@echo.
@echo  *************************
@echo  *** UNIQUE-LIST TOOLS ***
@echo  *************************
@echo.
@echo.
@echo  * Place and run me in the directory of the files you^'d like to work with.
@echo.
@echo  * I generate a list of unique values from column_a (or search relying on a specific list).
@echo.
@echo  * I generate a sum of rows from column_b for each unique value, where the rows chosen
@echo    for each sum contain the unique value on column_a.
@echo.
@echo  * Choose the two columns based on their headings.
@echo.

:GET_FILENAME
@echo.
@echo.
@echo  *** CHOOSE FILE
@echo.
@echo  Please choose a file from the list. Type the file^'s name (excluding the extension)
@echo  or enter "all files":
@echo.
@echo.

dir /b *.csv

@echo.
@echo.
set /p FILENAME=  FILE NAME: 
if not exist "%FILENAME%.csv" ( 
 if not "%FILENAME%"=="all files" set "FILENAME=" & echo. & echo       System cannot find the file %FILENAME%.csv in the current directory. & echo. & pause & goto GET_FILENAME )
)
set FILEPATH=%~dp0%FILENAME%.csv

@echo.
set /p COLUMN_A_HEADING=  COLUMN HEADING FOR UNIQUE LIST VALUES (case sensitive): 
@echo.
set /p COLUMN_B_HEADING=  COLUMN HEADING FOR VALUES TO SUM (case sensitive): 
@echo.
@echo   OPTIONAL SEARCH TEXT FOR UNIQUE LIST COLUMN (case sensitive; separate multiple terms
@echo   by a comma, leaving no unintended spaces; leave blank if none; escape special characters 
set /p REGEX=  according to DOS rules): 
@echo.
@echo.

pause

:EXECUTE
@echo.
@echo.

cd "%GNUWIN_PATH%"
if /I "%FILENAME%"=="all files" (
  goto ALL_FILES_LOOP 
) else (
  @echo  Now generating unique-value list and sum for %FILENAME%
  @echo  Headings: [%COLUMN_A_HEADING%] and [%COLUMN_B_HEADING%]
  @echo.
  mawk -v FILENAME_FOR_AWK="%FILENAME%.csv" -v COLUMN_A_HEADING="%COLUMN_A_HEADING%" -v COLUMN_B_HEADING="%COLUMN_B_HEADING%" -v REGEX="%REGEX%" -f "%UNIQ_LIST_SUMS_PATH%" "%FILEPATH%" > "%~dp0\uniq-tool-output.csv"
  cd "%~dp0"
  goto COMPLETED
)


:ALL_FILES_LOOP
cd "%~dp0"

for /f "delims=" %%i in ('dir /b *.csv') do (
  cd "%GNUWIN_PATH%"
  @echo  Now generating unique-value list and sum for %%~nxi
  @echo  Headings: [%COLUMN_A_HEADING%] and [%COLUMN_B_HEADING%]
  mawk -v FILENAME_FOR_AWK="%%~nxi" -v COLUMN_A_HEADING="%COLUMN_A_HEADING%" -v COLUMN_B_HEADING="%COLUMN_B_HEADING%" -v REGEX="%REGEX%" -f "%UNIQ_LIST_SUMS_PATH%" "%%~dpnxi" >> "%~dp0\uniq-tool-sums-tmp.csv"
  @echo  Done.
  @echo.
  cd "%~dp0"

  @echo DELIMITER >> "%~dp0\uniq-tool-sums-tmp.csv"
)

cd "%GNUWIN_PATH%"
mawk -f "%UNIQ_LIST_SUMS_BATCH_PATH%" "%~dp0\uniq-tool-sums-tmp.csv" > "%~dp0\uniq-tool-output.csv"
cd "%~dp0"
del "%~dp0\uniq-tool-sums-tmp.csv"

:COMPLETED
@echo.
@echo  *** COMPLETED
@echo.
@echo  Analysis saved to the file, "uniq-list-tools-output.csv"
@echo   in the directory, "%~dp0"
@echo.
@echo.

@echo Press any key to exit... & pause > nul
exit