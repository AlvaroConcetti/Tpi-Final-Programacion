using Consultas;
using Dominio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CatalogoWEB
{
    public partial class Favoritos : System.Web.UI.Page
    {
        ConsultasCatalogo consultasCatalogo = new ConsultasCatalogo();


        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que se vean favoritos sin login.
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                lblParrafo.Text = "Inicie sesion para que pueda ver sus favoritos.";
                return;
            }

            Usuario usuarioLogueado = (Usuario)Session["Usuario"];
            int idUsuarioLogueado = usuarioLogueado.Id;

            // Cargar la lista de favoritos.
            if (!IsPostBack)
            {
                List<Articulo> listaFavoritos = consultasCatalogo.ListarFavoritos(idUsuarioLogueado);
                Session.Add("ListaFavoritosEnSession", listaFavoritos);
                repRepetidorFavoritos.DataSource = listaFavoritos;
                repRepetidorFavoritos.DataBind();
            }
        }

        // Quitar de favoritos un articulo que esta dentro del repetidor.
        protected void repRepetidorFavoritos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "QuitarFavorito")
            {
                Usuario usuarioLogueado = (Usuario)Session["Usuario"];
                int idUsuarioLogueado = usuarioLogueado.Id;
                int idArticuloFavorito = int.Parse(e.CommandArgument.ToString());
                consultasCatalogo.EliminarFavorito(idUsuarioLogueado, idArticuloFavorito);

                repRepetidorFavoritos.DataSource = consultasCatalogo.ListarFavoritos(idUsuarioLogueado);
                repRepetidorFavoritos.DataBind();
            }
        }

        // Boton para redireccion al detalle del articulo.
        protected void btnDetalle_Click(object sender, EventArgs e)
        {
            int articuloId = int.Parse(((Button)sender).CommandArgument);

            List<Articulo> lista = (List<Articulo>)Session["ListaFavoritosEnSession"];

            if (lista != null)
            {
                Articulo seleccionado = lista.Find(x => x.Id == articuloId);
                Session.Add("ArticuloSeleccionado", seleccionado);
                Session.Add("Origen", "Favoritos.aspx");
                Response.Redirect("Detalle.aspx", false);
            }
            else
            {
                repRepetidorFavoritos.DataSource = consultasCatalogo.ListarArticulo();
                repRepetidorFavoritos.DataBind();
            }
        }

        // Redireccion al catalogo princiapal.
        protected void btnFavoritoVolver_Click(object sender, EventArgs e)
        {
            Response.Redirect("Default.aspx", false);
        }
    }
}