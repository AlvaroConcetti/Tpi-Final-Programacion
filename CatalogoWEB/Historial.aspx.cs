using Consultas;
using Dominio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CatalogoWEB
{
    public partial class Historial : System.Web.UI.Page
    {
        ConsultasVenta consultasVenta = new ConsultasVenta();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que no permita ver el historial de compras sin login.
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Session.Add("Error", "Debes estar logueado para ver tu historial de compras.");
                Response.Redirect("Error.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                CargarHistorial();
            }
        }

        // Mustra el historial.
        private void CargarHistorial()
        {
            try
            {
                Usuario usuarioLogueado = (Usuario)Session["Usuario"];
                List<Pedido> compras = consultasVenta.ListarComprasConfirmadas(usuarioLogueado.Id);

                foreach (Pedido pedido in compras)
                {
                    pedido.Detalle = consultasVenta.ListarDetallePedido(pedido.Id);
                }

                repCompras.DataSource = compras;
                repCompras.DataBind();

                pnlVacio.Visible = compras.Count == 0;
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Boton de redireccion para el carrito.
        protected void btnHistorialVolver_Click(object sender, EventArgs e)
        {
            Response.Redirect("Carrito.aspx", false);
        }
    }
}
