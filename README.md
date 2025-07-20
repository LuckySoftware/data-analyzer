# Sistema de Procesamiento de Datos (Parques Eólicos)

## Descripción
El sistema lee archivos de texto con un formato específico (delimitados por " | "), los procesa y los guarda en una base de datos PostgreSQL.

## Estructura del Proyecto
```
MAIN
├── data/
│   ├── raw data/      # Archivos originales para procesar
│   └── used data/     # Archivos ya procesados
├── scripts/
│   ├── extraer.py     # Script principal para procesamiento masivo
└── tools/
    ├── consulta_db.bat # Herramienta de consulta para Windows
    └── consulta_db.sh  # Herramienta de consulta para Unix/Linux
```

## Requisitos del Sistema
- Python 3.x
- PostgreSQL
- Bibliotecas Python:
  - datetime
  - csv
  - os
  - subprocess
  - shutil
  - glob

## Configuración de la Base de Datos
El sistema usa PostgreSQL con la siguiente estructura:
```sql
CREATE TABLE logs (
    nombre_parque VARCHAR(100),
    valor2 NUMERIC,
    valor3 INTEGER,
    fecha_hora TIMESTAMP,
    valor5 INTEGER,
    valor6 INTEGER
);
```

## Formato de Archivos de Entrada
Los archivos de entrada deben ser archivos .txt con el siguiente formato:
```
valor | valor2 | valor3 | valor4 | valor5 | valor6
```
Ejemplo:
```
Parque1 | 123.456 | 789 | 01/05/2025 00:07:00:000 | 42 | 13
```

## Acerca de los Scripts

### extraer.py
- Script main para procesamiento masivo de archivos
- Procesa todos los archivos .txt en la carpeta 'raw data'
- Mueve automáticamente los archivos procesados a 'used data'
- Maneja errores y registra el progreso

### extraerIndividual.py
- Script para procesamiento individual de archivos
- Procesa el archivos .txt en la carpeta 'raw data'
- Mueve automáticamente el archivos procesado a 'used data'
- Maneja errores y registra el progreso

## Uso

1. Colocá tus archivos .txt en la carpeta 'raw data'
2. Configurá las variables de la base de datos en el script que vas a usar
3. Ejecutá el script deseado:
   ```bash
   python scripts/extraer.py  # Para procesamiento masivo
   python scripts/extraerIndividual.py  # Para un archivo específico
   ```

## Manejo de Errores
- Verifica el formato correcto de los archivos
- Registra errores por línea
- Mantiene un seguimiento de archivos procesados
- No detiene el proceso por errores en líneas individuales

## Notas Importantes
- Asegurate de tener los permisos correctos en la base de datos 
(tener en cuenta que esta pensado para local y puede tener problemas)
- Los archivos procesados se mueven automáticamente a 'used data'
- Se agregan timestamps a los archivos duplicados en 'used data'
(para evitar duplicados y mantener un seguimiento de cambios con
un historial)
- El sistema maneja automáticamente la precisión de los valores numéricos, es decir que se cuenta con absolutamente todos los decimales que se ingresan
