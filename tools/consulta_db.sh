#!/bin/bash

# Configuración de la base de datos
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="postgres"
DB_USER="ilucky"
export PGPASSWORD="tu_contraseña"

# Función para mostrar el menú principal
show_main_menu() {
    clear
    echo "*******************************************"
    echo "*          SISTEMA DE CONSULTAS.          *"
    echo "*******************************************"
    echo ""
    echo "1. Consultar datos con filtros"
    echo "2. Exportar resultados a CSV"
    echo "3. Salir"
    echo ""
    read -p "Seleccione una opción [1-3]: " main_option
}

# Función para mostrar el menú de filtros
show_filter_menu() {
    clear
    echo "*******************************************"
    echo "*  SELECCIONE EL TIPO DE FILTRO           *"
    echo "*******************************************"
    echo ""
    echo "1. Filtrar por fecha exacta"
    echo "2. Filtrar por rango de fechas"
    echo "3. Filtrar por nombre de parque"
    echo "4. Filtrar por fecha exacta Y nombre"
    echo "5. Filtrar por rango de fechas Y nombre"
    echo "6. Volver al menú principal"
    echo ""
    read -p "Seleccione una opción [1-6]: " filter_option
}

# Función para construir y ejecutar consultas
execute_query() {
    local where_clause=""
    local query=""
    
    # Construir condición WHERE basada en los parámetros
    if [ "$#" -gt 0 ]; then
        where_clause="WHERE $1"
        
        if [ "$#" -eq 2 ]; then
            where_clause="$where_clause AND $2"
        fi
    fi
    
    # Construir consulta completa manteniendo los valores solicitados
    query="SELECT nombre_parque, valor2, valor3, fecha_hora, valor5, valor6 FROM logs $where_clause ORDER BY fecha_hora DESC LIMIT 1000;"
    
    echo -e "\nEjecutando consulta:\n$query\n"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$query"
}

# Función para exportar a CSV
export_to_csv() {
    local where_clause=""
    local query=""
    
    echo "Seleccione tipo de filtro para exportación:"
    echo "1. Fecha exacta"
    echo "2. Rango de fechas"
    echo "3. Nombre de parque"
    echo "4. Combinar con nombre de parque"
    read -p "Opción: " export_option
    
    case $export_option in
        1)
            read -p "Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): " fecha
            where_clause="fecha_hora = '$fecha'"
            ;;
        2)
            read -p "Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): " fecha_inicio
            read -p "Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): " fecha_fin
            where_clause="fecha_hora BETWEEN '$fecha_inicio' AND '$fecha_fin'"
            ;;
        3)
            read -p "Ingrese nombre de parque (contemplar variantes): " nombre
            where_clause="nombre_parque LIKE '%$nombre%'"
            ;;
        4)
            echo "1. Combinar con fecha exacta"
            echo "2. Combinar con rango de fechas"
            read -p "Opción: " sub_option
            
            if [ "$sub_option" -eq 1 ]; then
                read -p "Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): " fecha
                read -p "Ingrese nombre de parque (contemplar variantes): " nombre
                where_clause="fecha_hora = '$fecha' AND nombre_parque LIKE '%$nombre%'"
            else
                read -p "Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): " fecha_inicio
                read -p "Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): " fecha_fin
                read -p "Ingrese nombre de parque (contemplar variantes): " nombre
                where_clause="fecha_hora BETWEEN '$fecha_inicio' AND '$fecha_fin' AND nombre_parque LIKE '%$nombre%'"
            fi
            ;;
        *)
            echo "Opción no válida, exportando todos los datos"
            ;;
    esac
    
    read -p "Ingrese el nombre con el que desea crear el archivo CSV (sin extensión): " csvfile
    
    # Construir consulta de exportación
    if [ -z "$where_clause" ]; then
        query="\COPY (SELECT nombre_parque, valor2, valor3, fecha_hora, valor5, valor6 FROM logs ORDER BY fecha_hora DESC LIMIT 10000) TO '${csvfile}.csv' WITH CSV HEADER"
    else
        query="\COPY (SELECT nombre_parque, valor2, valor3, fecha_hora, valor5, valor6 FROM logs WHERE $where_clause ORDER BY fecha_hora DESC) TO '${csvfile}.csv' WITH CSV HEADER"
    fi
    
    # Ejecutar exportación
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$query"
    echo -e "\nDatos exportados a ${csvfile}.csv"
}

# Menú principal
while true; do
    show_main_menu
    
    case $main_option in
        1)  # Consultar con filtros
            while true; do
                show_filter_menu
                
                case $filter_option in
                    1)  # Fecha exacta
                        read -p "Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): " fecha
                        execute_query "fecha_hora = '$fecha'"
                        ;;
                    2)  # Rango de fechas
                        read -p "Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): " fecha_inicio
                        read -p "Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): " fecha_fin
                        execute_query "fecha_hora BETWEEN '$fecha_inicio' AND '$fecha_fin'"
                        ;;
                    3)  # Solo nombre
                        read -p "Ingrese nombre de parque: " nombre
                        execute_query "nombre_parque LIKE '%$nombre%'"
                        ;;
                    4)  # Fecha exacta + nombre
                        read -p "Ingrese fecha exacta (YYYY-MM-DD HH:MI:SS.MS): " fecha
                        read -p "Ingrese nombre de parque: " nombre
                        execute_query "fecha_hora = '$fecha'" "nombre_parque LIKE '%$nombre%'"
                        ;;
                    5)  # Rango de fechas + nombre
                        read -p "Ingrese fecha inicial (YYYY-MM-DD HH:MI:SS.MS): " fecha_inicio
                        read -p "Ingrese fecha final (YYYY-MM-DD HH:MI:SS.MS): " fecha_fin
                        read -p "Ingrese nombre de parque: " nombre
                        execute_query "fecha_hora BETWEEN '$fecha_inicio' AND '$fecha_fin'" "nombre_parque LIKE '%$nombre%'"
                        ;;
                    6)  # Volver
                        break
                        ;;
                    *)
                        echo "Opción no válida"
                        ;;
                esac
                read -p "Presione [Enter] para continuar..."
            done
            ;;
        2)  # Exportar a CSV
            export_to_csv
            read -p "Presione [Enter] para continuar..."
            ;;
        3)  # Salir
            echo "Saliendo del sistema..."
            exit 0
            ;;
        *)
            echo "Opción no válida"
            read -p "Presione [Enter] para continuar..."
            ;;
    esac
done