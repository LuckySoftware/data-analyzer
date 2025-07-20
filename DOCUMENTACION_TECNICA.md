# Documentación Técnica de VENTUS 📚

## Arquitectura del Sistema 🏗️

VENTUS está diseñado con una arquitectura modular que separa claramente las responsabilidades de cada componente del sistema. A continuación, se detalla cada aspecto técnico del sistema.

## Componentes Principales 🔧

### 1. Sistema de Procesamiento de Archivos

#### Módulo de Extracción (`extraer.py`)
```python
class CaracterísticasPrincipales:
    - Procesamiento masivo de archivos
    - Manejo de errores robusto
    - Sistema de logging integrado
    - Gestión automática de archivos procesados
```

#### Flujo de Datos
1. **Lectura de Archivo**
   - Formato de entrada: Texto delimitado por pipes (`|`)
   - Validación de estructura por línea
   - Parseo de tipos de datos

2. **Transformación de Datos**
   - Conversión de tipos:
     * Strings → VARCHAR(100)
     * Números decimales → NUMERIC(15,6)
     * Enteros → INTEGER
     * Fechas → TIMESTAMP

3. **Carga en Base de Datos**
   - Uso de COPY para carga eficiente
   - Manejo de transacciones
   - Validación de integridad

### 2. Estructura de la Base de Datos

#### Tabla Principal: `logs`

| Columna | Tipo | Descripción |
|---------|------|-------------|
| nombre_parque | VARCHAR(100) | Identificador del parque eólico |
| valor2 | NUMERIC | Medición de precisión alta |
| valor3 | INTEGER | Valor entero de medición |
| fecha_hora | TIMESTAMP | Momento exacto de la medición |
| valor5 | INTEGER | Valor entero adicional |
| valor6 | INTEGER | Valor entero adicional |

### 3. Sistema de Archivos

#### Estructura de Directorios
- **raw data/**: Directorio de ingreso de datos
  * Archivos pendientes de procesamiento
  * Formato de nombre: `VarAna_YYYY_MM_DD_HH_mm.txt`

- **used data/**: Directorio de archivos procesados
  * Sistema de versionado por timestamp
  * Preservación de datos originales

## Manejo de Errores y Excepciones

### 1. Validación de Datos
```python
Tipos de Validaciones:
- Estructura de línea (6 campos)
- Tipos de datos correctos
- Formato de fecha válido
- Valores numéricos en rango
```

### 2. Gestión de Excepciones
- **FileNotFoundError**: Archivo no encontrado
- **ValueError**: Error en conversión de tipos
- **subprocess.CalledProcessError**: Error en carga a DB
- **IOError**: Error en operaciones de archivo

## Optimizaciones y Mejores Prácticas

### 1. Rendimiento
- Uso de `StringIO` para manejo eficiente de memoria
- Procesamiento por lotes en DB
- Limpieza automática de archivos temporales

### 2. Seguridad
- Validación de tipos de datos
- Sanitización de entradas

### 3. Mantenibilidad
- Código modular y comentado
- Constantes configurables
- Logs detallados de operaciones

## Configuración del Entorno

### 1. Variables de Entorno
```python
Configuración DB:
DB_NAME = 'postgres'
DB_USER = 'usuario'
DB_PASSWORD = 'contraseña'
DB_HOST = 'localhost'
DB_PORT = '5432'
```

### 2. Dependencias del Sistema
- Sistema Operativo: Compatible con Windows/Unix
- Python 3.x (desarrollado con: 3.10.1)
- PostgreSQL 12+ (desarrollado con: 14.19 HomeBrew)
- Permisos de escritura en directorios

## Procedimientos de Mantenimiento

### 1. Respaldo de Datos
- Conservación de archivos originales
- Sistema de versionado por timestamp
- Logs de operaciones

### 2. Monitoreo
- Registro de errores por archivo
- Estadísticas de procesamiento
- Control de archivos duplicados

## Guía de Troubleshooting

### Problemas Comunes y Soluciones

1. **Error de Conexión DB**
   - Verificar credenciales
   - Comprobar servicio PostgreSQL
   - Revisar permisos de usuario

2. **Errores de Formato**
   - Validar estructura del archivo
   - Verificar delimitadores
   - Comprobar codificación

3. **Errores de Procesamiento**
   - Revisar logs de error
   - Verificar permisos de escritura
   - Comprobar espacio en disco

## Recomendaciones de Uso

1. **Procesamiento de Archivos**
   - Procesar en horarios de baja carga
   - Monitorear uso de recursos
   - Mantener respaldos actualizados

2. **Mantenimiento**
   - Limpieza periódica de archivos procesados
   - Actualización de índices DB
   - Revisión de logs de error

## Glosario de Términos

- **Raw Data**: Datos sin procesar
- **Used Data**: Datos ya procesados
- **Timestamp**: Marca temporal única
- **Batch Processing**: Procesamiento por lotes