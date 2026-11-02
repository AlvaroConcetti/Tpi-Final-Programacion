using Dominio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CatalogoWEB
{
    public partial class Detalle : System.Web.UI.Page
    {
        public Articulo ArticuloSeleccionado { get; set; }
        protected void Page_Load(object sender, EventArgs e)
        {
            ArticuloSeleccionado = (Articulo)Session["ArticuloSeleccionado"];

            // Modifica el texto del boton segun corresponda.
            if ((string)Session["Origen"] == "Favoritos.aspx")
            {
                btnDetalleVolver.Text = "← Volver a favoritos";
            }
            else if((string)Session["Origen"] == "Carrito.aspx")
            {
                btnDetalleVolver.Text = "← Volver al carrito";
            }
            else
            {
                btnDetalleVolver.Text = "← Volver al catálogo";
            }
        }

        // Boton de volver inteligente, depende de donde venga la peticion de detalle, vuelve a la misma pagina. 
        protected void btnDetalleVolver_Click(object sender, EventArgs e)
        {
            if ((string)Session["Origen"] == "Favoritos.aspx")
            {
                Response.Redirect("Favoritos.aspx");
            }
            else if ((string)Session["Origen"] == "Carrito.aspx")
            {
                Response.Redirect("Carrito.aspx");
            }
            else
            {
                Response.Redirect("Default.aspx");
            }
        }
    }
}
