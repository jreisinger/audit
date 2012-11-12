:: Turn off command printing
::@echo off

:: MAIN
set mail_server=
set mail_address=

call :init_out_file
call :create_files
:: Third number defines number of iterations
for /l %%X in (1,1,3) do (call :run_tests)
call :clean_up
call :mail_results
goto :eof

:: Initialize output file
:init_out_file
echo|set /p=date > out
date /T >> out
echo|set /p=host >> out
echo %COMPUTERNAME% >> out
echo|set /p=user >> out
echo %USERNAME% >> out
goto :eof

:: Create dummy files
:create_files
mkdir files
chdir files
echo "This is just a sample line appended  to create a big file. " > dummy.txt
:: 100MB
::for /L %%i in (1,1,21) do type dummy.txt >> dummy.txt
for /L %%i in (1,1,12) do type dummy.txt >> dummy.txt
copy dummy.txt dummy1.txt
chdir ..
goto :eof

:: Do simple performance tests
:run_tests
echo start copy %time% >> out
copy "files\*"
echo stop copy %time% >> out
echo start compress %time% >> out
"C:\Program Files\WinRAR\rar.exe" a files.rar files
echo stop compress %time% >> out
goto :eof

:: Cleanup
:clean_up
echo start cleanup %time% >> out
del "*.txt"
del files.rar
del /Q files\*
rmdir files
echo stop cleanup %time% >> out
goto :eof

:: Mail the results
:mail_results
blat.exe out -server %mail_server% -f %username% -to %mail_address%
goto :eof
