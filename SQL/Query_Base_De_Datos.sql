/*	
BASE DE DATOS RELACIONAL PARA UNA CADENA DE RESTAURANTE
*/
-- Crear base de datos
CREATE DATABASE Restaurante;

-- PASO 1: Crear tablas de entidades fuertes
CREATE TABLE Sucursal (
    id_sucursal INT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    email VARCHAR(100),
	CONSTRAINT PK_sucursal_id_sucursal PRIMARY KEY (id_sucursal),
	CONSTRAINT CK_sucursal_email CHECK (email LIKE '%@%')
);

CREATE TABLE Empleado (
    cedula VARCHAR(13),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(200),
    email VARCHAR(100),
	CONSTRAINT PK_empleado_cedula PRIMARY KEY (cedula),
	CONSTRAINT CK_empleado_cedula CHECK (cedula LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT CK_empleado_email CHECK (email LIKE '%@%')
);

CREATE TABLE Cliente (
    cedula VARCHAR(13),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    fecha_nacimiento DATE,
	CONSTRAINT PK_cliente_cedula PRIMARY KEY (cedula),
	CONSTRAINT CK_cliente_cedula CHECK (cedula LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT CK_cliente_fecha_nacimiento CHECK (fecha_nacimiento < getdate())
);

CREATE TABLE Orden (
    num_orden INT,
    fecha DATE NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    forma_pago VARCHAR(50) NOT NULL,
	CONSTRAINT PK_orden_num_orden PRIMARY KEY (num_orden),
	CONSTRAINT CK_orden_fecha CHECK (fecha <= getdate()),
	CONSTRAINT CK_orden_monto_total CHECK (monto_total > 0),
	CONSTRAINT CK_orden_forma_pago CHECK (forma_pago IN ('Efectivo', 'Tarjeta'))
);

CREATE TABLE Plato (
    codigo_plato INT,
    tipo VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(255),
	CONSTRAINT PK_plato_codigo_plato PRIMARY KEY (codigo_plato),
	CONSTRAINT CK_plato_tipo CHECK (tipo IN ('Entrada', 'Principal', 'Postre')),	
	CONSTRAINT CK_plato_precio CHECK (precio > 0)
);

CREATE TABLE Producto (
    codigo_producto INT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(255),
    tipo_producto VARCHAR(15),
	CONSTRAINT PK_producto_codigo_producto PRIMARY KEY (codigo_producto),
	CONSTRAINT CK_producto_precio CHECK (precio > 0),	
	CONSTRAINT CK_producto_tipo_producto CHECK (tipo_producto IN ('Producto', 'Ingrediente'))
);

CREATE TABLE Proveedor (
    codigo_proveedor INT,
    nombre VARCHAR(100) NOT NULL,
    persona_contacto VARCHAR(100),
    direccion VARCHAR(200),
    email VARCHAR(100),
	CONSTRAINT PK_proveedor_codigo_proveedor PRIMARY KEY (codigo_proveedor),
	CONSTRAINT CK_proveedor_email CHECK (email LIKE '%@%')
);

-- PASO 2: Crear tablas de entidades débiles 
CREATE TABLE Camarero (
    cedula VARCHAR(13),
    años_experiencia INT NOT NULL,
    habilidades VARCHAR(200),
	CONSTRAINT PK_camarero_cedula PRIMARY KEY (cedula),
	CONSTRAINT CK_camarero_años_experiencia CHECK (años_experiencia > 0),
	CONSTRAINT FK_camarero_cedula FOREIGN KEY (cedula) REFERENCES Empleado(cedula) ON DELETE CASCADE
);

CREATE TABLE Cocinero (
    cedula VARCHAR(13),
    tipo VARCHAR(50) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
	CONSTRAINT PK_cocinero_cedula PRIMARY KEY (cedula),
	CONSTRAINT FK_cocinero_cedula FOREIGN KEY (cedula) REFERENCES Empleado(cedula) ON DELETE CASCADE,
	CONSTRAINT CK_cocinero_tipo CHECK (tipo IN ('Jefe de cocina', 'Subchef', 'cocinero'))
);

CREATE TABLE Administrativo (
    cedula VARCHAR(13) PRIMARY KEY,
    cargo VARCHAR(50) NOT NULL,
    antiguedad INT NOT NULL,
	CONSTRAINT CK_administrativo_antiguedad CHECK (antiguedad >= 0),
	CONSTRAINT FK_administrativo_cedula FOREIGN KEY (cedula) REFERENCES Empleado(cedula) ON DELETE CASCADE,
	CONSTRAINT CK_administrativo_cargo CHECK (cargo IN ('Gerente', 'administrador', 'contador' ))
);

-- PASO 3: Modificar tablas con relaciones 1-N
ALTER TABLE Orden
	ADD  id_sucursal INT, cedula_cliente VARCHAR(13), cedula_camarero VARCHAR(13),
	CONSTRAINT FK_orden_id_sucursal FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
	CONSTRAINT FK_orden_cedula_cliente FOREIGN KEY (cedula_cliente) REFERENCES Cliente(cedula),
	CONSTRAINT FK_orden_cedula_camarero FOREIGN KEY (cedula_camarero) REFERENCES Camarero(cedula);

ALTER TABLE Plato
	ADD  cedula_cocinero VARCHAR(13),
	CONSTRAINT FK_plato_cedula_cocinero FOREIGN KEY (cedula_cocinero) REFERENCES Cocinero(cedula);

-- PASO 4: Crear tablas para relaciones N-M
CREATE TABLE Incluye (
    num_orden INT,
    codigo_plato INT,
    cantidad INT NOT NULL,
	CONSTRAINT PK_incluye_num_orden_codigo_plato PRIMARY KEY (num_orden, codigo_plato),
	CONSTRAINT FK_incluye_num_orden FOREIGN KEY (num_orden) REFERENCES Orden(num_orden),
	CONSTRAINT FK_incluye_codigo_plato FOREIGN KEY (codigo_plato) REFERENCES Plato(codigo_plato),
	CONSTRAINT CK_incluye_cantidad CHECK (cantidad > 0),
);

CREATE TABLE Contiene (
    codigo_plato INT,
    codigo_producto INT,
    cantidad INT NOT NULL,
    CONSTRAINT PK_contiene_codigo_plato_producto PRIMARY KEY (codigo_plato, codigo_producto),
	CONSTRAINT FK_contiene_codigo_plato FOREIGN KEY (codigo_plato) REFERENCES Plato(codigo_plato),
	CONSTRAINT FK_contiene_codigo_producto FOREIGN KEY (codigo_producto) REFERENCES Producto(codigo_producto),
	CONSTRAINT CK_contiene_cantidad CHECK (cantidad > 0),
);

CREATE TABLE Ofrece (
    id_sucursal INT,
    codigo_plato INT,
    CONSTRAINT PK_ofrece_id_sucursal_codigo_plato PRIMARY KEY (id_sucursal, codigo_plato),
	CONSTRAINT FK_ofrece_id_sucursal FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
	CONSTRAINT FK_ofrece_codigo_plato FOREIGN KEY (codigo_plato) REFERENCES Plato(codigo_plato)
);

CREATE TABLE Suministra_producto (
    codigo_proveedor INT,
    codigo_producto INT,
    fecha DATE,
    cantidad INT NOT NULL,
    CONSTRAINT PK_suministra_producto_codigo_proveedor_producto PRIMARY KEY (codigo_proveedor, codigo_producto, fecha),
	CONSTRAINT FK_suministra_codigo_proveedor FOREIGN KEY (codigo_proveedor) REFERENCES Proveedor(codigo_proveedor),
	CONSTRAINT FK_suministra_codigo_producto FOREIGN KEY (codigo_producto) REFERENCES Producto(codigo_producto),
	CONSTRAINT CK_suministra_producto_cantidad CHECK (cantidad > 0),
	CONSTRAINT CK_suministra_producto_fecha CHECK (fecha <= getdate()),
);

CREATE TABLE Trabajan_en (
    cedula_empleado VARCHAR(13),
    id_sucursal INT,
    CONSTRAINT PK_trabajan_en_cedula_empleado_id_sucursal PRIMARY KEY (cedula_empleado, id_sucursal),
	CONSTRAINT FK_trabajan_en_cedula_empleado FOREIGN KEY (cedula_empleado) REFERENCES Empleado(cedula),
	CONSTRAINT FK_trabajan_en_id_sucursal FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

CREATE TABLE Maneja (
    cedula_administrativo VARCHAR(13),
    id_sucursal INT,
    CONSTRAINT PK_maneja_cedula_admin_id_sucursal PRIMARY KEY (cedula_administrativo, id_sucursal),
	CONSTRAINT FK_maneja_cedula_administrativo FOREIGN KEY (cedula_administrativo) REFERENCES Administrativo(cedula),
	CONSTRAINT FK_maneja_id_sucursal FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

-- PASO 5: Crear tablas para atributos multivaluados
CREATE TABLE Telefono_Sucursal (
    id_sucursal INT,
    telefono VARCHAR(20),
    CONSTRAINT PK_telefono_sucursal_id_sucursal_telefono PRIMARY KEY (id_sucursal, telefono),
	CONSTRAINT FK_telefono_sucursal_id_sucursal FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

CREATE TABLE Telefono_Empleado (
    cedula VARCHAR(13),
    telefono VARCHAR(20),
    CONSTRAINT PK_telefono_empleado_cedula_telefono PRIMARY KEY (cedula, telefono),
	CONSTRAINT FK_telefono_empleado_cedula FOREIGN KEY (cedula) REFERENCES Empleado(cedula)
);

CREATE TABLE Telefono_Proveedor (
    codigo_proveedor INT,
    telefono VARCHAR(20),
    CONSTRAINT PK_telefono_proveedor_codigo_proveedor_telefono PRIMARY KEY (codigo_proveedor, telefono),
	CONSTRAINT FK_telefono_proveedor_codigo_proveedor FOREIGN KEY (codigo_proveedor) REFERENCES Proveedor(codigo_proveedor)
);

-- Carga de datos
INSERT INTO Sucursal (id_sucursal, nombre, direccion, email) VALUES 
(1, 'Sucursal Bella Vista', 'Av. Central 123, Ciudad de Panamá', 'bella@restaurante.com'),
(2, 'Sucursal Albrook', 'Calle Mall, Albrook', 'albrook@restaurante.com'),
(3, 'Sucursal Metromall', 'Via Tocumen 455', 'metromall@restaurante.com'),
(4, 'Sucursal San Miguelito', 'Av. Domingo Díaz', 'sanmi@restaurante.com'),
(5, 'Sucursal Costa del Este', 'Blvd. Costa Este 22', 'costa@restaurante.com');

-- Insertar datos en Empleado
INSERT INTO Empleado (cedula, nombre, apellido, direccion, email) VALUES
('12-3456-78901', 'Carlos', 'Martínez', 'Calle 1, Ciudad', 'carlos@email.com'),
('23-4567-89012', 'Ana', 'Rodríguez', 'Calle 2, Ciudad', 'ana@email.com'),
('34-5678-90123', 'Luis', 'García', 'Calle 3, Ciudad', 'luis@email.com'),
('45-6789-01234', 'Marta', 'López', 'Calle 4, Ciudad', 'marta@email.com'),
('56-7890-12345', 'Jorge', 'Hernández', 'Calle 5, Ciudad', 'jorge@email.com'),
('67-8901-23456', 'Sofía', 'Pérez', 'Calle 6, Ciudad', 'sofia@email.com'),
('78-9012-34567', 'Pedro', 'Sánchez', 'Calle 7, Ciudad', 'pedro@email.com'),
('89-0123-45678', 'Lucía', 'Ramírez', 'Calle 8, Ciudad', 'lucia@email.com'),
('90-1234-56789', 'Diego', 'Flores', 'Calle 9, Ciudad', 'diego@email.com'),
('01-2345-67890', 'Elena', 'Torres', 'Calle 10, Ciudad', 'elena@email.com'),
('11-2233-44556', 'Roberto', 'Jiménez', 'Calle 11, Ciudad', 'roberto@email.com'),
('22-3344-55667', 'Carmen', 'Vargas', 'Calle 12, Ciudad', 'carmen@email.com'),
('33-4455-66778', 'Andrés', 'Castro', 'Calle 13, Ciudad', 'andres@email.com'),
('44-5566-77889', 'Patricia', 'Rojas', 'Calle 14, Ciudad', 'patricia@email.com'),
('55-6677-88990', 'Fernando', 'Mendoza', 'Calle 15, Ciudad', 'fernando@email.com');

-- Insertar datos en Camarero
INSERT INTO Camarero (cedula, años_experiencia, habilidades) VALUES
('12-3456-78901', 3, 'Atención rápida, conocimiento de vinos'),
('23-4567-89012', 5, 'Trato con clientes exigentes'),
('34-5678-90123', 2, 'Servicio en barra'),
('45-6789-01234', 4, 'Coordinación de mesas'),
('56-7890-12345', 1, 'Servicio básico');

-- Insertar datos en Cocinero
INSERT INTO Cocinero (cedula, tipo, especialidad) VALUES
('67-8901-23456', 'Jefe de cocina', 'Cocina fusión'),
('78-9012-34567', 'Subchef', 'Carnes'),
('89-0123-45678', 'cocinero', 'Pastas'),
('90-1234-56789', 'cocinero', 'Postres'),
('01-2345-67890', 'cocinero', 'Ensaladas');

-- Insertar datos en Administrativo
INSERT INTO Administrativo (cedula, cargo, antiguedad) VALUES
('11-2233-44556', 'Gerente', 5),
('22-3344-55667', 'administrador', 3),
('33-4455-66778', 'contador', 4),
('44-5566-77889', 'administrador', 2),
('55-6677-88990', 'contador', 1);

-- Insertar datos en Cliente
INSERT INTO Cliente (cedula, nombre, apellido, direccion, telefono, fecha_nacimiento) VALUES
('99-8888-77777', 'María', 'González', 'Av. A, Ciudad', '111-2222', '1990-05-15'),
('88-7777-66666', 'Juan', 'Díaz', 'Av. B, Ciudad', '333-4444', '1985-11-30'),
('77-6666-55555', 'Laura', 'Morales', 'Av. C, Ciudad', '555-6666', '1995-02-20'),
('66-5555-44444', 'Ricardo', 'Silva', 'Av. D, Ciudad', '777-8888', '1978-08-12'),
('55-4444-33333', 'Gabriela', 'Ríos', 'Av. E, Ciudad', '999-0000', '2000-07-03'),
('44-3333-22222', 'Oscar', 'Méndez', 'Av. F, Ciudad', '222-3333', '1992-12-25'),
('33-2222-11111', 'Isabel', 'Cordero', 'Av. G, Ciudad', '444-5555', '1982-04-17'),
('22-1111-00000', 'Héctor', 'Navarro', 'Av. H, Ciudad', '666-7777', '1970-09-08'),
('11-0000-99999', 'Adriana', 'Solís', 'Av. I, Ciudad', '888-9999', '1998-03-19'),
('00-9999-88888', 'Felipe', 'Campos', 'Av. J, Ciudad', '000-1111', '1989-06-22');

-- Insertar datos en Producto
INSERT INTO Producto (codigo_producto, nombre, precio, descripcion, tipo_producto) VALUES
(101, 'Tomate', 1.50, 'Tomate fresco', 'Ingrediente'),
(102, 'Pollo', 4.00, 'Pollo orgánico', 'Ingrediente'),
(103, 'Arroz', 2.00, 'Arroz premium', 'Ingrediente'),
(104, 'Vino Tinto', 15.00, 'Reserva especial', 'Producto'),
(105, 'Queso', 3.50, 'Queso madurado', 'Ingrediente'),
(106, 'Pan', 1.00, 'Pan artesanal', 'Producto'),
(107, 'Café', 2.50, 'Café de altura', 'Producto'),
(108, 'Chocolate', 4.00, 'Chocolate 70%', 'Ingrediente'),
(109, 'Helado', 3.00, 'Helado de vainilla', 'Producto'),
(110, 'Refresco', 2.00, 'Refresco cola', 'Producto');

-- Insertar datos en Proveedor
INSERT INTO Proveedor (codigo_proveedor, nombre, persona_contacto, direccion, email) VALUES
(201, 'Distribuidora Alimentos S.A.', 'Roberto Sánchez', 'Av. K, Ciudad', 'contacto@alimentos.com'),
(202, 'Bebidas Premium Ltda.', 'Laura Mejía', 'Av. L, Ciudad', 'ventas@bebidaspremium.com'),
(203, 'Carnes Selectas', 'Carlos Rojas', 'Av. M, Ciudad', 'info@carnesselectas.com'),
(204, 'Delicias del Mar', 'Marta Fuentes', 'Av. N, Ciudad', 'pedidos@deliciasmar.com'),
(205, 'Granos y Más', 'Jorge Linares', 'Av. O, Ciudad', 'contacto@granosymas.com'),
(206, 'Lácteos Frescos', 'Ana Beltrán', 'Av. P, Ciudad', 'lacteos@frescos.com'),
(207, 'Panadería Artesanal', 'Pedro Navarro', 'Av. Q, Ciudad', 'info@panartesanal.com'),
(208, 'Dulces Sueños', 'Lucía Jiménez', 'Av. R, Ciudad', 'ventas@dulcessueños.com'),
(209, 'Importaciones Gourmet', 'Diego Castro', 'Av. S, Ciudad', 'gourmet@importaciones.com'),
(210, 'Frutas Tropicales', 'Elena Mora', 'Av. T, Ciudad', 'frutas@tropicales.com');

-- Insertar datos en Plato
INSERT INTO Plato (codigo_plato, tipo, precio, descripcion, cedula_cocinero) VALUES
(301, 'Entrada', 8.00, 'Ensalada César', '67-8901-23456'),
(302, 'Principal', 15.00, 'Pollo al curry', '78-9012-34567'),
(303, 'Principal', 18.00, 'Lomo de salmón', '89-0123-45678'),
(304, 'Postre', 7.00, 'Tiramisú', '90-1234-56789'),
(305, 'Entrada', 9.00, 'Sopa de mariscos', '67-8901-23456'),
(306, 'Principal', 16.50, 'Risotto de hongos', '78-9012-34567'),
(307, 'Principal', 20.00, 'Filete mignon', '89-0123-45678'),
(308, 'Postre', 6.50, 'Flan de caramelo', '90-1234-56789'),
(309, 'Entrada', 7.50, 'Bruschettas', '01-2345-67890'),
(310, 'Postre', 8.00, 'Cheesecake', '01-2345-67890');

-- Insertar datos en Orden
INSERT INTO Orden (num_orden, fecha, monto_total, forma_pago, id_sucursal, cedula_cliente, cedula_camarero) VALUES
(1001, '2024-06-01', 32.50, 'Tarjeta', 1, '99-8888-77777', '12-3456-78901'),
(1002, '2024-06-02', 25.00, 'Efectivo', 2, '88-7777-66666', '23-4567-89012'),
(1003, '2024-06-03', 41.00, 'Tarjeta', 3, '77-6666-55555', '34-5678-90123'),
(1004, '2024-06-04', 18.50, 'Efectivo', 4, '66-5555-44444', '45-6789-01234'),
(1005, '2024-06-05', 29.75, 'Tarjeta', 5, '55-4444-33333', '56-7890-12345'),
(1006, '2024-06-06', 36.00, 'Efectivo', 1, '44-3333-22222', '12-3456-78901'),
(1007, '2024-06-07', 22.50, 'Tarjeta', 2, '33-2222-11111', '23-4567-89012'),
(1008, '2024-06-08', 47.25, 'Efectivo', 3, '22-1111-00000', '34-5678-90123'),
(1009, '2024-06-09', 15.00, 'Tarjeta', 4, '11-0000-99999', '45-6789-01234'),
(1010, '2024-06-10', 28.50, 'Efectivo', 5, '00-9999-88888', '56-7890-12345'),
(1011, '2024-06-11', 35.00, 'Tarjeta', 1, '99-8888-77777', '12-3456-78901'),
(1012, '2024-06-12', 22.75, 'Efectivo', 2, '88-7777-66666', '23-4567-89012'),
(1013, '2024-06-13', 40.50, 'Tarjeta', 3, '77-6666-55555', '34-5678-90123'),
(1014, '2024-06-14', 19.00, 'Efectivo', 4, '66-5555-44444', '45-6789-01234'),
(1015, '2024-06-15', 31.20, 'Tarjeta', 5, '55-4444-33333', '56-7890-12345'),
(1016, '2024-06-16', 38.75, 'Efectivo', 1, '44-3333-22222', '12-3456-78901'),
(1017, '2024-06-17', 24.50, 'Tarjeta', 2, '33-2222-11111', '23-4567-89012'),
(1018, '2024-06-18', 49.00, 'Efectivo', 3, '22-1111-00000', '34-5678-90123'),
(1019, '2024-06-19', 16.80, 'Tarjeta', 4, '11-0000-99999', '45-6789-01234'),
(1020, '2024-06-20', 27.60, 'Efectivo', 5, '00-9999-88888', '56-7890-12345');

-- Insertar datos en Incluye
INSERT INTO Incluye (num_orden, codigo_plato, cantidad) VALUES
(1001, 301, 2),
(1001, 302, 1),
(1002, 303, 1),
(1002, 304, 1),
(1003, 305, 1),
(1003, 307, 2),
(1004, 309, 3),
(1005, 302, 2),
(1006, 306, 1),
(1006, 310, 1),
(1007, 308, 2),
(1008, 307, 1),
(1008, 304, 1),
(1009, 310, 2),
(1010, 303, 1);

-- Insertar datos en Contiene
INSERT INTO Contiene (codigo_plato, codigo_producto, cantidad) VALUES
(301, 101, 3),
(301, 105, 1),
(302, 102, 2),
(302, 103, 1),
(303, 104, 1),
(303, 102, 1),
(304, 108, 2),
(304, 109, 1),
(305, 101, 2),
(305, 110, 1),
(306, 103, 1),
(306, 105, 2),
(307, 102, 3),
(308, 105, 1),
(308, 108, 1),
(309, 101, 2),
(309, 106, 1),
(310, 105, 3),
(310, 108, 1);

-- Insertar datos en Ofrece
INSERT INTO Ofrece (id_sucursal, codigo_plato) VALUES
(1, 301), (1, 302), (1, 304), (1, 306),
(2, 303), (2, 305), (2, 308),
(3, 301), (3, 307), (3, 310),
(4, 302), (4, 309), (4, 304),
(5, 303), (5, 306), (5, 308);

-- Insertar datos en Suministra_producto
INSERT INTO Suministra_producto (codigo_proveedor, codigo_producto, fecha, cantidad) VALUES
(201, 101, '2024-05-01', 50),
(201, 103, '2024-05-02', 30),
(202, 104, '2024-05-03', 20),
(203, 102, '2024-05-04', 40),
(204, 101, '2024-05-05', 35),
(205, 103, '2024-05-06', 25),
(206, 105, '2024-05-07', 30),
(207, 106, '2024-05-08', 60),
(208, 108, '2024-05-09', 15),
(209, 104, '2024-05-10', 18),
(210, 101, '2024-05-11', 45),
(201, 102, '2024-06-01', 55),
(202, 103, '2024-06-05', 28),
(203, 104, '2024-06-10', 22),
(204, 105, '2024-06-15', 33),
(205, 106, '2024-06-20', 45),
(206, 107, '2024-07-01', 50),
(207, 108, '2024-07-05', 20),
(208, 101, '2024-07-10', 40),
(209, 102, '2024-07-15', 38),
(210, 103, '2024-07-20', 26);

-- Insertar datos en Trabajan_en
INSERT INTO Trabajan_en (cedula_empleado, id_sucursal) VALUES
('12-3456-78901', 1),
('23-4567-89012', 2),
('34-5678-90123', 3),
('45-6789-01234', 4),
('56-7890-12345', 5),
('67-8901-23456', 1),
('78-9012-34567', 2),
('89-0123-45678', 3),
('90-1234-56789', 4),
('01-2345-67890', 5);

-- Insertar datos en Maneja
INSERT INTO Maneja (cedula_administrativo, id_sucursal) VALUES
('11-2233-44556', 1),
('22-3344-55667', 2),
('33-4455-66778', 3),
('44-5566-77889', 4),
('55-6677-88990', 5);

-- Insertar datos en Teléfonos (multivaluados)
INSERT INTO Telefono_Sucursal (id_sucursal, telefono) VALUES
(1, '111-1111'),  
(2, '222-3333'),
(3, '333-2222'),
(4, '444-3333'), 
(5, '555-5555');

INSERT INTO Telefono_Empleado (cedula, telefono) VALUES
('12-3456-78901', '123-4567'), 
('23-4567-89012', '234-5678'),
('34-5678-90123', '345-6789'),
('45-6789-01234', '456-7890'), 
('45-6789-01234', '456-7891'),
('56-7890-12345', '567-8901'),
('67-8901-23456', '678-9012'),
('78-9012-34567', '789-0123'),
('89-0123-45678', '890-1234'),
('90-1234-56789', '901-2345');

INSERT INTO Telefono_Proveedor (codigo_proveedor, telefono) VALUES
(201, '200-1000'), 
(201, '200-1001'),
(202, '200-2000'),
(203, '200-3000'), 
(203, '200-3001'),
(204, '200-4000'),
(205, '200-5000'),
(206, '200-6000'), 
(206, '200-6001'),
(207, '200-7000'),
(208, '200-8000'),
(209, '200-9000'),
(210, '201-0000');


-- PROCEDIMIENTOS ALMACENADOS
/* 
	1. Calcular el total de ventas de una sucursal
	Este procedimiento calcula el total de ventas de una sucursal específica durante un mes y año determinados. 
	Recibe tres parámetros obligatorios: @id_sucursal, @mes (entre 1-12), y @año (año de consulta). Como resultado, 
	retorna el monto total de ventas a través del parámetro de salida @total_ventas y genera un conjunto de resultados 
	con información detallada que incluye: ID de sucursal, nombre de la sucursal, número del mes, nombre del mes, 
	año consultado y el total de ventas calculado.
*/
CREATE PROCEDURE pa_TotalVentasSucursal
    @id_sucursal INT,   -- Identificador de la sucursal a consultar
    @mes INT,           -- Mes numérico para el cálculo 
    @año INT,          -- Año para el cálculo
    @total_ventas DECIMAL(10,2) OUTPUT  -- Parámetro OUTPUT para el total de ventas
AS
BEGIN
    -- Cálculo del total de ventas
    SELECT @total_ventas = ISNULL(SUM(Orden.monto_total), 0)
    FROM Orden
    WHERE Orden.id_sucursal = @id_sucursal
      AND MONTH(Orden.fecha) = @mes
      AND YEAR(Orden.fecha) = @año;

    -- Obtención de información adicional:
    DECLARE @nombre_sucursal VARCHAR(100);
    DECLARE @nombre_mes VARCHAR(15);
    
    SELECT @nombre_sucur		sal = Sucursal.nombre 
    FROM Sucursal
    WHERE Sucursal.id_sucursal = @id_sucursal;
    
	-- Obtiene el nombre del mes a partir del año y mes proporcionados
    SET @nombre_mes = DATENAME(MONTH, DATEFROMPARTS(@año, @mes, 1));
    
    -- Generación del resultado final
    SELECT 
        @id_sucursal AS  id_sucursal,
        @nombre_sucursal AS nombre_sucursal,
        @mes AS mes,
        @nombre_mes AS nombre_mes,
        @año AS año,
        @total_ventas AS total_ventas;
END;

-- Ejemplo de uso (se pueden cambiar los valores)
DECLARE @resultado_exc DECIMAL(10,2);  
DECLARE @sucursal_exc INT = 2;   --Variar entre id_sucursal= (1-5) solo hay 5 sucursales     
DECLARE @mes_exc INT = 6;        --Mantener en mes=6 no hay datos para otros meses dentro de la bd        
DECLARE @año_exc INT = 2024;     --Mantener en año=2024 no hay datos para otros años dentro de la bd     

-- Ejecutar procedimiento
EXEC pa_TotalVentasSucursal 
    @id_sucursal = @sucursal_exc,
    @mes = @mes_exc,
    @año = @año_exc,
    @total_ventas = @resultado_exc OUTPUT;

/*
	2. Mostrar los diferentes platos por categorias
	Este procedimiento recupera un listado de platos y los clasifica según el precio que tengan en, 
	Económico, Estándar o Premium, adicional, puede recibir un parámetro de entrada @tipo_plato, el cual filtrara 
	por tipo de plato (Entrada, principal o postre) y cuando no se especifica este parámetro, muestra todos los platos disponibles. 
	Para cada registro devuelve: código del plato, descripción, precio, tipo de plato y una de las categoría de precio 
	mencionadas anterioremente basada en rangos de precios predefinidos. 
	Los resultados se organizan primero por tipo de plato y luego por precio en orden descendente.
*/
CREATE PROCEDURE pa_CategoriaPlatos
    @tipo_plato VARCHAR(50) = NULL -- Parametro para el filtrado por tipo
AS
BEGIN
    -- Consulta principal
    SELECT 
        Plato.codigo_plato,
        Plato.descripcion,
        Plato.precio,
        Plato.tipo,
        CASE 
            WHEN Plato.precio > 15 THEN 'Premium'					-- Si el precio es mayor a 15, es Premium
            WHEN Plato.precio BETWEEN 10 AND 15 THEN 'Estándar'		-- Si el precio está entre 10 y 15, es Estándar
            ELSE 'Económico'										-- Si es menor a 10, es Económico
        END AS categoria_precio
    FROM Plato
    WHERE (@tipo_plato IS NULL OR Plato.tipo = @tipo_plato) -- Si se pasa un tipo, filtra por ese tipo; de lo contrario,mostrara todos los platos
    ORDER BY 
        Plato.tipo,         -- Ordena por tipo de plato
        Plato.precio DESC;  -- Ordena por precio descendente
END;

-- Ejemplos de uso
-- Mostrar solo platos por tipo (Entrada, principal, postre)
EXEC pa_CategoriaPlatos @tipo_plato = 'Entrada';

-- Mostrar todos los platos de todos los tipos
EXEC pa_CategoriaPlatos;

/*
	3. Calcular total de compras de los proveedores en un determinado mes y año
	El procedimiento almacenado pa_TotalComprasProveedores calcula el total de compras y la cantidad de pedidos realizados 
	a todos los proveedores durante un período mensual específico. Recibe como parámetros de entrada el mes (1-12) y el año (formato YYYY) a consultar. 
	Internamente, agrupa los registros de compras de la tabla Suministra_producto filtrando por el mes y año especificados, 
	calculando para cada proveedor el monto total (cantidad multiplicada por precio unitario) y contabilizando los pedidos. 
	Posteriormente, genera un listado completo de todos los proveedores (incluyendo aquellos sin compras en el período) mostrando su código, 
	nombre, persona de contacto, teléfono, el total de compras (que muestra 0 cuando no existen registros) y la cantidad de pedidos correspondientes. 
	Los resultados finales se ordenan de forma descendente según el monto total de compras.
*/
CREATE PROCEDURE pa_TotalComprasProveedores
    @mes INT,  -- Mes para filtrar las compras 
    @año INT   -- Año para filtrar las compras 
AS
BEGIN
    -- Une las tablas necesarias para calcular los totales por proveedor
    SELECT 
        Proveedor.codigo_proveedor,  
        Proveedor.nombre,            
        Proveedor.persona_contacto, 
        SUM(Suministra_producto.cantidad * Producto.precio) AS total_compras,  -- Sumatoria de compras (cantidad * precio)
        COUNT(DISTINCT Suministra_producto.codigo_producto) AS cantidad_pedidos -- Conteo de productos únicos comprados
        
    FROM Proveedor
    -- Conexión proveedor → suministra_producto
    INNER JOIN Suministra_producto  
        ON Proveedor.codigo_proveedor = Suministra_producto.codigo_proveedor  -- conexión por ID de proveedor
    
    -- Conexión suministra_producto → productos 
    INNER JOIN Producto  
        ON Suministra_producto.codigo_producto = Producto.codigo_producto  -- conexión por ID de producto
    
    WHERE -- FILTRADO TEMPORAL
        MONTH(Suministra_producto.fecha) = @mes  -- Extrae mes de la fecha y compara con parámetro
        AND YEAR(Suministra_producto.fecha) = @año  -- Extrae año de la fecha y compara con parámetro
    
    GROUP BY -- AGRUPACIÓN POR PROVEEDOR
        Proveedor.codigo_proveedor,  -- Agrupación por identificador único
        Proveedor.nombre,            -- Agrupación por nombre (normalizado)
        Proveedor.persona_contacto   -- Agrupación por contacto
    ORDER BY total_compras DESC;  -- Orden descendente (mayores compras primero)
END

EXEC pa_TotalComprasProveedores @mes = 5, @año = 2024; -- Variar mes= (5,6,7), mantener año=2024 no existen mas años dentro de la bd

SELECT * FROM Proveedor
SELECT * FROM Suministra_producto
SELECT * FROM Producto

-- CURSORES

/*
	1. Cursor para calcular las compras totales de los clientes
	Este procedimiento utiliza un cursor para recorrer cada cliente registrado en la base de datos y calcular su gasto total acumulado 
	en órdenes de compra. El proceso se inicia declarando un cursor que selecciona todos los clientes de la tabla correspondiente. 
	Para cada cliente obtenido, el sistema ejecuta una consulta que suma los montos totales de todas sus órdenes asociadas, 
	utilizando su PK (cedula) para garantizar precisión en los resultados, en posibles casos de clientes con nombres similares. 
	El valor calculado se almacena temporalmente y se presenta el nombre del cliente junto con su total acumulado. 
	Finalmente, el cursor avanza al siguiente cliente repitiendo el proceso hasta completar todos los registros, 
	momento en el cual libera los recursos utilizados.
*/
-- Declarar variables para almacenar datos del cliente y total de ventas
DECLARE @nombre_cliente VARCHAR(50), @cedula_cliente VARCHAR(20), @total_ventas DECIMAL(10,2);

-- Crear cursor para recorrer clientes (usando identificador único)
DECLARE cursor_ventas_clientes CURSOR FOR 
    SELECT nombre, cedula FROM Cliente;

-- Abrir cursor para iniciar procesamiento
OPEN cursor_ventas_clientes;

-- Obtener primer registro del cursor
FETCH NEXT FROM cursor_ventas_clientes INTO @nombre_cliente, @cedula_cliente;

-- Recorrer todos los registros del cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Calcular total de ventas para el cliente actual usando su cédula
    SELECT @total_ventas = SUM(monto_total)
    FROM Orden
    WHERE cedula_cliente = @cedula_cliente; 

    -- Mostrar resultado formateado
    PRINT 'Cliente: ' + @nombre_cliente + ' | Total comprado: $' + CAST(@total_ventas AS VARCHAR);

    -- Obtener siguiente registro
    FETCH NEXT FROM cursor_ventas_clientes INTO @nombre_cliente, @cedula_cliente;
END;

-- Cerrar cursor para liberar recursos
CLOSE cursor_ventas_clientes;

-- Liberar memoria del cursor
DEALLOCATE cursor_ventas_clientes;

-- FUNCIONES
	/*
		1. Función que calcula el margen de beneficio para un plato (Función escalar)
		Esta función determina el margen de beneficio bruto (ganancia) generado por un plato específico del restaurante. 
		Recibe como parámetro único el código identificador del plato (@codigo_plato INT), utilizando este valor para 
		localizar el registro correspondiente en la tabla Plato. El beneficio del plato se calcula restando el costo total
		de los ingredientes al precio de venta del plato, retornando el resultado como un valor decimal.
	*/
CREATE FUNCTION f_CalcularBeneficioPlato
(@codigo_plato INT)
RETURNS DECIMAL(10,2)  -- Retorna valor escalar (margen de beneficio)
AS
BEGIN
    DECLARE @beneficio DECIMAL(10,2)  -- Variable local para resultado
    DECLARE @precio DECIMAL(10,2)  -- Precio de venta del plato
    DECLARE @costo DECIMAL(10,2)   -- Costo total de ingredientes

    -- Obtiene el precio del plato
    SELECT @precio = precio
    FROM Plato
    WHERE codigo_plato = @codigo_plato

 -- Suma el costo de ingredientes multiplicado por la cantidad
    SELECT @costo = SUM(Producto.precio * Contiene.cantidad)
    FROM Contiene, Producto
    WHERE Contiene.codigo_producto = Producto.codigo_producto AND Contiene.codigo_plato = @codigo_plato

    -- Calcula el margen de beneficio
    SET @beneficio = @precio - @costo

    RETURN @beneficio  -- Retorna el margen calculado
END; 

-- Prueba de la función con el codigo_plato = 302 (pollo al curry)
SELECT dbo.f_CalcularBeneficioPlato(302) AS Beneficio;

-- Visualizar los datos del plato (Para verificación unicamente)
SELECT * FROM plato where codigo_plato = 302
SELECT * FROM contiene where codigo_plato = 302 
SELECT * FROM producto where codigo_producto = 103
SELECT * FROM producto where codigo_producto = 102

	/*
	2. Función que muestra todas las órdenes de un cliente con detalles (Función de tabla con multiples instrucciones)
	Esta función muestra en forma estructurada todas las órdenes asociadas a un cliente, combinando información crítica de múltiples tablas. 
	Recibe como parámetro único la cédula del cliente (@cedula_cliente VARCHAR(13)), utilizando este dato para filtrar las transacciones del 
	cliente solicitado. Combina datos de las tablas Orden, Sucursal, Camarero y Empleado, selecciona el numero de orden, fecha, monto,
	sucursal donde se hizo la orden y nombre del camarero. Los resultados los inserta en una tabla (@ordenes) que retorna los resultados en
	forma tabular.
	*/
CREATE FUNCTION f_ObtenerOrdenesCliente
(@cedula_cliente VARCHAR(13))
RETURNS @ordenes TABLE  -- Tabla explícita de retorno
(
    num_orden INT,
    fecha DATE,
    monto_total DECIMAL(10,2),
    sucursal VARCHAR(100),
    camarero VARCHAR(100)
)
AS
BEGIN
    -- Consulta multitabla 
    INSERT INTO @ordenes
    SELECT	
        Orden.num_orden,							-- Numero de la orden
        Orden.fecha,								-- Fecha de la orden
        Orden.monto_total,							-- Monto total pagado
        Sucursal.nombre,							-- Nombre de la sucursal
        Empleado.nombre + ' ' + Empleado.apellido	-- Nombre completo del camarero
    FROM Orden, Sucursal, Camarero, Empleado
    WHERE Orden.id_sucursal = Sucursal.id_sucursal  -- Relación con sucursal
      AND Orden.cedula_camarero = Camarero.cedula	 -- Relación con camarero
      AND Camarero.cedula = Empleado.cedula			-- Relación con empleado
      AND Orden.cedula_cliente = @cedula_cliente	-- Filtro por cliente

    RETURN  -- Finaliza retornando la tabla
END;

-- Prueba de la función con el cliente 
SELECT * FROM dbo.f_ObtenerOrdenesCliente('99-8888-77777');

-- Visualizar los datos del cliente (Para verificación unicamente)
SELECT * FROM cliente 
SELECT * FROM orden where cedula_cliente = '99-8888-77777'

	/*
		3. Lista platos ofrecidos en una sucursal con información del cocinero (Funcion de tabla en linea)
		Esta función muestra un listado completo de los platos ofertados en una sucursal determinada, 
		incluyendo información sobre el plato y el cocinero que lo realizo. Recibe como parámetro el 
		ID de la sucursal (@id_sucursal INT), utilizando este para filtrar los platos disponibles en 
		dicha sucursal.
	*/
CREATE FUNCTION f_PlatosDisponiblesSucursal
(@id_sucursal INT)
RETURNS TABLE  -- Tabla implícita definida por el SELECT
AS
RETURN 
(
    -- Consulta multitabla 
    SELECT 
        Plato.codigo_plato,		-- Identificador único del plato
        Plato.descripcion,		-- Descripción detallada del plato
        Plato.precio,			-- Precio del plato 
		Empleado.nombre + ' ' + Empleado.apellido as Nombre_Empleado, -- Nombre del cocinero
		Cocinero.tipo
    FROM Ofrece, Plato, Cocinero, Empleado
    WHERE Ofrece.codigo_plato = Plato.codigo_plato	-- Relación plato-ofrecimiento
      AND Plato.cedula_cocinero = Cocinero.cedula	-- Relación plato-cocinero
      AND Cocinero.cedula = Empleado.cedula			-- Relación cocinero-datos empleado
      AND Ofrece.id_sucursal = @id_sucursal			-- Filtro por sucursal específica
);

-- Prueba de la función con la sucursal con el ID=3
SELECT * FROM dbo.f_PlatosDisponiblesSucursal(3);


-- TRIGGERS

	/*
	1. Al ingresar una orden, verificara que el cliente exista en la base de datos
	El siguiente trigger verificara si al momento de ingresar una nueva orden, el cliente
	al que va dirijida existe dentro de la base de datos, si detecta que un cliente no esta
	registrado retornara un mensaje de error, indicando que dicho cliente no esta registrado
	*/
CREATE TRIGGER t_RegistrarOrden
ON Orden
INSTEAD OF INSERT
AS
BEGIN
    -- Verificar si alguno de los clientes en inserted NO está registrado en la tabla Cliente
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE cedula_cliente NOT IN (
            SELECT cedula FROM Cliente
        )
    )
    BEGIN -- Entra al bloque si la condición es verdadera
        -- Mostrar mensaje de error si hay clientes no registrados
        SELECT 'Cliente no registrado' AS Error;
        RETURN;
    END -- Fin IF

    -- Insertar sólo las filas cuya cedula_cliente sí está registrada en Cliente
    INSERT INTO Orden (num_orden, fecha, monto_total, forma_pago, id_sucursal, cedula_cliente, cedula_camarero)
    SELECT 
        num_orden,
        fecha,
        monto_total,
        forma_pago,
        id_sucursal,
        cedula_cliente,
        cedula_camarero
    FROM inserted
    WHERE cedula_cliente IN (
        SELECT cedula FROM Cliente
    );
END; -- Fin trigger t_RegistrarOrden

-- Visualizar los clientes existentes y ordenes
SELECT * FROM cliente;
SELECT * FROM orden;

-- Prueba con cliente existente
INSERT INTO Orden (num_orden, fecha, monto_total, forma_pago, id_sucursal, cedula_cliente, cedula_camarero)
VALUES (1022, '2024-07-02', 60.00, 'Efectivo', 2, '00-9999-88888', '23-4567-89012');

-- Prueba con cliente no existente
INSERT INTO Orden (num_orden, fecha, monto_total, forma_pago, id_sucursal, cedula_cliente, cedula_camarero)
VALUES (1023, '2024-07-03', 45.00, 'Tarjeta', 1, '99-0000-00000', '12-3456-78901');

	/*
		2. Actualizar el precio de un plato en base al aumento del precio del producto con un margen de 30% de ganancia
		Este trigger se activara después de una actualización en la tabla Producto, con el objetivo de reajustar el precio 
		de los platos que utilizan productos cuyos precios han sido modificados. El proceso inicia verificando si la actualización 
		afectó la columna precio mediante la cláusula IF UPDATE(precio). Cuando se detecta un cambio, el sistema identifica los platos 
		afectados mediante una subconsulta que cruza la tabla Contiene con los registros actualizados (inserted). Para cada plato vinculado, 
		recalcula su precio sumando el costo total de sus ingredientes y aplica un margen de ganancia del 30% sobre este costo. 
		Luego actualiza la tabla Plato con el nuevo precio, mantienendo el margen de beneficio establecido.
	*/
CREATE TRIGGER t_ActualizarPrecioPlato
ON Producto
AFTER UPDATE
AS
BEGIN
    -- Solo actuar si el precio del producto cambió
    IF UPDATE(precio)
    BEGIN
        -- Actualizar el precio de cada plato afectado
        UPDATE Plato
        SET precio =
        (
            -- Calculamos el nuevo precio
            (
                SELECT SUM(Producto.precio * Contiene.cantidad)
                FROM Contiene, Producto
                WHERE Contiene.codigo_plato = Plato.codigo_plato AND Contiene.codigo_producto = Producto.codigo_producto
            )	* 1.3 -- (suma del costo de cada ingrediente * cantidad usada) multiplicado por 1.3 (30% margen)
        )
        WHERE Plato.codigo_plato IN
        (
            -- Aquí filtramos solo los platos que usan los productos cuyo precio cambió
            SELECT Contiene.codigo_plato
            FROM Contiene, inserted
            WHERE Contiene.codigo_producto = inserted.codigo_producto
        )
    END -- Fin IF
END; -- Fin trigger t_ActualizarPrecioPlato

-- Verificar precios antes de actualizar
SELECT codigo_plato, precio FROM Plato WHERE codigo_plato = 301;
SELECT Contiene.codigo_producto, Producto.precio, Contiene.cantidad
FROM Contiene, Producto
WHERE Contiene.codigo_producto = Producto.codigo_producto AND Contiene.codigo_plato = 301;

-- Prueba de actualización para el trigger
UPDATE Producto
SET precio = 2.50
WHERE codigo_producto = 101;

	/*
		3. Elimina al proveedor y muestra los productos afectados
		Este trigger se activara al detectar un intento de eliminación, inicia verificando la existencia del proveedor mediante la tabla deleted. 
		Si no se detectan registros a eliminar, devuelve un mensaje de notificación indicando que el proveedor no existe. Cuando existen registros, 
		el sistema genera una notificación por cada producto relacionado con el proveedor, informando que dichos productos se verán afectados por 
		la eliminación. Posteriormente, elimina los teléfonos asociados al proveedor en Telefono_Proveedor, los registros de suministro en Suministra_producto 
		y al final el propio proveedor en la tabla Proveedor. 
	*/
CREATE TRIGGER t_ProveedorProducto
ON Proveedor
INSTEAD OF DELETE
AS
BEGIN
	-- Verificación para la existencia del proveedor 
	 IF NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        SELECT 'El proveedor no existe' AS Notificación;
        RETURN;
    END; -- FIn IF

	-- Mostrar una lista de notificaciones indicando qué productos estaban relacionados con el proveedor eliminado
    SELECT ('Proveedor eliminado afecta a producto: ' + Producto.nombre) AS Notificación --  mensaje de notificación 
    FROM Producto
    WHERE
        -- Filtro: el producto debe estar en la lista de productos que eran suministrados por el proveedor que se eliminó
        codigo_producto IN (
            -- Subconsulta que obtiene todos los códigos de producto que estaban relacionados con el proveedor eliminado
            SELECT Suministra_producto.codigo_producto
            FROM Suministra_producto
            WHERE Suministra_producto.codigo_proveedor IN (
                SELECT codigo_proveedor
                FROM deleted
            )
        );

    -- Eliminar de la tabla Telefono_Proveedor todos los teléfonos asociados al proveedor 
    DELETE FROM Telefono_Proveedor
    WHERE codigo_proveedor IN (
        SELECT codigo_proveedor-- Subconsulta que obtiene el codigo_proveedor de las filas eliminadas
        FROM deleted
    );

    -- Eliminar de la tabla Suministra_producto todos los registros asociados al proveedor
    DELETE FROM Suministra_producto
    WHERE codigo_proveedor IN ( 
        SELECT codigo_proveedor -- Subconsulta que obtiene el codigo_proveedor de las filas eliminadas
        FROM deleted
    );

    -- Eliminar el registro del proveedor
    DELETE FROM Proveedor
    WHERE codigo_proveedor IN (
        SELECT codigo_proveedor -- Subconsulta que obtiene el codigo_proveedor de las filas eliminadas
        FROM deleted
    );
END; -- Fin trigger

-- Verificar información asociada al proveedor
SELECT * FROM producto
SELECT * FROM proveedor WHERE codigo_proveedor = 207
SELECT * FROM suministra_producto WHERE codigo_proveedor = 207;

-- Prueba para eliminar al proveedor
DELETE FROM Proveedor
WHERE codigo_proveedor = 208;


-- VISTAS

	/*
		1. Vista de Proveedores con Productos Suministrados
		Esta vista muestra información importante sobre las relaciones entre proveedores y productos mediante al unión de tres tablas: Proveedor, Producto y Suministra_producto. 
		Para generar un reporte que muestre por cada proveedor: su identificador, nombre, contacto, junto con los productos asociados (código, nombre, precio), y detalles históricos 
		de suministros (fecha y cantidad entregada).
	*/
CREATE VIEW Reporte_Proveedores_Productos AS
SELECT 
    Proveedor.codigo_proveedor,               -- PK del proveedor 
    Proveedor.nombre AS nombre_proveedor,      -- Nombre comercial del proveedor 
    Proveedor.persona_contacto,                -- Responsable de comunicación con el proveedor
    Producto.codigo_producto,                 -- PK del producto 
    Producto.nombre AS nombre_producto,        -- Nombre del producto suministrado 
    Producto.precio,                           -- Precio actual del producto 
    Suministra_producto.fecha,                 -- Fecha del suministro 
    Suministra_producto.cantidad               -- Volumen entregado en la transacción
FROM Proveedor, Producto, Suministra_producto  -- Tablas fuentes de datos
WHERE 
    Proveedor.codigo_proveedor = Suministra_producto.codigo_proveedor -- Relaciona proveedores con sus registros de suministro
    AND Producto.codigo_producto = Suministra_producto.codigo_producto; --  Relaciona productos con los registros de suministro

-- Mostrar la vista
SELECT * FROM Reporte_Proveedores_Productos

	/*
		2. Vista de Órdenes con Detalles de Platos y Clientes
		Esta vista muestra información de las órdenes de compra, clientes, platos y sus relaciones para generar un reporte de las transacciones realizadas. 
		Combina datos de cuatro tablas (Orden, Cliente, Plato, Incluye). Proporciona un reporte completo de cada orden, incluyendo: número, fecha, monto total, 
		nombre del cliente, detalles de los platos (código, tipo, precio) y cantidades solicitadas.
	*/
CREATE VIEW Reporte_Detalles_Orden AS
SELECT 
    Orden.num_orden,                       -- Número de la orden (PK)
    Orden.fecha,                           -- Fecha de la transacción
    Orden.monto_total,                     -- Total pagado en la orden
    Cliente.nombre + ' ' + Cliente.apellido AS Nombre_Cliente, -- Nombre y apellido del cliente 
    Plato.codigo_plato,                    -- Identificador único del plato
    Plato.tipo,                            -- Categoría del plato (Entrada/Principal/Postre)
    Plato.precio,                          -- Precio unitario del plato en el momento de la orden
    Incluye.cantidad                       -- Cantidad solicitada de este plato en la orden
FROM Orden, Cliente, Plato, Incluye        -- Tablas fuentes
WHERE 
    Orden.cedula_cliente = Cliente.cedula		-- Vincula orden con cliente mediante cédula
    AND Orden.num_orden = Incluye.num_orden		-- Relaciona orden con los platos incluidos
    AND Incluye.codigo_plato = Plato.codigo_plato;	-- Enlaza los platos de la relación "Incluye"

-- Mostrar la vista
SELECT * FROM Reporte_Detalles_Orden