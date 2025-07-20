import csv
import datetime
from io import StringIO
import os
import subprocess
import shutil

# Ruta archivo
ARCHIVO_TXT = '/Users/ilucky/Documents/Desarrollador/VENTUS/data/raw data/VarAna_2025_05_01_00_07.txt'
USED_DATA_DIR = '/Users/ilucky/Documents/Desarrollador/VENTUS/data/used data'

# Config de la DB
DB_NAME = 'postgres'
DB_USER = 'ilucky'
DB_PASSWORD = ''
DB_HOST = 'localhost'
DB_PORT = '5432'


# Crea el directorio used_data si no existe
def directorio_usedata():
    if not os.path.exists(USED_DATA_DIR):
        os.makedirs(USED_DATA_DIR)
        
# Procesa el archivo TXT conservando todos los valores exactos
def procesar_archivo():
    datos_csv = StringIO()
    writer = csv.writer(datos_csv, delimiter=',')
    
    with open(ARCHIVO_TXT, 'r') as f:
        for linea_num, linea in enumerate(f, 1):
            # Dividir la las columnas usando el " | " como delimitador
            partes = [parte.strip() for parte in linea.split('|')]
            
            if len(partes) != 6:
                print(f"Línea {linea_num} ignorada - Número incorrecto de columnas: {linea}")
                continue
            
            try:
                nombre_parque = partes[0]
                
                # Convertir valores manteniendo precision
                valor2 = float(partes[1])  # NUMERIC(15,6)
                valor3 = int(partes[2])    # INTEGER
                
                # Convertir fecha con milisegundos
                fecha_original = partes[3]
                dt = datetime.datetime.strptime(fecha_original, '%d/%m/%Y %H:%M:%S:%f')
                fecha_pg = dt.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]  # Ajuste de milisegundos
                
                valor5 = int(partes[4])    # INTEGER
                valor6 = int(partes[5])    # INTEGER
                
                # Escribir fila en CSV
                writer.writerow([
                    nombre_parque,  # nombre_parque VARCHAR(100)
                    valor2,         # valor2 NUMERIC(15,6)
                    valor3,         # valor3 INTEGER
                    fecha_pg,       # fecha_hora TIMESTAMP
                    valor5,         # valor5 INTEGER
                    valor6          # valor6 INTEGER
                ])
                
            except ValueError as e:
                print(f"Error de conversión en línea {linea_num}: {linea}\nError: {str(e)}")
                continue
            except Exception as e:
                print(f"Error inesperado en línea {linea_num}: {linea}\nError: {str(e)}")
                continue
    
    return datos_csv.getvalue()



# Importa los datos a PostgreSQL usando el nombre de columna correcto
def importar_a_postgresql(datos_csv):
    
    temp_file = 'temp_import.csv'
    try:
        with open(temp_file, 'w') as f:
            f.write(datos_csv)
        
        comando = f"""
        PGPASSWORD={DB_PASSWORD} psql -h {DB_HOST} -p {DB_PORT} -U {DB_USER} -d {DB_NAME} -c "
        COPY logs(nombre_parque, valor2, valor3, fecha_hora, valor5, valor6) 
        FROM STDIN WITH (FORMAT csv, DELIMITER ',');
        " < {temp_file}
        """
        
        result = subprocess.run(comando, shell=True, check=True, text=True)
        print("¡Importación completada con éxito!")
        
    except subprocess.CalledProcessError as e:
        print(f"Error durante el proceso de importacion: {str(e)}")
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)

if __name__ == "__main__":
    print("Procesando archivo")
    datos_csv = procesar_archivo()
    
    print("Importando a PostgresSQL")
    importar_a_postgresql(datos_csv)
    
    print("Los datos se mudaron correctamente")