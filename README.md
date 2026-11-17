# Catálogo Web – TP Final Programación

Catálogo de productos con carrito de compras, favoritos y panel de administración.
Hecho en **ASP.NET Web Forms (.NET Framework 4.8)** con **SQL Server**.

## Funcionalidades

**Usuarios**
- Ver el catálogo, buscar, filtrar por categoría y marca, y ordenar por precio o nombre.
- Ver el detalle de cada artículo.
- Registrarse e iniciar sesión.
- Mi perfil: editar nombre y apellido y cambiar la contraseña.
- Agregar artículos a favoritos.
- Carrito de compras: sumar o restar unidades sin pasarse del stock.
- Iniciar la compra: se genera un pedido y se manda por WhatsApp al comercio.
- Ver el historial de compras confirmadas.

**Administrador**
- ABM de artículos (con imagen) y filtro avanzado por código, precio, marca o categoría.
- Importación masiva de artículos desde un archivo CSV (hay una plantilla en `CatalogoWEB/Content/plantilla_articulos.csv`), con un resumen de qué filas se cargaron y cuáles tuvieron errores.
- Exportación de los artículos a CSV (respeta los filtros aplicados y usa el mismo formato que la importación).
- Aviso en Administración cuando hay artículos con 5 unidades o menos.
- ABM de marcas y categorías.
- Ventas: confirmar pedidos (descuenta stock) o cancelarlos.
- Pedidos cancelados: reactivarlos o borrarlos.
- Configurar el número de WhatsApp del comercio.
- Dashboard con ventas, artículos más vendidos, stock bajo y favoritos.

## Estructura de la solución

| Proyecto | Qué tiene |
|---|---|
| `Dominio` | Las clases del negocio: `Articulo`, `Usuario`, `Pedido`, `DetallePedido`, `ItemCarrito`, `Marca`, `Categoria`. |
| `Consultas` | El acceso a datos. `AccesoDatos` maneja la conexión y cada clase `ConsultasX` llama a los stored procedures. También está `Seguridad` (chequeo de sesión y admin) y `HashContrasena`. |
| `CatalogoWEB` | El sitio web: las páginas `.aspx`, la master page, los estilos y la carpeta `Images`. Las páginas de administración heredan de `PaginaAdmin`, que controla que el usuario sea admin. |

## Cómo levantarlo

1. Abrir `TPFinalNivel3ConcettiAlvaro.sln` con Visual Studio.
2. En SQL Server Management Studio, ejecutar los scripts de `CatalogoWEB/bdd-catalogoweb` **en este orden**:
   1. `Catalogo_Completo.sql` (crea la base `CATALOGO_WEB_DB`)
   2. `Stock_Pedidos.sql`
   3. `Migracion_MarcaCategoria.sql`
   4. `HistorialCategoriasTelefono.sql`
   5. `Migracion_DuplicadosMarcaCategoria.sql`
   6. `PedidosCancelados.sql`
   7. `Seguridad_HashContrasenas.sql`
   8. `Perfil.sql`
   9. `Bajas_Logicas.sql`
3. Revisar la cadena de conexión en `CatalogoWEB/Web.config` (`CadenaConexion`). Por defecto usa `.\SQLEXPRESS` con autenticación de Windows.
4. Poner `CatalogoWEB` como proyecto de inicio y ejecutar (F5).

### Crear un administrador

Registrarse desde la página y después marcar el usuario como admin en la base:

```sql
UPDATE USERS SET admin = 1 WHERE email = 'tu@email.com'
```

## Seguridad

- Las contraseñas se guardan con hash (PBKDF2 con salt) y no en texto plano. Los usuarios que ya existían se actualizan solos la próxima vez que inician sesión.
- Las páginas de administración heredan de `PaginaAdmin`, que corta la ejecución si el usuario no es admin.
- Todas las consultas usan parámetros, para evitar inyección SQL.
- Los textos que cargan los usuarios se muestran codificados (`<%#: %>`), para evitar que se inyecte HTML o JavaScript.
- Las imágenes que se suben solo pueden ser JPG, PNG o WEBP de hasta 2 MB.
- Los artículos se dan de baja en forma lógica (`Activo = 0`): dejan de verse en el catálogo, pero los pedidos ya hechos los conservan, así el historial y las ventas no cambian.
- Los errores muestran un mensaje genérico, y no el detalle técnico.
