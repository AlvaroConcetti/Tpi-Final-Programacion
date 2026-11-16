using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Consultas;
using Dominio;

namespace CatalogoWEB
{
    public partial class AgregarArticulo : PaginaAdmin
    {
        ConsultasArticulo consultasArticulo = new ConsultasArticulo();
        ConsultasCatalogo consultasCatalogo = new ConsultasCatalogo();

        // True si se llego con ?Id= (editar); false si es un alta. Lo usa el markup para titulos y textos.
        protected bool EsEdicion
        {
            get { return Request.QueryString["Id"] != null; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtBoxId.Enabled = false;

            // TextBox multilinea no renderiza MaxLength como atributo: se agrega a mano para limitar en el navegador.
            txtBoxDescripcion.Attributes["maxlength"] = "150";

            if (!IsPostBack)
            {
                CargarDesplegables();

                // Si la redireccion trajo un parametro "Id" por URL, entra y precarga los campos para editarlos.
                if (EsEdicion)
                {
                    btnAceptar.Text = "Guardar cambios";

                    int idArticulo = int.Parse(Request.QueryString["id"]);
                    List<Articulo> articulos = consultasCatalogo.ListarArticulo();
                    Articulo articuloSeleccionado = articulos.Find(x => x.Id == idArticulo);

                    // Por si el articulo ya no existe (lo borraron o cambiaron el Id en la URL).
                    if (articuloSeleccionado == null)
                    {
                        Session.Add("Error", "El artículo que querés editar no existe.");
                        Response.Redirect("Error.aspx", false);
                        return;
                    }

                    txtBoxId.Text = articuloSeleccionado.Id.ToString();
                    // "0.##" (sin separador de miles): con cultura es-AR "N2" daba "1.500,00",
                    // que no pasa la validacion del precio (^\d+(,\d{1,2})?$) y no dejaba guardar.
                    txtBoxPrecio.Text = articuloSeleccionado.Precio.ToString("0.##");
                    txtBoxStock.Text = articuloSeleccionado.Stock.ToString();
                    txtBoxNombre.Text = articuloSeleccionado.Nombre;
                    txtBoxDescripcion.Text = articuloSeleccionado.Descripcion;
                    SeleccionarOpcion(ddlMarca, articuloSeleccionado.Marca);
                    SeleccionarOpcion(ddlCategoria, articuloSeleccionado.Categoria);
                    txtBoxCodigo.Text = articuloSeleccionado.Codigo;

                    if (!string.IsNullOrWhiteSpace(articuloSeleccionado.UrlImagen))
                    {
                        imgArticulo.ImageUrl = articuloSeleccionado.UrlImagen;
                    }
                }
            }
        }

        // Llena los desplegables con las marcas y categorias existentes (ordenadas) + una opcion vacia inicial.
        // El value es la descripcion porque AgregarArticuloSP/ModificarArticuloSP reciben la marca/categoria como texto.
        private void CargarDesplegables()
        {
            ddlMarca.Items.Clear();
            ddlMarca.Items.Add(new ListItem("Elegí una marca", ""));
            foreach (Marca marca in consultasCatalogo.ListarMarcas().OrderBy(m => m.Descripcion))
                ddlMarca.Items.Add(new ListItem(marca.Descripcion, marca.Descripcion));

            ddlCategoria.Items.Clear();
            ddlCategoria.Items.Add(new ListItem("Elegí una categoría", ""));
            foreach (Categoria categoria in consultasCatalogo.ListarCategorias().OrderBy(c => c.Descripcion))
                ddlCategoria.Items.Add(new ListItem(categoria.Descripcion, categoria.Descripcion));
        }

        // Selecciona la opcion con ese texto; si no existe en la lista (dato viejo), la agrega para no perderla.
        private void SeleccionarOpcion(DropDownList ddl, string valor)
        {
            if (string.IsNullOrWhiteSpace(valor))
                return;

            ListItem item = ddl.Items.FindByValue(valor);
            if (item == null)
            {
                item = new ListItem(valor, valor);
                ddl.Items.Add(item);
            }
            ddl.ClearSelection();
            item.Selected = true;
        }

        protected void btnAceptar_Click(object sender, EventArgs e)
        {
            try
            {
                //Validacion para los RequiredFieldValidator.
                Page.Validate();
                if (!Page.IsValid)
                    return;

                Articulo articuloNuevo = new Articulo();

                //Validacion en backend para el txtBox precio.
                try
                {
                    articuloNuevo.Precio = decimal.Parse(txtBoxPrecio.Text);
                }
                catch (Exception)
                {
                    Session.Add("Error", "El precio tiene un formato inválido.");
                    Response.Redirect("Error.aspx", false);
                    return;
                }

                //Validacion en backend para el txtBox stock.
                try
                {
                    articuloNuevo.Stock = int.Parse(txtBoxStock.Text);
                }
                catch (Exception)
                {
                    Session.Add("Error", "El stock tiene un formato inválido.");
                    Response.Redirect("Error.aspx", false);
                    return;
                }

                articuloNuevo.Nombre = txtBoxNombre.Text;
                articuloNuevo.Descripcion = txtBoxDescripcion.Text;
                articuloNuevo.Marca = ddlMarca.SelectedValue;
                articuloNuevo.Categoria = ddlCategoria.SelectedValue;
                articuloNuevo.Codigo = txtBoxCodigo.Text;

                Articulo articuloExistente = null;
                if (Request.QueryString["Id"] != null)
                {
                    int idArticulo = int.Parse(Request.QueryString["Id"]);
                    List<Articulo> articulos = consultasCatalogo.ListarArticulo();
                    articuloExistente = articulos.Find(x => x.Id == idArticulo);
                }
                if (txtImagen.PostedFile != null && txtImagen.PostedFile.ContentLength > 0)
                {
                    string errorImagen = ValidarImagen(txtImagen.PostedFile);
                    if (errorImagen != null)
                    {
                        Session.Add("Error", errorImagen);
                        Response.Redirect("Error.aspx", false);
                        return;
                    }

                    // El nombre del archivo se arma con el codigo del articulo. Le sacamos todo lo que
                    // no sea letra, numero, guion o guion bajo, para que no se pueda poner algo como
                    // "../../Web.config" y guardar el archivo fuera de la carpeta Images.
                    string codigoSeguro = Regex.Replace(txtBoxCodigo.Text, "[^A-Za-z0-9_-]", "");
                    if (codigoSeguro == "")
                        codigoSeguro = "sin-codigo";

                    string extension = System.IO.Path.GetExtension(txtImagen.PostedFile.FileName).ToLower();
                    string nombreArchivo = "articulo-" + codigoSeguro + extension;
                    txtImagen.PostedFile.SaveAs(System.IO.Path.Combine(Server.MapPath("~/Images/"), nombreArchivo));
                    articuloNuevo.UrlImagen = "Images/" + nombreArchivo;
                }
                else if (articuloExistente != null)
                {
                    // Editando no subieron nada nuevo -> conservar la que ya estaba.
                    articuloNuevo.UrlImagen = articuloExistente.UrlImagen;
                }
                else
                {
                    // Alta nueva sin imagen.
                    articuloNuevo.UrlImagen = string.Empty;
                }

                // Si se esta editando se llama al metodo modificar, sino al agregar.
                if (Request.QueryString["Id"] != null)
                {
                    articuloNuevo.Id = int.Parse(Request.QueryString["Id"]);
                    consultasArticulo.ModificarArticulo(articuloNuevo);
                }
                else
                {
                    consultasArticulo.AgregarArticulo(articuloNuevo);
                }

                RedirectAAdministracion();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Valida la imagen subida: solo JPG, PNG o WEBP y como maximo 2 MB.
        // Devuelve el mensaje de error, o null si esta todo bien.
        private string ValidarImagen(HttpPostedFile archivo)
        {
            string extension = System.IO.Path.GetExtension(archivo.FileName).ToLower();

            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png" && extension != ".webp")
                return "La imagen debe ser JPG, PNG o WEBP.";

            if (!archivo.ContentType.StartsWith("image/"))
                return "El archivo no es una imagen.";

            if (archivo.ContentLength > 2 * 1024 * 1024)
                return "La imagen no puede pesar más de 2 MB.";

            return null;
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            RedirectAAdministracion();
        }

        // Metodo privado para que si tengo que modificar el querystring lo hago aca y se modifica en los 2 (o mas en un futuro) lados que lo tengo.
        private void RedirectAAdministracion()
        {
            if (!string.IsNullOrEmpty(Request.QueryString["Buscar"]))
            {
                string filtro = Request.QueryString["Filtro"];
                string criterio = Request.QueryString["Criterio"];
                string buscar = Request.QueryString["Buscar"];

                Response.Redirect("Administracion.aspx?Filtro=" + Server.UrlEncode(filtro)
                    + "&Criterio=" + Server.UrlEncode(criterio)
                    + "&Buscar=" + Server.UrlEncode(buscar), false);
            }
            else
            {
                Response.Redirect("Administracion.aspx", false);
            }
        }
    }

}
