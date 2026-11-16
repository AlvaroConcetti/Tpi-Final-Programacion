/*
	Script incremental: pagina "Mi perfil" (editar nombre y apellido).
	Ejecutar contra CATALOGO_WEB_DB, despues de Seguridad_HashContrasenas.sql.
	(El cambio de contraseña usa ActualizarPassUsuarioSP, que se creo en ese script.)
*/

USE [CATALOGO_WEB_DB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ActualizarPerfilSP]
    @id int,
    @nombre varchar(50),
    @apellido varchar(50)
AS
BEGIN
    UPDATE USERS
    SET nombre = @nombre, apellido = @apellido
    WHERE Id = @id
END
GO
