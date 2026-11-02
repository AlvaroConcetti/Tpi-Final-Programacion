/*
	Script incremental: historial de compras por usuario, ABM de Marcas/Categorias
	desde el panel de administracion, y telefono de WhatsApp configurable para Ventas.
	Ejecutar contra CATALOGO_WEB_DB, despues de Stock_Pedidos.sql y Migracion_MarcaCategoria.sql.
*/

USE [CATALOGO_WEB_DB]
GO

-- ===================== Historial de compras (pedidos confirmados por usuario) =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ListarPedidosConfirmadosPorUsuarioSP]
	@idUser int
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
	WHERE P.Estado = 'Confirmado' AND P.IdUser = @idUser
	ORDER BY P.FechaConfirmacion DESC
END
GO

-- ===================== ABM de MARCAS =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AgregarMarcaSP]
	@descripcion varchar(50)
AS
BEGIN
	INSERT INTO MARCAS (Descripcion) VALUES (@descripcion)
	SELECT SCOPE_IDENTITY()
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ModificarMarcaSP]
	@id int,
	@descripcion varchar(50)
AS
BEGIN
	UPDATE MARCAS SET Descripcion = @descripcion WHERE Id = @id
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EliminarMarcaSP]
	@id int
AS
BEGIN
	-- No se puede eliminar una marca que algun articulo todavia tiene asignada
	IF EXISTS (SELECT 1 FROM ARTICULOS WHERE IdMarca = @id)
	BEGIN
		SELECT CAST(0 AS BIT) AS Exito
		RETURN
	END

	DELETE FROM MARCAS WHERE Id = @id
	SELECT CAST(1 AS BIT) AS Exito
END
GO

-- ===================== ABM de CATEGORIAS =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AgregarCategoriaSP]
	@descripcion varchar(50)
AS
BEGIN
	INSERT INTO CATEGORIAS (Descripcion) VALUES (@descripcion)
	SELECT SCOPE_IDENTITY()
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ModificarCategoriaSP]
	@id int,
	@descripcion varchar(50)
AS
BEGIN
	UPDATE CATEGORIAS SET Descripcion = @descripcion WHERE Id = @id
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EliminarCategoriaSP]
	@id int
AS
BEGIN
	-- No se puede eliminar una categoria que algun articulo todavia tiene asignada
	IF EXISTS (SELECT 1 FROM ARTICULOS WHERE IdCategoria = @id)
	BEGIN
		SELECT CAST(0 AS BIT) AS Exito
		RETURN
	END

	DELETE FROM CATEGORIAS WHERE Id = @id
	SELECT CAST(1 AS BIT) AS Exito
END
GO

-- ===================== Telefono de WhatsApp (Ventas) =====================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CONFIGURACION_VENTAS](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TelefonoWhatsApp] [varchar](20) NULL,
 CONSTRAINT [PK_CONFIGURACION_VENTAS] PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Fila unica de configuracion. El resto del sistema siempre lee/actualiza esta unica fila.
INSERT INTO [dbo].[CONFIGURACION_VENTAS] (TelefonoWhatsApp) VALUES (NULL)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerTelefonoWhatsAppSP]
AS
BEGIN
	SELECT TOP 1 TelefonoWhatsApp FROM CONFIGURACION_VENTAS ORDER BY Id
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GuardarTelefonoWhatsAppSP]
	@telefono varchar(20)
AS
BEGIN
	UPDATE CONFIGURACION_VENTAS
	SET TelefonoWhatsApp = @telefono
	WHERE Id = (SELECT TOP 1 Id FROM CONFIGURACION_VENTAS ORDER BY Id)
END
GO
