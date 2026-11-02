/*
	Script incremental: gestion de stock + pedidos/ventas.
	Ejecutar contra la base CATALOGO_WEB_DB ya creada por Catalogo_Completo.sql.

	No se modifico Catalogo_Completo.sql porque esta guardado en UTF-16
	(exportado por SSMS) y editarlo como texto plano corre riesgo de corromperlo.
	Este script deja la base al dia; si en algun momento se re-exporta un dump
	completo desde SSMS, va a incluir estos cambios de forma nativa.
*/

USE [CATALOGO_WEB_DB]
GO

-- ===================== ARTICULOS: columna Stock =====================
ALTER TABLE [dbo].[ARTICULOS] ADD [Stock] [int] NOT NULL DEFAULT (0)
GO

-- ===================== Tabla PEDIDOS (cabecera) =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PEDIDOS](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdUser] [int] NOT NULL,
	[Estado] [varchar](20) NOT NULL,
	[FechaPedido] [datetime] NOT NULL,
	[FechaConfirmacion] [datetime] NULL,
 CONSTRAINT [PK_PEDIDOS] PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO

-- ===================== Tabla DETALLE_PEDIDOS (lineas) =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DETALLE_PEDIDOS](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPedido] [int] NOT NULL,
	[IdArticulo] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
 CONSTRAINT [PK_DETALLE_PEDIDOS] PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO

-- ===================== SPs de ARTICULOS: agregan @stock =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AgregarArticuloSP]
	@codigo varchar(50),
	@nombre varchar(50),
	@descripcion varchar(150),
	@idMarca int,
	@idCategoria int,
	@imagenUrl varchar(1000),
	@precio money,
	@stock int
AS
BEGIN
	INSERT INTO ARTICULOS (Codigo, Nombre, Descripcion, IdMarca, IdCategoria, ImagenUrl, Precio, Stock)
	VALUES (@codigo, @nombre, @descripcion, @idMarca, @idCategoria, @imagenUrl, @precio, @stock)

	-- Nos devuelve el ID autogenerado por el IDENTITY(1,1)
	SELECT SCOPE_IDENTITY()
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ModificarArticuloSP]
	@id int,
	@codigo varchar(50),
	@nombre varchar(50),
	@descripcion varchar(150),
	@idMarca int,
	@idCategoria int,
	@imagenUrl varchar(1000),
	@precio money,
	@stock int
AS
BEGIN
	UPDATE ARTICULOS
	SET
		Codigo = @codigo,
		Nombre = @nombre,
		Descripcion = @descripcion,
		IdMarca = @idMarca,
		IdCategoria = @idCategoria,
		ImagenUrl = @imagenUrl,
		Precio = @precio,
		Stock = @stock
	WHERE Id = @id
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		A.Nombre LIKE '%' + @busqueda + '%'
		OR A.Descripcion LIKE '%' + @busqueda + '%'
		OR C.Descripcion LIKE '%' + @busqueda + '%'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	WHERE F.IdUser = @IdUser
END
GO

-- ===================== SPs de PEDIDOS =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CrearPedidoSP]
	@idUser int
AS
BEGIN
	INSERT INTO PEDIDOS (IdUser, Estado, FechaPedido)
	VALUES (@idUser, 'Pendiente', GETDATE())

	SELECT SCOPE_IDENTITY()
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AgregarDetallePedidoSP]
	@idPedido int,
	@idArticulo int,
	@cantidad int,
	@precioUnitario money
AS
BEGIN
	INSERT INTO DETALLE_PEDIDOS (IdPedido, IdArticulo, Cantidad, PrecioUnitario)
	VALUES (@idPedido, @idArticulo, @cantidad, @precioUnitario)
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ListarPedidosPendientesSP]
AS
BEGIN
	SELECT
		P.Id,
		P.IdUser,
		U.email AS EmailUsuario,
		P.Estado,
		P.FechaPedido,
		P.FechaConfirmacion
	FROM PEDIDOS P
	INNER JOIN USERS U ON U.Id = P.IdUser
	WHERE P.Estado = 'Pendiente'
	ORDER BY P.FechaPedido
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ListarDetallePedidoSP]
	@idPedido int
AS
BEGIN
	SELECT
		D.Id,
		D.IdPedido,
		D.Cantidad,
		D.PrecioUnitario,
		A.Id AS IdArticulo,
		A.Codigo,
		A.Nombre,
		A.Descripcion,
		A.ImagenUrl,
		A.Stock
	FROM DETALLE_PEDIDOS D
	INNER JOIN ARTICULOS A ON A.Id = D.IdArticulo
	WHERE D.IdPedido = @idPedido
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ConfirmarVentaSP]
	@idPedido int
AS
BEGIN
	DECLARE @cantidadLineas int
	DECLARE @nombreArticuloSinStock varchar(50)

	SELECT @cantidadLineas = COUNT(*) FROM DETALLE_PEDIDOS WHERE IdPedido = @idPedido

	BEGIN TRANSACTION

	-- Descuenta stock linea por linea, solo si alcanza; el WHERE con Stock >= Cantidad
	-- hace que el chequeo y el descuento sean atomicos (evita que dos ventas concurrentes
	-- dejen el stock en negativo).
	UPDATE A
	SET A.Stock = A.Stock - D.Cantidad
	FROM ARTICULOS A
	INNER JOIN DETALLE_PEDIDOS D ON D.IdArticulo = A.Id
	WHERE D.IdPedido = @idPedido AND A.Stock >= D.Cantidad

	IF @@ROWCOUNT < @cantidadLineas
	BEGIN
		-- Al menos una linea no tenia stock suficiente: se deshacen los descuentos
		-- que sí se hayan aplicado y no se confirma nada de este pedido.
		ROLLBACK TRANSACTION

		SELECT TOP 1 @nombreArticuloSinStock = A.Nombre
		FROM DETALLE_PEDIDOS D
		INNER JOIN ARTICULOS A ON A.Id = D.IdArticulo
		WHERE D.IdPedido = @idPedido AND A.Stock < D.Cantidad

		SELECT CAST(0 AS BIT) AS Exito, @nombreArticuloSinStock AS ArticuloSinStock
		RETURN
	END

	UPDATE PEDIDOS
	SET Estado = 'Confirmado', FechaConfirmacion = GETDATE()
	WHERE Id = @idPedido

	COMMIT TRANSACTION

	SELECT CAST(1 AS BIT) AS Exito, CAST(NULL AS varchar(50)) AS ArticuloSinStock
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CancelarPedidoSP]
	@idPedido int
AS
BEGIN
	-- Solo cancela pedidos pendientes; uno ya confirmado no se toca desde aca.
	UPDATE PEDIDOS
	SET Estado = 'Cancelado'
	WHERE Id = @idPedido AND Estado = 'Pendiente'
END
GO
