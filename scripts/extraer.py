import csv
import datetime
from io import StringIO
import os
import subprocess
import shutil
import glob

# Configuracion directorio a procesar - RAW DATA
INPUT_DIR = '/Users/ilucky/Documents/Desarrollador/VENTUS/data/raw data'

# Carpeta para archivos ya procesados - PROCESSED DATA
USED_DATA_DIR = '/Users/ilucky/Documents/Desarrollador/VENTUS/data/used data'

# Target para saber que tipos de archivos procesar
FILE_PATTERN = '*.txt'

# Configuracion de la DB
DB_NAME = 'postgres'
DB_USER = 'ilucky'
DB_PASSWORD = ''
DB_HOST = 'localhost'
DB_PORT = '5432'

# Crea los directorios necesarios en caso de no existir
def asegurar_directorios():
    os.makedirs(INPUT_DIR, exist_ok=True)
    os.makedirs(USED_DATA_DIR, exist_ok=True)

# Obtiene lista de archivos a procesar
def obtener_archivos_a_procesar():
    return glob.glob(os.path.join(INPUT_DIR, FILE_PATTERN))

# Mueve el archivo ya procesado a la carpeta de used_data
def mover_archivo_procesado(archivo_original):
    try:
        nombre_archivo = os.path.basename(archivo_original)
        archivo_destino = os.path.join(USED_DATA_DIR, nombre_archivo)
        
        # Si el archivo ya existe en destino, añade timestamp
        if os.path.exists(archivo_destino):
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            nombre, ext = os.path.splitext(nombre_archivo)
            archivo_destino = os.path.join(USED_DATA_DIR, f"{nombre}_{timestamp}{ext}")
        
        shutil.move(archivo_original, archivo_destino)
        print(f"Archivo movido a: {archivo_destino}")
        return True
    except Exception as e:
        print(f"Error moviendo archivo {archivo_original}: {str(e)}")
        return False

# Procesa un archivo .txt y prepara los datos para ser mandados al a DB
def procesar_archivo(archivo_txt):
    datos_csv = StringIO()
    writer = csv.writer(datos_csv, delimiter=',')
    total_lineas = 0
    lineas_procesadas = 0
    
    try:
        with open(archivo_txt, 'r') as f:
            for linea_num, linea in enumerate(f, 1):
                total_lineas += 1
                partes = [parte.strip() for parte in linea.split('|')]
                
                if len(partes) != 6:
                    print(f"{archivo_txt} - Linea {linea_num} ignorada: Numero incorrecto de columnas")
                    continue
                
                try:
                    nombre_parque = partes[0]
                    valor2 = float(partes[1])
                    valor3 = int(partes[2])
                    
                    dt = datetime.datetime.strptime(partes[3], '%d/%m/%Y %H:%M:%S:%f')
                    fecha_pg = dt.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]
                    
                    valor5 = int(partes[4])
                    valor6 = int(partes[5])
                    
                    writer.writerow([nombre_parque, valor2, valor3, fecha_pg, valor5, valor6])
                    lineas_procesadas += 1
                    
                except Exception as e:
                    print(f"{archivo_txt} - Error linea {linea_num}: {str(e)}")
                    continue
        
        print(f"{archivo_txt} - Procesado: {lineas_procesadas}/{total_lineas} lineas validas")
        return datos_csv.getvalue() if lineas_procesadas > 0 else None
    
    except Exception as e:
        print(f"Error procesando {archivo_txt}: {str(e)}")
        return None

# Importa los datos ya procesados para la DB
def importar_a_postgresql(datos_csv, archivo_origen):
    if datos_csv is None:
        return False
    
    temp_file = f"temp_import_{os.path.basename(archivo_origen)}.csv"
    try:
        with open(temp_file, 'w') as f:
            f.write(datos_csv)
        
        comando = f"""
        PGPASSWORD={DB_PASSWORD} psql -h {DB_HOST} -p {DB_PORT} -U {DB_USER} -d {DB_NAME} -c "
        COPY logs(nombre_parque, valor2, valor3, fecha_hora, valor5, valor6) 
        FROM STDIN WITH (FORMAT csv, DELIMITER ',');
        " < {temp_file}
        """
        
        subprocess.run(comando, shell=True, check=True)
        print(f"{archivo_origen} - Datos importados")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"{archivo_origen} - Error al importar datos: {str(e)}")
        return False
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)

# Procesa todos los archivos del directorio
def procesar_todos_los_archivos():
    asegurar_directorios()
    archivos = obtener_archivos_a_procesar()
    
    if not archivos:
        print(f"No se encontraron archivos {FILE_PATTERN} en {INPUT_DIR}")
        return
    
    print(f"Procesando {len(archivos)} archivos")
    
    for archivo in archivos:
        print(f"\nProcesando: {archivo}")
        datos_csv = procesar_archivo(archivo)
        
        if datos_csv:
            exito = importar_a_postgresql(datos_csv, archivo)
            
            if exito:
                if not mover_archivo_procesado(archivo):
                    print(f"{archivo} - No se pudo mover a {USED_DATA_DIR}")
            else:
                print(f"{archivo} - No se mueve por error de importacion")
        else:
            print(f"{archivo} - No contiene datos validos para importar")
    
    print("\nProceso completado")

if __name__ == "__main__":
    procesar_todos_los_archivos()