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
    public partial class Ventas : System.Web.UI.Page
    {
        ConsultasVenta consultasVenta = new ConsultasVenta();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que los usuarios no tengan permiso aca.
            if (Seguridad.Admin(Session["Usuario"]) == false)
            {
                Session.Add("Error", "No tienes permisos para ingresar aqui.");
                Response.Redirect("Error.aspx", false);
            }

            if (!IsPostBack)
            {
                txtBoxTelefono.Text = consultasVenta.ObtenerTelefonoWhatsApp();
                CargarPedidos();
            }
        }

        // Dispara la consulta para guardar/actualizar el numero de telefono.
        protected void btnGuardarTelefono_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid)
                return;

            try
            {
                consultasVenta.GuardarTelefonoWhatsApp(txtBoxTelefono.Text.Trim());
                lblMensajeTelefono.Text = "Teléfono actualizado.";
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Metodo de cargar los pedidos.
        private void CargarPedidos()
        {
            try
            {
                List<Pedido> pedidos = consultasVenta.ListarPedidosPendientes();

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

        // Boton para confirmar el pedido + verificacion del stock.
        protected void btnConfirmar_Click(object sender, EventArgs e)
        {
            try
            {
                int idPedido = int.Parse(((Button)sender).CommandArgument);
                string articuloSinStock = consultasVenta.ConfirmarVenta(idPedido);

                lblMensaje.Text = articuloSinStock != null
                    ? "No se pudo confirmar la venta: no hay stock suficiente de \"" + articuloSinStock + "\"."
                    : "";

                CargarPedidos();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Boton que dispara la consulta para cancelar el pedido.
        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            try
            {
                int idPedido = int.Parse(((Button)sender).CommandArgument);
                consultasVenta.CancelarPedido(idPedido);

                CargarPedidos();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Redireccion a pedidos cancelados.
        protected void btnPedidosCancelados_Click(object sender, EventArgs e)
        {
            Response.Redirect("PedidosCancelados.aspx", false);
        }
    }
}
