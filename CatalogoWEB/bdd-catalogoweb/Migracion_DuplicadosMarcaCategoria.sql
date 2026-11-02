USE [CATALOGO_WEB_DB]
GO

-- Evita duplicados de Marca por Descripcion (alta). Devuelve Exito=0 si ya existia.
ALTER PROCEDURE [dbo].[AgregarMarcaSP]
    @descripcion varchar(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM MARCAS WHERE Descripcion = LTRIM(RTRIM(@descripcion)))
    BEGIN
        SELECT CAST(0 AS BIT) AS Exito, CAST(NULL AS INT) AS Id
    END
    ELSE
    BEGIN
        INSERT INTO MARCAS (Descripcion) VALUES (LTRIM(RTRIM(@descripcion)))
        SELECT CAST(1 AS BIT) AS Exito, CAST(SCOPE_IDENTITY() AS INT) AS Id
    END
END
GO

-- Mismo chequeo para la edicion, excluyendo la propia fila (si no, guardar sin
-- cambiar el texto siempre fallaria por matchear contra si misma).
ALTER PROCEDURE [dbo].[ModificarMarcaSP]
    @id int,
    @descripcion varchar(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM MARCAS WHERE Descripcion = LTRIM(RTRIM(@descripcion)) AND Id <> @id)
    BEGIN
        SELECT CAST(0 AS BIT) AS Exito
    END
    ELSE
    BEGIN
        UPDATE MARCAS SET Descripcion = LTRIM(RTRIM(@descripcion)) WHERE Id = @id
        SELECT CAST(1 AS BIT) AS Exito
    END
END
GO

-- Mismo mecanismo para Categoria.
ALTER PROCEDURE [dbo].[AgregarCategoriaSP]
    @descripcion varchar(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CATEGORIAS WHERE Descripcion = LTRIM(RTRIM(@descripcion)))
    BEGIN
        SELECT CAST(0 AS BIT) AS Exito, CAST(NULL AS INT) AS Id
    END
    ELSE
    BEGIN
        INSERT INTO CATEGORIAS (Descripcion) VALUES (LTRIM(RTRIM(@descripcion)))
        SELECT CAST(1 AS BIT) AS Exito, CAST(SCOPE_IDENTITY() AS INT) AS Id
    END
END
GO

ALTER PROCEDURE [dbo].[ModificarCategoriaSP]
    @id int,
    @descripcion varchar(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CATEGORIAS WHERE Descripcion = LTRIM(RTRIM(@descripcion)) AND Id <> @id)
    BEGIN
        SELECT CAST(0 AS BIT) AS Exito
    END
    ELSE
    BEGIN
        UPDATE CATEGORIAS SET Descripcion = LTRIM(RTRIM(@descripcion)) WHERE Id = @id
        SELECT CAST(1 AS BIT) AS Exito
    END
END
GO
