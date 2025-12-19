# Sistema de Base de Datos - Cadena de Restaurantes

![Database Design](https://img.shields.io/badge/Database-SQL%20Server-CC2927?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

## Descripción del Proyecto

Este proyecto implementa una **base de datos relacional completa** para la gestión de una cadena de restaurantes. Proporciona una solución integral que permite administrar sucursales, empleados, clientes, órdenes, platos, productos, proveedores y sus correspondientes relaciones.

La base de datos fue diseñada siguiendo los estándares de normalización (1FN, 2FN, 3FN). Incluye procedimientos almacenados, funciones escalares y tabulares, triggers de validación y vistas reportes.


## Características Principales

### Módulos Implementados
```
- **Gestión de Sucursales**: Control de múltiples ubicaciones con datos de contacto
- **Administración de Empleados**: Clasificación por roles (camarero, cocinero, administrativo)
- **Gestión de Clientes**: Programa de fidelización y registro de transacciones
- **Catálogo de Platos**: Menú con clasificación por tipo y precios
- **Inventario de Productos**: Seguimiento de ingredientes y productos para el negocio
- **Red de Proveedores**: Gestión de suministros y entregas
- **Sistema de Órdenes**: Registro completo de transacciones y pagos
- **Reportes Avanzados**: Vistas consolidadas para análisis de datos
```


### Objetos de Base de Datos

```
Entidades Fuertes:          7
Entidades Débiles:          3
Relaciones N-M:             6
Atributos Multivaluados:    3
Procedimientos Almacenados: 3
Funciones:                  3
Triggers:                   3
Vistas:                     2
```


##  Modelo de Datos

### Estructura del Diagrama Entidad-Relación

El modelo relacional consta de **22 tablas** organizadas en tres capas:

#### Capa 1: Entidades Fuertes (Tablas Principales)
- `Sucursal` - Localidades operativas
- `Empleado` - Base de datos de personal
- `Cliente` - Registro de clientes
- `Orden` - Transacciones de compra
- `Plato` - Catálogo de productos culinarios
- `Producto` - Ingredientes y productos
- `Proveedor` - Proveedores de suministros

#### Capa 2: Entidades Débiles (Especializaciones)
- `Camarero` - Personal de servicio al cliente
- `Cocinero` - Personal de cocina
- `Administrativo` - Personal administrativo

#### Capa 3: Tablas de Relación (N-M)
- `Incluye` - Platos en órdenes
- `Contiene` - Ingredientes en platos
- `Ofrece` - Platos disponibles por sucursal
- `Suministra_producto` - Entregas de proveedores
- `Trabajan_en` - Asignación de empleados a sucursales
- `Maneja` - Administración de sucursales

#### Capa 4: Atributos Multivaluados
- `Telefono_Sucursal` - Teléfonos de contacto
- `Telefono_Empleado` - Teléfonos de empleados
- `Telefono_Proveedor` - Teléfonos de proveedores


### Requisitos Previos
```
- SQL Server 2019 o superior
- SQL Server Management Studio (SSMS) 18.0+
- Permisos de administrador en la base de datos
```

## Restaurar .Bak en SQL server

### Click derecho en la carpeta Database
[![Opciones en Carpeta Database](https://i.postimg.cc/hPYmsnbD/image.png)](https://postimg.cc/JGbt792v)

### Click en la opción Restore Database 
[![Pestaña Restore Database](https://i.postimg.cc/d173LkpL/image-1.png)](https://postimg.cc/LYp2WXHp)

### En el apartado de source, click en device y en el cuadro de la derecha con los tres puntos (...)
[![Pestaña Select Backup device](https://i.postimg.cc/QCyFfg7f/image-2.png)](https://postimg.cc/ctf1HnX3)

### Click en la opción Add y busca el archivo .bak en la carpeta donde lo hayas descargado
[![Explorador de archivos](https://i.postimg.cc/jSsjykBj/image-3.png)](https://postimg.cc/3dc7T98M)

### Una vez encontrado, solo tendras que aceptar todo
[![Restauración de la base de datos](https://i.postimg.cc/J7Z7vLLw/image-4.png)](https://postimg.cc/hh4qQNvM)
[![Restauración exitosa](https://i.postimg.cc/q76HKsB7/image-5.png)](https://postimg.cc/942k5q73)


## Integridad

### Restricciones Implementadas
```
- Claves primarias en todas las tablas
- Claves foráneas con integridad referencial
- Restricciones CHECK para validación de datos
- Restricciones UNIQUE para datos únicos
- Cascada de eliminación en relaciones N-M
```


## Estructura del Repositorio
```
Proyecto-Base-Datos-Restaurante/
├── README.md                              
├── SQL/
│   ├── Query_Base_De_Datos.sql           
│   └── Respaldo_Base_De_Datos.bak               
├── Diagrama_Relacional.jpg
├── Diagrama_Base_de_Datos.jpg
```
