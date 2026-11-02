using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.WebSockets;
using Consultas;
using Dominio;
using static System.Net.WebRequestMethods;

namespace CatalogoWEB
{
    public partial class AgregarArticulo : System.Web.UI.Page
    {
        ConsultasArticulo consultasArticulo = new ConsultasArticulo();
        ConsultasCatalogo consultasCatalogo = new ConsultasCatalogo();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que no puedan entrar usuarios al panel administracion.
            if (Seguridad.Admin(Session["Usuario"]) == false)
            {
                Session.Add("Error", "No tienes permisos para ingresar aqui.");
                Response.Redirect("Error.aspx", false);
            }

            txtBoxId.Enabled = false;

            if (!IsPostBack)
            {
                // Si la redireccion trajo un parametro "Id" por URL, entra y precarga los campos para editarlos.
                if (Request.QueryString["Id"] != null)
                {
                    btnAceptar.Text = "Editar";

                    int idArticulo = int.Parse(Request.QueryString["id"]);
                    List<Articulo> articulos = consultasCatalogo.ListarArticulo();
                    Articulo articuloSeleccionado = articulos.Find(x => x.Id == idArticulo);

                    txtBoxId.Text = articuloSeleccionado.Id.ToString();
                    txtBoxPrecio.Text = articuloSeleccionado.Precio.ToString("N2");
                    txtBoxStock.Text = articuloSeleccionado.Stock.ToString();
                    txtBoxNombre.Text = articuloSeleccionado.Nombre;
                    txtBoxDescripcion.Text = articuloSeleccionado.Descripcion;
                    txtBoxMarca.Text = articuloSeleccionado.Marca;
                    txtBoxCategoria.Text = articuloSeleccionado.Categoria;
                    txtBoxCodigo.Text = articuloSeleccionado.Codigo;
                    
                    if (!string.IsNullOrWhiteSpace(articuloSeleccionado.UrlImagen))
                    {
                        imgArticulo.ImageUrl = articuloSeleccionado.UrlImagen;
                    }
                    else
                    {
                        imgArticulo.ImageUrl = "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png";
                    }
                }
            }
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
                articuloNuevo.Marca = txtBoxMarca.Text;
                articuloNuevo.Categoria = txtBoxCategoria.Text;
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
                    string ruta = Server.MapPath("./Images/");
                    string nombreArchivo = "articulo-" + txtBoxCodigo.Text + ".jpg";
                    txtImagen.PostedFile.SaveAs(ruta + nombreArchivo);
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
