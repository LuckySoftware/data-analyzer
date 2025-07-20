@echo off
setlocal enabledelayedexpansion

:: Configuración de la base de datos
set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=postgres
set DB_USER=ilucky
set PGPASSWORD=tu_contraseña

:main_menu
cls
echo *******************************************
echo *          SISTEMA DE CONSULTAS.          *
echo *******************************************
echo.
echo 1. Consultar datos con filtros
echo 2. Exportar resultados a CSV
echo 3. Salir
echo.
set /p main_option=Seleccione una opción [1-3]: 

if "%main_option%"=="1" goto filter_menu
if "%main_option%"=="2" goto export_csv
if "%main_option%"=="3" exit /b
echo Opción no válida
pause
goto main_menu

:filter_menu
cls
echo *******************************************
echo *  SELECCIONE EL TIPO DE FILTRO           *
echo *******************************************
echo.
echo 1. Filtrar por fecha exacta
echo 2. Filtrar por rango de fechas
echo 3. Filtrar por nombre de parque
echo 4. Filtrar por fecha exacta Y nombre
echo 5. Filtrar por rango de fechas Y nombre
echo 6. Volver al menú principal
echo.
set /p filter_option=Seleccione una opción [1-6]: 

if "%filter_option%"=="1" goto exact_date
if "%filter_option%"=="2" goto date_range
if "%filter_option%"=="3" goto park_name
if "%filter_option%"=="4" goto exact_date_and_name
if "%filter_option%"=="5" goto date_range_and_name
if "%filter_option%"=="6" goto main_menu
echo Opción no válida
pause
goto filter_menu

:exact_date
set /p fecha=Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): 
set where_clause=fecha_hora = '!fecha!'
goto execute_query

:date_range
set /p fecha_inicio=Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): 
set /p fecha_fin=Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): 
set where_clause=fecha_hora BETWEEN '!fecha_inicio!' AND '!fecha_fin!'
goto execute_query

:park_name
set /p nombre=Ingrese nombre de parque: 
set where_clause=nombre_parque LIKE '%%!nombre!%%'
goto execute_query

:exact_date_and_name
set /p fecha=Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): 
set /p nombre=Ingrese nombre de parque: 
set where_clause=fecha_hora = '!fecha!' AND nombre_parque LIKE '%%!nombre!%%'
goto execute_query

:date_range_and_name
set /p fecha_inicio=Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): 
set /p fecha_fin=Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): 
set /p nombre=Ingrese nombre de parque: 
set where_clause=fecha_hora BETWEEN '!fecha_inicio!' AND '!fecha_fin!' AND nombre_parque LIKE '%%!nombre!%%'
goto execute_query

:execute_query
echo.
echo Ejecutando consulta:
echo SELECT nombre_parque, valor2, valor3, fecha_hora, valor5, valor6 FROM logs WHERE !where_clause! ORDER BY fecha_hora DESC LIMIT 1000;
echo.
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT nombre_parque, valor2, valor3, fecha_hora, valor5, valor6 FROM logs WHERE !where_clause! ORDER BY fecha_hora DESC LIMIT 1000;"
pause
goto filter_menu

:export_csv
cls
echo Seleccione tipo de filtro para exportación:
echo 1. Fecha exacta
echo 2. Rango de fechas
echo 3. Nombre de parque
echo 4. Combinar con nombre de parque
echo.
set /p export_option=Opción: 

if "%export_option%"=="1" goto export_exact_date
if "%export_option%"=="2" goto export_date_range
if "%export_option%"=="3" goto export_park_name
if "%export_option%"=="4" goto export_combined
echo Opción no válida
pause
goto export_csv

:export_exact_date
set /p fecha=Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): 
set where_clause=fecha_hora = '!fecha!'
goto perform_export

:export_date_range
set /p fecha_inicio=Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): 
set /p fecha_fin=Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): 
set where_clause=fecha_hora BETWEEN '!fecha_inicio!' AND '!fecha_fin!'
goto perform_export

:export_park_name
set /p nombre=Ingrese nombre de parque (contemplar variantes): 
set where_clause=nombre_parque LIKE '%%!nombre!%%'
goto perform_export

:export_combined
cls
echo 1. Combinar con fecha exacta
echo 2. Combinar con rango de fechas
echo.
set /p sub_option=Opción: 

if "%sub_option%"=="1" (
    set /p fecha=Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): 
    set /p nombre=Ingrese nombre de parque (contemplar variantes): 
    set where_clause=fecha_hora = '!fecha!' AND nombre_parque LIKE '%%!nombre!%%'
) else if "%sub_option%"=="2" (
    set /p fecha_inicio=Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): 
    set /p fecha_fin=Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): 
    set /p nombre=Ingrese nombre de parque (contemplar variantes): 
    set where_clause=fecha_hora BETWEEN '!fecha_inicio!' AND '!fecha_fin!' AND nombre_parque LIKE '%%!nombre!%%'
) else (
    echo Opción no válida
    pause
    goto export_combined
)
goto perform_export

:perform_export
set /p csvfile=Ingrese el nombre con el que desea crear el archivo CSV (sin extensión): 

if "!where_clause!"=="" (
    psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "\COPY (SELECT nombre_parque, valor2, valor3, fecha_hora, valor5, valor6 FROM logs ORDER BY fecha_hora DESC LIMIT 10000) TO '!csvfile!.csv' WITH CSV HEADER"
) else (
    psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "\COPY (SELECT nombre_parque, valor2, valor3, fecha_hora, valor5, valor6 FROM logs WHERE !where_clause! ORDER BY fecha_hora DESC) TO '!csvfile!.csv' WITH CSV HEADER"
)

echo.
echo Datos exportados a !csvfile!.csv
pause
goto main_menu