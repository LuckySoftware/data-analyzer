@echo off
REM este script solo contempla PostgreSQL
:menu
cls
echo ****************************************
echo *      CONSULTAS A BASE DE DATOS       *
echo ****************************************
echo.
echo 1. Consultar por fecha exacta
echo 2. Consultar por nombre de parque
echo 3. Consultar por rango de fechas
echo 4. Exportar datos a CSV
echo 5. Salir
echo.
set /p opcion=Seleccione una opcion: 

if "%opcion%"=="1" goto fecha_exacta
if "%opcion%"=="2" goto nombre_parque
if "%opcion%"=="3" goto rango_fechas
if "%opcion%"=="4" goto exportar_csv
if "%opcion%"=="5" exit

echo Opcion no valida
pause
goto menu

:fecha_exacta
set /p fecha=Ingrese fecha (YYYY-MM-DD HH:MI:SS.MS): 
psql -h localhost -p 5432 -U ilucky -d postgres -c "SELECT * FROM logs WHERE fecha_hora = '%fecha%'"
pause
goto menu

:nombre_parque
set /p nombre=Ingrese nombre de parque: 
psql -h localhost -p 5432 -U ilucky -d postgres -c "SELECT * FROM logs WHERE nombre_parque LIKE '%%%nombre%%%' LIMIT 100"
pause
goto menu

:rango_fechas
set /p fecha_inicio=Ingrese fecha inicio (YYYY-MM-DD): 
set /p fecha_fin=Ingrese fecha fin (YYYY-MM-DD): 
psql -h localhost -p 5432 -U ilucky -d postgres -c "SELECT fecha_hora, nombre_parque, valor2 FROM logs WHERE fecha_hora::date BETWEEN '%fecha_inicio%'::date AND '%fecha_fin%'::date ORDER BY fecha_hora"
pause
goto menu

:exportar_csv
set /p archivo=Ingrese nombre del archivo CSV (sin extension): 
psql -h localhost -p 5432 -U ilucky -d postgres -c "\COPY (SELECT * FROM logs LIMIT 1000) TO '%archivo%.csv' WITH CSV HEADER"
echo Datos exportados a %archivo%.csv
pause
goto menu