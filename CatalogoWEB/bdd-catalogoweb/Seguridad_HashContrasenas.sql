/*
	Script incremental: contraseñas hasheadas (PBKDF2).
	Ejecutar contra CATALOGO_WEB_DB, despues de PedidosCancelados.sql.

	- Agranda USERS.pass para que entre el hash (antes varchar(20)).
	- RegistrarUsuarioSP acepta el hash.
	- ObtenerUsuarioPorEmailSP: el login ahora trae el usuario por email y la
	  contraseña se verifica en C# (HashContrasena.Verificar).
	- ActualizarPassUsuarioSP: los usuarios viejos con contraseña en texto plano
	  se migran solos al hash la proxima vez que inician sesion.
*/

USE [CATALOGO_WEB_DB]
GO

ALTER TABLE [dbo].[USERS] ALTER COLUMN [pass] varchar(200) NOT NULL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[RegistrarUsuarioSP]
    @email varchar(100),
    @pass varchar(200)
AS
BEGIN
    INSERT INTO USERS (email, pass, admin)
    VALUES (@email, @pass, 0)

    SELECT SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE [dbo].[ObtenerUsuarioPorEmailSP]
    @email varchar(100)
AS
BEGIN
    SELECT id, email, pass, nombre, apellido, admin
    FROM USERS
    WHERE email = @email
END
GO

CREATE PROCEDURE [dbo].[ActualizarPassUsuarioSP]
    @id int,
    @pass varchar(200)
AS
BEGIN
    UPDATE USERS SET pass = @pass WHERE Id = @id
END
GO

-- El SP viejo comparaba la contraseña en texto plano; ya no se usa.
DROP PROCEDURE [dbo].[LoginUsuarioSP]
GO
