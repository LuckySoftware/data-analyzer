import csv
import datetime
from io import StringIO
import os
import subprocess
import shutil

# Configuracion de archivo a procesar
ARCHIVO_TXT = '/Users/ilucky/Documents/Desarrollador/VENTUS/data/raw data/VarAna_2025_05_01_23_27.txt'

# Directorio para mover automaticamente los archivos procesados
USED_DATA_DIR = '/Users/ilucky/Documents/Desarrollador/VENTUS/data/used data'

# Configuracion de la DB
DB_NAME = 'postgres'
DB_USER = 'ilucky'
DB_PASSWORD = ''
DB_HOST = 'localhost'
DB_PORT = '5432'

# Crea el directorio en el caso de que used_data no exista
def asegurar_directorio_used():
    if not os.path.exists(USED_DATA_DIR):
        os.makedirs(USED_DATA_DIR)

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
    except Exception as e:
        print(f"Error moviendo archivo: {str(e)}")

# Procesa el archivo .txt y prepara los datos para la DB
def procesar_archivo():
    datos_csv = StringIO()
    writer = csv.writer(datos_csv, delimiter=',')
    
    try:
        with open(ARCHIVO_TXT, 'r') as f:
            for linea_num, linea in enumerate(f, 1):
                partes = [parte.strip() for parte in linea.split('|')]
                
                if len(partes) != 6:
                    print(f"Linea {linea_num} ignorada - Numero incorrecto de columnas: {linea}")
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
                    
                except Exception as e:
                    print(f"Error procesando la linea {linea_num}: {str(e)}")
                    continue
        
        return datos_csv.getvalue()
    
    except FileNotFoundError:
        print(f"Error: Archivo {ARCHIVO_TXT} no encontrado")
        return None

# Importa los datos procesados a la DB
def importar_a_postgresql(datos_csv):
    if datos_csv is None:
        return False
    
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
        
        subprocess.run(comando, shell=True, check=True)
        print("Datos importados - OK")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"Error al importar datos: {str(e)}")
        return False
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)

if __name__ == "__main__":
    asegurar_directorio_used()
    
    print("Procesando archivo")
    datos_csv = procesar_archivo()
    
    if datos_csv:
        print("Importando a DB")
        exito = importar_a_postgresql(datos_csv)
        
        if exito:
            print("Moviendo archivo procesado")
            mover_archivo_procesado(ARCHIVO_TXT)
        else:
            print("No se mueve el archivo debido a errores en la importacion")
    
    print("Proceso completado - OK")