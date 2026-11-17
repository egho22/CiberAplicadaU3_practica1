-- =====================================================================
-- Practica 1 - Datos iniciales (version SEGURA)
-- Mismos datos que la version vulnerable para comparar resultados:
--   * Usuario 1 (Ana): pedidos 1 y 2
--   * Usuario 2 (Beto): pedido 3
-- =====================================================================

INSERT INTO usuarios (id, nombre, email, password, rol) VALUES
  (1, 'Ana', 'ana@itson.mx', 'ana12345', 'USER'),
  (2, 'Beto', 'beto@itson.mx', 'beto12345', 'USER');

INSERT INTO pedidos (id, descripcion, monto, fecha, usuario_id) VALUES
  (1, 'Laptop para laboratorio', 18500.00, '2026-09-01', 1),
  (2, 'Mouse inalambrico', 450.00, '2026-09-15', 1),
  (3, 'Monitor 24 pulgadas', 3200.00, '2026-10-02', 2);

-- ✅ (ajuste del equipo) Los INSERT anteriores usan IDs explicitos. En H2 2.x la
-- secuencia IDENTITY no siempre avanza con valores explicitos, y el primer
-- POST podia intentar usar id=1 (violacion de llave primaria -> 500).
-- Se reinician las identidades al siguiente valor libre.
-- (Si se usa MySQL, eliminar estas dos lineas: MySQL ajusta AUTO_INCREMENT solo.)
ALTER TABLE usuarios ALTER COLUMN id RESTART WITH 3;
ALTER TABLE pedidos ALTER COLUMN id RESTART WITH 4;
