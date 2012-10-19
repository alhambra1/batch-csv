@echo off
mode con lines=40 cols=110

:START
@echo                          ******************************
@echo                          * Rename ^& Move Unzipped CSV *
@echo                          ******************************
@echo.
@echo  Rename Unzipped assumes there is only ONE csv file inside each folder in a directory.
@echo  The program creates a new directory alongside the original one, opens each folder in 
@echo  the directory, renames the csv file by it's parent folder name, keeping the file's 
@echo  original extension, and moves the file to the new directory. Please make sure there 
@echo  is only one file per folder and that the working directory is clear of any folders 
@echo  and files you do not wish to change. A process log is saved in the new folder. 
@echo.
@echo                                       ***
@echo.
@echo     PLEASE MAKE SURE THERE ARE NO FILES WITH THE SAME NAME AS THE ORIGINAL FOLDER IN
@echo                      THE DIRECTORY THE ORIGINAL FOLDER IS IN!
@echo.
@echo                                       ***
@echo.

:GETINPUT
@echo.
@echo                               ASSIGN FOLDER PATH
@echo.
@echo  Please enter the complete drive and folder path, for example,
@echo.
@echo      C:\Documents and Settings\Username\Desktop\Folder
@echo.
@echo  If you are running this program from inside the folder's directory,
@echo  you may just press ENTER.
@echo.

set /p original_folder_path=     FOLDER PATH: 
if "%original_folder_path%"=="" set original_folder_path=%~dp0
if not exist "%original_folder_path%" set "original_folder_path=" & echo. & echo       %original_folder_path% does not seem to be a valid directory. & echo. & pause & goto GETINPUT

:CONFIRM
@echo.
@echo.
@echo  Original path is set to: %original_folder_path% 
@echo.
set /p repeatCaseInsensitive= Are you sure you want to continue [Y/y/N/n, E/e to exit]?:
@echo.
@echo.
if "%repeatCaseInsensitive%"=="" (GOTO CONFIRM)
if /I "%repeatCaseInsensitive%"=="y" (GOTO EXECUTE)
if /I "%repeatCaseInsensitive%"=="n" (GOTO GETINPUT) 
if /I "%repeatCaseInsensitive%"=="e" (GOTO EXIT) else (GOTO CONFIRM)

:EXECUTE
cd "%original_folder_path%" 
for %%* in (.) do set original_folder_name=%%~n*
cd..
set new_folder_path=%cd%\Renamed_Files_From_%original_folder_name%
set process_log_path=%new_folder_path%\process_log.txt

mkdir "Renamed_Files_From_%original_folder_name%"
@echo creating new folder "Renamed_Files_From_%original_folder_name%" alongside original folder...
@echo creating new folder "Renamed_Files_From_%original_folder_name%" alongside original folder... >> "%process_log_path%"

cd "%original_folder_path%"
@echo.
@echo. >> "%process_log_path%"

@echo listing folders...
@echo listing folders... >> "%process_log_path%"
dir /b /AD
dir /b /AD >> "%process_log_path%"
@echo.
@echo. >> "%process_log_path%"

for /f "delims=" %%i in ('dir /b /AD') do (

  @echo switching to directory "%%i"...
  @echo switching to directory "%%i"... >> "%process_log_path%"
  cd "%%i"

  for %%d in (.) do echo directory path is %%~Sd
  @echo directory listing:
  @echo directory listing: >> "%process_log_path%"
  dir /b *.csv >> "%process_log_path%"
  dir /b *.csv
  @echo.
  @echo. >> "%process_log_path%"

  REM rename file
  for /f "delims=" %%a in ('dir /b *.csv') do (
    @echo renaming "%%a" to "%%i.csv" ...
    @echo renaming "%%a" to "%%i.csv" ... >> "%process_log_path%"
    ren "%%a" "%%i.csv" 2>> "%process_log_path%"
    @echo moving "%%i" to "%new_folder_path%" ...
    @echo moving "%%i" to "%new_folder_path%" ... >> "%process_log_path%"
    move "%%i.csv" "%new_folder_path%" 2>> "%process_log_path%"
  )

  @echo.
  @echo. >> "%process_log_path%" 
  cd "%original_folder_path%"
)

@echo.
@echo. >> "%process_log_path%"
@echo Completed.
@echo Completed. >> "%process_log_path%"
@echo.
@echo. >> "%process_log_path%"

:REPEAT
set /p repeatCaseInsensitive=   Repeat Process [Y/y/N/n, E/e to exit]?:
if "%repeatCaseInsensitive%"=="" (GOTO REPEAT)
if /I "%repeatCaseInsensitive%"=="y" (GOTO GETINPUT)
if /I "%repeatCaseInsensitive%"=="n" (GOTO EXIT) 
if /I "%repeatCaseInsensitive%"=="e" (GOTO EXIT) else (GOTO REPEAT)
 
:EXIT
exit