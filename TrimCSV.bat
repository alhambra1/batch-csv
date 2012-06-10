@echo off
mode con lines=40 cols=96

REM SET PATH CONFIGURATIONS
REM SET PATH CONFIGURATIONS
set GNUWIN_PATH=C:\Program Files\GnuWin32\Bin
set TRIMCSV_PATH=C:\Documents and Settings\User\Desktop\CSV-Utilities
set EXCEL_COL_TO_AWK_SYNTAX_PATH=C:\Documents and Settings\User\Desktop\CSV-Utilities\Awk files\ExcelColToAwkSyntax.awk

REM CHECK FOR CORRECT CONFIGURATION
if not exist "%GNUWIN_PATH%" set gnu_not=true
if not exist "%TRIMCSV_PATH%" set trim_csv_not=true
if not exist "%EXCEL_COL_TO_AWK_SYNTAX_PATH%" set excel_col_to_awk_syntax_not=true

if /I "%gnu_not%"=="true" (
  @echo. & @echo Cannot find the GnuWin32 folder, please configure the correct path.
)
if /I "%trim_csv_not%"=="true" (
  @echo. & @echo Cannot find the CSV-Utilities folder, please configure the correct path.
  set ext=true
)
if /I "%excel_col_to_awk_syntax_not%"=="true" (
  @echo. & @echo Cannot find the file, "ExcelColToAwkSyntax.awk," please configure the correct path.
  set ext=true
)
if "%ext%"=="true" ( 
  @echo. & echo Press any key to exit...
  set /p ext=
  exit
)

:START
@echo                                        ************
@echo                                        * Trim CSV *
@echo                                        ************
@echo.
@echo  Trim CSV relies on the GnuWin package Gawk to extract selected columns from all CSV files in
@echo  a folder, and save the trimmed files in a folder called "Trimmed" inside the original folder. 
@echo  Trim CSV also relies on the included file, "ExcelColToAwkSyntax.awk," to automatically convert
@echo  any excel columns to awk field syntax. 

:GETINPUT
@echo.
@echo.
@echo                         EXTRACTION DETAILS
@echo.
@echo  (1) Please enter the complete drive and folder path, for example,
@echo.
@echo        C:\Documents and Settings\Username\Desktop\Folder
@echo.
@echo      If you are running this program from inside the folder's directory,
@echo      you may just press ENTER.
@echo.

set /p folderpath=     FOLDER PATH: 

if "%folderpath%"=="" (set folderpath=%~dp0)
if not exist "%folderpath%" ( set "folderpath=" & echo. & echo       %folderpath% does not seem to be a valid directory. & echo. & pause & goto GETINPUT )

:GETCOLUMNS
@echo.
@echo  (2) Please enter the columns to extract. You may enter a range by using a dash.
@echo      TrimCSV accepts either numbers or Excel columns, case insensitive. 
@echo      For example: 1,2,5-8,a,c,A-AB
@echo.

set /p columns=     COLUMNS TO EXTRACT: 

REM convert any Excel columns to numbers
cd "%GNUWIN_PATH%"
@echo DELIMITER%columns%DELIMITER > "%TRIMCSV_PATH%\TrimCSV_tmp_file"
awk -f "%EXCEL_COL_TO_AWK_SYNTAX_PATH%" "%TRIMCSV_PATH%\TrimCSV_tmp_file" > "%TRIMCSV_PATH%\TrimCSV_columns"
del "%TRIMCSV_PATH%\TrimCSV_tmp_file"

setLocal EnableDelayedExpansion
cd "%TRIMCSV_PATH%"
for /f "tokens=* delims= " %%a in (TrimCSV_columns) do (
  if !columns_converted!'==' set columns_converted=%%a
)
if "%columns_converted:~0,6%"=="Please" (
  del "%TRIMCSV_PATH%\TrimCSV_columns" & echo. & echo       %columns_converted% & echo. & pause & goto GETCOLUMNS
) else del "%TRIMCSV_PATH%\TrimCSV_columns"
@echo.

:HEADINGS
set answer=false
set /p headings=     Include headings (first row) [Y/y N/n]?
if /I "%headings%"=="y" (set answer=true)
if /I "%headings%"=="n" (set answer=true)
if "%answer%"=="false" (GOTO HEADINGS)

@echo.
@echo  (3) Trim CSV can optionally copy only those rows that include specific text.
@echo      Please enter any conditional text. If none, leave blank and press ENTER.
@echo.

set /p conditional_text=     CONDITIONAL TEXT: 

:REVIEW
@echo.
@echo.
@echo.
@echo                      *** REVIEW ^& CONFIRM ***
@echo.
@echo.
@echo        FILEPATH:          %folderpath%
@echo.
@echo        COLUMNS:           %columns%
@echo.
@echo        INCLUDE HEADINGS:  %headings%
@echo.
@echo        CONDITIONAL TEXT:  %conditional_text%
@echo.
@echo.

:CONFIRM
set /p repeatCaseInsensitive=     CONTINUE WITH EXTRACTION [Y/y/N/n, E/e to exit]?:
if "%repeatCaseInsensitive%"=="" (GOTO CONFIRM)
if /I "%repeatCaseInsensitive%"=="e" (GOTO EXIT)
if /I "%repeatCaseInsensitive%"=="y" (GOTO EXECUTE)
if /I "%repeatCaseInsensitive%"=="n" (GOTO GETINPUT) else (GOTO CONFIRM)

:EXECUTE
cd "%folderpath%"

set trimmed_dir="%folderpath%\Trimmed"
md %trimmed_dir%

for /f "delims=" %%i in ('dir /b *.csv') do (

  @echo.
  @echo.
  @echo  Now trimming %%~nxi ...

  cd "%GNUWIN_PATH%"

  if /I "%headings%"=="y" (
    awk "BEGIN {FS=\",\"; OFS=\",\"} NR==1 {print %columns_converted%; next} /%conditional_text%/{print %columns_converted%}" "%%~dpnxi" > "%folderpath%\trimmed\%%~ni_trimmed.csv"
  ) else (
    awk "BEGIN {FS=\",\"; OFS=\",\"} /%conditional_text%/{print %columns_converted%}" "%%~dpnxi" > "%folderpath%\trimmed\%%~ni_trimmed.csv"
  )
  @echo  Done.

  cd "%folderpath%"
)

@echo.
@echo.
@echo                         *** COMPLETED ***
@echo.
@echo   Trimming has completed. Trimmed files are available in the folder "Trimmed"
@echo   located in the original folder.
@echo.

:REPEAT
set /p repeatCaseInsensitive=   Repeat Process [Y/y/N/n, E/e to exit]?:
if "%repeatCaseInsensitive%"=="" (GOTO REPEAT)
if /I "%repeatCaseInsensitive%"=="y" (GOTO GETINPUT)
if /I "%repeatCaseInsensitive%"=="n" (GOTO EXIT) 
if /I "%repeatCaseInsensitive%"=="e" (GOTO EXIT) else (GOTO REPEAT)
 
:EXIT
exit