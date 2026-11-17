-- =====================================================================
-- Mis pedidos
-- Ejecutar DESPUES de Bajas_Logicas.sql. Se puede ejecutar mas de una vez.
--
-- Antes el cliente solo veia sus compras confirmadas: despues de mandar el
-- pedido por WhatsApp no lo encontraba en ningun lado hasta que el comercio
-- lo confirmaba. Este procedimiento trae todos sus pedidos, con su estado
-- (Pendiente, Confirmado o Cancelado), del mas nuevo al mas viejo.
-- =====================================================================
USE CATALOGO_WEB_DB
GO

IF OBJECT_ID('ListarPedidosPorUsuarioSP', 'P') IS NULL
	EXEC('CREATE PROCEDURE ListarPedidosPorUsuarioSP AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[ListarPedidosPorUsuarioSP]
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
	WHERE P.IdUser = @idUser
	ORDER BY P.FechaPedido DESC
END
GO
