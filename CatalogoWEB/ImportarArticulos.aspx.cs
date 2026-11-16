using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Consultas;
using Dominio;

namespace CatalogoWEB
{
    public partial class ImportarArticulos : PaginaAdmin
    {
        ConsultasArticulo consultasArticulo = new ConsultasArticulo();
        ConsultasCatalogo consultasCatalogo = new ConsultasCatalogo();

        // Una fila del CSV que no se pudo cargar, para mostrarla en la tabla de resultado.
        public class ErrorImportacion
        {
            public int Fila { get; set; }
            public string Codigo { get; set; }
            public string Motivo { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnImportar_Click(object sender, EventArgs e)
        {
            try
            {
                lblMensaje.Text = "";
                pnlResultado.Visible = false;

                if (!fuArchivoCsv.HasFile)
                {
                    lblMensaje.Text = "Seleccioná un archivo CSV.";
                    return;
                }

                if (Path.GetExtension(fuArchivoCsv.FileName).ToLower() != ".csv")
                {
                    lblMensaje.Text = "El archivo tiene que ser .csv";
                    return;
                }

                string[] lineas = LeerLineas(fuArchivoCsv.FileBytes);

                if (lineas.Length < 2)
                {
                    lblMensaje.Text = "El archivo está vacío o solo tiene el encabezado.";
                    return;
                }

                // Excel en español separa con ";" pero otros programas usan ",". Lo detectamos con el encabezado.
                char separador = lineas[0].Contains(";") ? ';' : ',';

                // Codigos que ya estan cargados, para no repetirlos (y los que vamos agregando del mismo archivo).
                List<string> codigosUsados = new List<string>();
                foreach (Articulo articulo in consultasCatalogo.ListarArticulo())
                    codigosUsados.Add(articulo.Codigo.ToUpper());

                List<ErrorImportacion> errores = new List<ErrorImportacion>();
                int agregados = 0;

                // Arrancamos en 1 para saltear el encabezado.
                for (int i = 1; i < lineas.Length; i++)
                {
                    if (string.IsNullOrWhiteSpace(lineas[i]))
                        continue;

                    int numeroFila = i + 1; // como lo ve el usuario en Excel
                    string[] columnas = lineas[i].Split(separador);
                    string codigo = columnas[0].Trim();

                    Articulo nuevo;
                    string error = ValidarFila(columnas, out nuevo);

                    if (error == null && codigosUsados.Contains(codigo.ToUpper()))
                        error = "Ya existe un artículo con ese código.";

                    if (error != null)
                    {
                        errores.Add(new ErrorImportacion { Fila = numeroFila, Codigo = codigo, Motivo = error });
                        continue;
                    }

                    try
                    {
                        consultasArticulo.AgregarArticulo(nuevo);
                        codigosUsados.Add(codigo.ToUpper());
                        agregados++;
                    }
                    catch (Exception)
                    {
                        errores.Add(new ErrorImportacion { Fila = numeroFila, Codigo = codigo, Motivo = "No se pudo guardar en la base de datos." });
                    }
                }

                lblAgregados.Text = agregados.ToString();
                lblConError.Text = errores.Count.ToString();
                dgvErrores.DataSource = errores;
                dgvErrores.DataBind();
                dgvErrores.Visible = errores.Count > 0;
                pnlResultado.Visible = true;
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Revisa una fila y arma el articulo. Devuelve el mensaje de error, o null si esta bien.
        private string ValidarFila(string[] columnas, out Articulo articulo)
        {
            articulo = null;

            if (columnas.Length != 7)
                return "Tiene " + columnas.Length + " columnas y tienen que ser 7.";

            string codigo = columnas[0].Trim();
            string nombre = columnas[1].Trim();
            string descripcion = columnas[2].Trim();
            string marca = columnas[3].Trim();
            string categoria = columnas[4].Trim();
            string textoPrecio = columnas[5].Trim();
            string textoStock = columnas[6].Trim();

            if (codigo == "" || nombre == "" || marca == "" || categoria == "")
                return "Faltan datos obligatorios (código, nombre, marca o categoría).";

            if (codigo.Length > 50 || nombre.Length > 50 || marca.Length > 50 || categoria.Length > 50)
                return "El código, nombre, marca y categoría pueden tener hasta 50 caracteres.";

            if (descripcion.Length > 150)
                return "La descripción puede tener hasta 150 caracteres.";

            // Si escribieron el precio con punto (ej: 120.50) lo pasamos a coma, que es como lo entiende es-AR.
            if (textoPrecio.Contains(".") && !textoPrecio.Contains(","))
                textoPrecio = textoPrecio.Replace(".", ",");

            decimal precio;
            if (!decimal.TryParse(textoPrecio, out precio) || precio < 0)
                return "El precio \"" + columnas[5].Trim() + "\" no es válido.";

            int stock;
            if (!int.TryParse(textoStock, out stock) || stock < 0)
                return "El stock \"" + textoStock + "\" no es válido.";

            articulo = new Articulo();
            articulo.Codigo = codigo;
            articulo.Nombre = nombre;
            articulo.Descripcion = descripcion;
            articulo.Marca = marca;
            articulo.Categoria = categoria;
            articulo.Precio = precio;
            articulo.Stock = stock;
            articulo.UrlImagen = "";
            return null;
        }

        // Excel puede guardar el CSV en UTF-8 o en el formato viejo de Windows (Windows-1252).
        // Probamos primero UTF-8 y, si tiene caracteres invalidos, lo leemos como Windows-1252,
        // asi no se rompen los acentos ni las ñ.
        private string[] LeerLineas(byte[] contenido)
        {
            string texto;
            try
            {
                texto = new UTF8Encoding(false, true).GetString(contenido);
            }
            catch (DecoderFallbackException)
            {
                texto = Encoding.GetEncoding(1252).GetString(contenido);
            }

            texto = texto.TrimStart('﻿'); // por si viene con BOM
            return texto.Replace("\r\n", "\n").Split('\n');
        }

        protected void btnVolverAdmin_Click(object sender, EventArgs e)
        {
            Response.Redirect("Administracion.aspx", false);
        }
    }
}
