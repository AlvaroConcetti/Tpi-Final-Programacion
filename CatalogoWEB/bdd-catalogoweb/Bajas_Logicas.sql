-- =====================================================================
-- Bajas logicas de articulos
-- Ejecutar DESPUES de Perfil.sql. Se puede ejecutar mas de una vez.
--
-- Problema: EliminarArticuloSP borraba la fila de ARTICULOS. Los pedidos
-- ya hechos (DETALLE_PEDIDOS) quedaban apuntando a un articulo que no
-- existe, y como ListarDetallePedidoSP hace INNER JOIN con ARTICULOS,
-- esa linea desaparecia del historial del cliente y de Ventas: el total
-- del pedido cambiaba (ej. de $2.700 a $1.500) y el Dashboard tambien.
--
-- Solucion: el articulo no se borra, se marca como inactivo (Activo = 0).
-- Deja de verse en el catalogo, en Administracion y en favoritos, pero
-- los pedidos viejos lo siguen encontrando y conservan todas sus lineas.
-- =====================================================================
USE CATALOGO_WEB_DB
GO

IF COL_LENGTH('ARTICULOS', 'Activo') IS NULL
BEGIN
	ALTER TABLE ARTICULOS ADD Activo BIT NOT NULL CONSTRAINT DF_ARTICULOS_Activo DEFAULT 1
END
GO

-- Baja logica en lugar de DELETE
ALTER PROCEDURE [dbo].[EliminarArticuloSP]
	@id int
AS
BEGIN
	UPDATE ARTICULOS SET Activo = 0 WHERE Id = @id
END
GO

-- Catalogo y Administracion: solo articulos activos
ALTER PROCEDURE [dbo].[ListarArticulosSP]
AS
BEGIN
	SELECT
		A.Id,
		A.Codigo,
		A.Nombre,
		A.Descripcion,
		A.ImagenUrl,
		A.Precio,
		A.Stock,
		M.Descripcion as Marca,
		C.Descripcion as Categoria,
		A.IdMarca,
		A.IdCategoria
	FROM ARTICULOS A
	INNER JOIN MARCAS M ON M.Id = A.IdMarca
	INNER JOIN CATEGORIAS C ON C.Id = A.IdCategoria
	WHERE A.Activo = 1
END
GO

ALTER PROCEDURE [dbo].[FiltrarArticulosSP]
	@busqueda varchar(50)
AS
BEGIN
	SELECT
		A.Id, A.Codigo, A.Nombre, A.Descripcion, A.ImagenUrl, A.Precio, A.Stock,
		M.Descripcion as Marca,
		C.Descripcion as Categoria,
		A.IdMarca, A.IdCategoria
	FROM ARTICULOS A
	INNER JOIN MARCAS M ON M.Id = A.IdMarca
	INNER JOIN CATEGORIAS C ON C.Id = A.IdCategoria
	WHERE
		A.Activo = 1
		AND (A.Nombre LIKE '%' + @busqueda + '%'
		OR A.Descripcion LIKE '%' + @busqueda + '%'
		OR C.Descripcion LIKE '%' + @busqueda + '%')
END
GO

-- Favoritos: un articulo dado de baja deja de aparecer
ALTER PROCEDURE [dbo].[ListarFavoritosSP]
	@IdUser INT
AS
BEGIN
	SELECT
		A.Id,
		A.Codigo,
		A.Nombre,
		A.Descripcion,
		A.ImagenUrl,
		A.Precio,
		A.Stock,
		M.Id AS IdMarca,
		M.Descripcion AS Marca,
		C.Id AS IdCategoria,
		C.Descripcion AS Categoria
	FROM ARTICULOS A
	INNER JOIN MARCAS M ON A.IdMarca = M.Id
	INNER JOIN CATEGORIAS C ON A.IdCategoria = C.Id
	INNER JOIN FAVORITOS F ON A.Id = F.IdArticulo
	WHERE F.IdUser = @IdUser AND A.Activo = 1
END
GO

-- Una marca/categoria solo esta "en uso" si la tiene algun articulo activo
ALTER PROCEDURE [dbo].[EliminarMarcaSP]
	@id int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ARTICULOS WHERE IdMarca = @id AND Activo = 1)
	BEGIN
		SELECT CAST(0 AS BIT) AS Exito
		RETURN
	END

	DELETE FROM MARCAS WHERE Id = @id
	SELECT CAST(1 AS BIT) AS Exito
END
GO

ALTER PROCEDURE [dbo].[EliminarCategoriaSP]
	@id int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ARTICULOS WHERE IdCategoria = @id AND Activo = 1)
	BEGIN
		SELECT CAST(0 AS BIT) AS Exito
		RETURN
	END

	DELETE FROM CATEGORIAS WHERE Id = @id
	SELECT CAST(1 AS BIT) AS Exito
END
GO
