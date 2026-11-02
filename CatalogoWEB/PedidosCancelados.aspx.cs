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
    public partial class PedidosCancelados : System.Web.UI.Page
    {
        ConsultasVenta consultasVenta = new ConsultasVenta();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que un usuario sin permisos no ingrese.
            if (Seguridad.Admin(Session["Usuario"]) == false)
            {
                Session.Add("Error", "No tienes permisos para ingresar aqui.");
                Response.Redirect("Error.aspx", false);
            }

            if (!IsPostBack)
            {
                CargarPedidos();
            }
        }

        // Carga los pedidos en el repetidor.
        private void CargarPedidos()
        {
            try
            {
                List<Pedido> pedidos = consultasVenta.ListarPedidosCancelados();

                foreach (Pedido pedido in pedidos)
                {
                    pedido.Detalle = consultasVenta.ListarDetallePedido(pedido.Id);
                }

                repPedidos.DataSource = pedidos;
                repPedidos.DataBind();

                pnlVacio.Visible = pedidos.Count == 0;
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Redireccion a ventas.
        protected void btnVolverVentas_Click(object sender, EventArgs e)
        {
            Response.Redirect("Ventas.aspx", false);
        }

        // Reactivamos el pedido.
        protected void btnReactivar_Click(object sender, EventArgs e)
        {
            try
            {
                int idPedido = int.Parse(((Button)sender).CommandArgument);
                consultasVenta.ReactivarPedido(idPedido);

                CargarPedidos();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Borramos el pedido definitivamente.
        protected void btnEliminarDefinitivo_Click(object sender, EventArgs e)
        {
            try
            {
                int idPedido = int.Parse(((Button)sender).CommandArgument);
                consultasVenta.EliminarPedidoDefinitivo(idPedido);

                CargarPedidos();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }
    }
}
