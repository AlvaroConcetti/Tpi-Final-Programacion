/*
	Script incremental: gestion de pedidos cancelados (listar, reactivar, borrar definitivo).
	Ejecutar contra CATALOGO_WEB_DB, despues de HistorialCategoriasTelefono.sql.
*/

USE [CATALOGO_WEB_DB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ListarPedidosCanceladosSP]
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
	WHERE P.Estado = 'Cancelado'
	ORDER BY P.FechaPedido DESC
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReactivarPedidoSP]
	@idPedido int
AS
BEGIN
	-- Solo reactiva pedidos cancelados; vuelve a aparecer como pendiente en Ventas
	UPDATE PEDIDOS
	SET Estado = 'Pendiente'
	WHERE Id = @idPedido AND Estado = 'Cancelado'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EliminarPedidoDefinitivoSP]
	@idPedido int
AS
BEGIN
	-- Solo permite borrar definitivamente pedidos que ya estan cancelados
	-- (el IF evita dejar DETALLE_PEDIDOS huerfano si el pedido no calificaba)
	IF EXISTS (SELECT 1 FROM PEDIDOS WHERE Id = @idPedido AND Estado = 'Cancelado')
	BEGIN
		DELETE FROM DETALLE_PEDIDOS WHERE IdPedido = @idPedido
		DELETE FROM PEDIDOS WHERE Id = @idPedido
	END
END
GO
