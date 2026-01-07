-- Script de inicialización para crear datos de ejemplo
-- Este script se ejecuta automáticamente cuando se levanta el contenedor de PostgreSQL

-- Crear tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    country VARCHAR(50)
);

-- Crear tabla de productos
CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de órdenes
CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    order_date TIMESTAMP,
    status VARCHAR(50),
    total_amount DECIMAL(10,2)
);

-- Crear tabla de items de órdenes
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    unit_price DECIMAL(10,2)
);

-- Insertar datos de ejemplo
INSERT INTO users (user_id, email, first_name, last_name, country) VALUES
(1, 'juan.perez@email.com', 'Juan', 'Pérez', 'Argentina'),
(2, 'maria.garcia@email.com', 'María', 'García', 'México'),
(3, 'carlos.lopez@email.com', 'Carlos', 'López', 'Colombia'),
(4, 'ana.martinez@email.com', 'Ana', 'Martínez', 'España'),
(5, 'luis.rodriguez@email.com', 'Luis', 'Rodríguez', 'Chile');

INSERT INTO products (product_id, name, category, price) VALUES
(1, 'Laptop Dell XPS 13', 'Electrónicos', 1299.99),
(2, 'iPhone 15', 'Electrónicos', 999.99),
(3, 'Camiseta Algodón', 'Ropa', 29.99),
(4, 'Zapatos Deportivos', 'Calzado', 89.99),
(5, 'Libro Programación', 'Libros', 49.99),
(6, 'Auriculares Bluetooth', 'Electrónicos', 79.99),
(7, 'Pantalón Jean', 'Ropa', 59.99),
(8, 'Mesa de Madera', 'Muebles', 199.99);

INSERT INTO orders (order_id, user_id, order_date, status, total_amount) VALUES
(1, 1, '2024-01-15 10:30:00', 'completed', 1329.98),
(2, 2, '2024-01-16 14:20:00', 'completed', 89.99),
(3, 3, '2024-01-17 09:15:00', 'pending', 159.98),
(4, 1, '2024-01-18 16:45:00', 'completed', 79.99),
(5, 4, '2024-01-19 11:30:00', 'shipped', 1299.99),
(6, 5, '2024-01-20 13:20:00', 'completed', 259.98),
(7, 2, '2024-01-21 08:10:00', 'cancelled', 49.99),
(8, 3, '2024-01-22 15:30:00', 'completed', 199.99);

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1, 1299.99),
(2, 1, 6, 1, 29.99),
(3, 2, 4, 1, 89.99),
(4, 3, 3, 2, 29.99),
(5, 3, 7, 1, 59.99),
(6, 4, 6, 1, 79.99),
(7, 5, 1, 1, 1299.99),
(8, 6, 2, 1, 999.99),
(9, 6, 3, 1, 29.99),
(10, 6, 7, 1, 59.99),
(11, 6, 8, 1, 199.99),
(12, 7, 5, 1, 49.99),
(13, 8, 8, 1, 199.99);
