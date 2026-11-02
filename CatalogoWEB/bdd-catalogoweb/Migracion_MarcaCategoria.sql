USE [CATALOGO_WEB_DB]
GO

-- AgregarArticuloSP ahora recibe @marca/@categoria como texto.
-- Busca la Marca/Categoria por Descripcion; si no existe, la crea y usa el Id nuevo.
ALTER PROCEDURE [dbo].[AgregarArticuloSP]
    @codigo varchar(50),
    @nombre varchar(50),
    @descripcion varchar(150),
    @marca varchar(50),
    @categoria varchar(50),
    @imagenUrl varchar(1000),
    @precio money,
    @stock int
AS
BEGIN
    DECLARE @idMarca int
    DECLARE @idCategoria int

    SELECT @idMarca = Id FROM MARCAS WHERE Descripcion = LTRIM(RTRIM(@marca))
    IF @idMarca IS NULL
    BEGIN
        INSERT INTO MARCAS (Descripcion) VALUES (LTRIM(RTRIM(@marca)))
        SET @idMarca = SCOPE_IDENTITY()
    END

    SELECT @idCategoria = Id FROM CATEGORIAS WHERE Descripcion = LTRIM(RTRIM(@categoria))
    IF @idCategoria IS NULL
    BEGIN
        INSERT INTO CATEGORIAS (Descripcion) VALUES (LTRIM(RTRIM(@categoria)))
        SET @idCategoria = SCOPE_IDENTITY()
    END

    INSERT INTO ARTICULOS (Codigo, Nombre, Descripcion, IdMarca, IdCategoria, ImagenUrl, Precio, Stock)
    VALUES (@codigo, @nombre, @descripcion, @idMarca, @idCategoria, @imagenUrl, @precio, @stock)

    SELECT SCOPE_IDENTITY()
END
GO

-- Mismo mecanismo de "buscar o crear" para la edicion de articulos.
ALTER PROCEDURE [dbo].[ModificarArticuloSP]
    @id int,
    @codigo varchar(50),
    @nombre varchar(50),
    @descripcion varchar(150),
    @marca varchar(50),
    @categoria varchar(50),
    @imagenUrl varchar(1000),
    @precio money,
    @stock int
AS
BEGIN
    DECLARE @idMarca int
    DECLARE @idCategoria int

    SELECT @idMarca = Id FROM MARCAS WHERE Descripcion = LTRIM(RTRIM(@marca))
    IF @idMarca IS NULL
    BEGIN
        INSERT INTO MARCAS (Descripcion) VALUES (LTRIM(RTRIM(@marca)))
        SET @idMarca = SCOPE_IDENTITY()
    END

    SELECT @idCategoria = Id FROM CATEGORIAS WHERE Descripcion = LTRIM(RTRIM(@categoria))
    IF @idCategoria IS NULL
    BEGIN
        INSERT INTO CATEGORIAS (Descripcion) VALUES (LTRIM(RTRIM(@categoria)))
        SET @idCategoria = SCOPE_IDENTITY()
    END

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
