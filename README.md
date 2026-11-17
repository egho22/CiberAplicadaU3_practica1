# UC3 · Práctica 1: Seguridad en APIs (BOLA, Mass Assignment y validación estricta)

**Ciberseguridad Aplicada · Ingeniería en Software · ITSON**

| Integrante | Matrícula |
|---|---|
| Alejandro Rodríguez Lugo | 251622 |
| Héctor Javier Alonso Zaragoza | 252039 |

## Estructura del repositorio

```
codigo-original/pedidos-api-vulnerable/   API con fallas intencionales + postman/Coleccion_Explotacion_P1.json
codigo-modificado/pedidos-api-seguro/     API corregida + pruebas de seguridad + postman/Coleccion_Validacion_P1.json
reportes/                                 Reportes de vulnerabilidades, correcciones y auditoría (PDF, con capturas)
evidencias/capturas/                      Capturas de Postman y de mvn test
```

## Cómo ejecutar

Requisitos: Java 17 o superior, Maven (o NetBeans / Codespaces) y Postman. **No ejecuten ambas APIs a la vez**, porque las dos usan el puerto 8080.

```bash
# 1) API vulnerable
cd codigo-original/pedidos-api-vulnerable
mvn spring-boot:run          # NetBeans: clic derecho > Run
# Verificar: http://localhost:8080/api/pedidos debe devolver 3 pedidos

# 2) API segura (detener antes la anterior con Ctrl+C)
cd codigo-modificado/pedidos-api-seguro
mvn spring-boot:run

# 3) Pruebas de seguridad
cd codigo-modificado/pedidos-api-seguro
mvn test                     # NetBeans: Test Project (Alt+F6)
```

En Postman importen la colección de cada proyecto y definan `baseUrl = http://localhost:8080`. En la versión segura agreguen el encabezado `X-User-Id: 1` (Ana) o `X-User-Id: 2` (Beto).

## Resumen de hallazgos

| ID | Hallazgo | OWASP API 2023 | Severidad | Corrección | Prueba que lo valida |
|---|---|---|---|---|---|
| P1-001 | Contraseñas en texto plano en las respuestas | API3 (BOPLA) | Crítica | `@JsonIgnore` y DTOs de salida | Tests de Postman "Ninguna contraseña en la respuesta" |
| P1-002 | BOLA de lectura en pedidos | API1 | Alta | Verificación de propiedad (403) e identidad obligatoria (401) | `PruebaBolaTest` (3 pruebas) |
| P1-003 | BOLA de lectura en usuarios | API1 | Alta | Cada usuario solo consulta su propio perfil (403) | `PruebaBolaTest.usuario1_solicitaUsuarioAjeno_retorna403` |
| P1-004 | BOLA de escritura en pedidos | API1 | Alta | DTO sin `usuario`; el dueño es siempre el usuario autenticado | `PruebaBolaTest.crearPedidoConUsuarioAjenoEnJson_quedaANombreDelAutenticado` |
| P1-005 | Mass Assignment (`"rol":"ADMIN"`) | API3 | Crítica | DTO con lista blanca, rol fijo en el servidor y esquema estricto | `PruebaMassAssignmentTest` (2 pruebas) |
| P1-006 | Validación inadecuada de entradas | API8 | Media | Bean Validation, `@Valid` y manejador global de errores | `PruebaValidacionTest` (4 pruebas) |

El detalle completo está en la carpeta [`reportes/`](reportes/).

### Ajustes del equipo a la versión segura base
Al ejecutar la versión segura se detectaron y corrigieron 5 defectos: un import faltante que impedía compilar, el conflicto entre "ignorar `rol`" y el esquema estricto, mensajes de validación no deterministas y la secuencia de identidad de H2. Además se agregaron 2 pruebas (11 en total) y 3 peticiones con *tests* a la colección de validación. Están explicados en la sección 3 del reporte de correcciones.

## Solución de problemas
- **`Port 8080 was already in use`**: detengan la otra API o usen `server.port=8081` y ajusten `baseUrl`.
- **Error 500 con "Unique index or primary key violation" al hacer POST en la API vulnerable**: la secuencia de H2 no avanzó después de `data.sql`. Repitan la petición 2 o 3 veces, porque cada intento fallido avanza la secuencia. En la API segura ya está corregido en `data.sql`.
- **401 o 403 inesperados en la versión segura**: falta `X-User-Id` o se está pidiendo un recurso ajeno, que es el comportamiento esperado.
- **Si usan MySQL** en la versión segura, borren las dos líneas `ALTER TABLE ... RESTART WITH` al final de `data.sql`.
