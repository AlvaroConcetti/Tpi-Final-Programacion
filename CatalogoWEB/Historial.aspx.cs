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
    // "Mis pedidos": todos los pedidos del cliente con su estado (Pendiente, Confirmado o Cancelado).
    public partial class Historial : System.Web.UI.Page
    {
        ConsultasVenta consultasVenta = new ConsultasVenta();

        // Telefono del comercio, para el link "Reenviar por WhatsApp" de los pedidos pendientes.
        private string telefonoWhatsApp;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que no permita ver los pedidos sin login.
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Response.Redirect("Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                CargarPedidos();
            }
        }

        private void CargarPedidos()
        {
            try
            {
                Usuario usuarioLogueado = (Usuario)Session["Usuario"];
                List<Pedido> pedidos = consultasVenta.ListarPedidosPorUsuario(usuarioLogueado.Id);

                foreach (Pedido pedido in pedidos)
                {
                    pedido.Detalle = consultasVenta.ListarDetallePedido(pedido.Id);
                }

                telefonoWhatsApp = consultasVenta.ObtenerTelefonoWhatsApp();

                repCompras.DataSource = pedidos;
                repCompras.DataBind();

                pnlVacio.Visible = pedidos.Count == 0;
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Clase de la etiqueta de estado (color) segun el estado del pedido.
        protected string ClaseEstado(object estado)
        {
            switch (estado as string)
            {
                case "Confirmado": return "estado estado--confirmado";
                case "Cancelado": return "estado estado--cancelado";
                default: return "estado estado--pendiente";
            }
        }

        // Texto que explica en que esta el pedido.
        protected string NotaEstado(object dataItem)
        {
            Pedido pedido = (Pedido)dataItem;
            switch (pedido.Estado)
            {
                case "Confirmado":
                    return pedido.FechaConfirmacion.HasValue
                        ? "El comercio confirmó la venta el " + pedido.FechaConfirmacion.Value.ToString("dd/MM/yyyy 'a las' HH:mm") + "."
                        : "El comercio confirmó la venta.";
                case "Cancelado":
                    return "El comercio canceló este pedido.";
                default:
                    return "Esperando que el comercio lo confirme. Si no llegaste a mandar el mensaje, podés reenviarlo.";
            }
        }

        // Link para reenviar por WhatsApp un pedido pendiente (vacio si no corresponde).
        protected string LinkReenviar(object dataItem)
        {
            Pedido pedido = (Pedido)dataItem;
            if (pedido.Estado != "Pendiente" || string.IsNullOrWhiteSpace(telefonoWhatsApp) || pedido.Detalle.Count == 0)
                return "";
            return WhatsApp.LinkPedido(telefonoWhatsApp, pedido.Id, pedido.Detalle);
        }

        // Boton de volver al catalogo.
        protected void btnHistorialVolver_Click(object sender, EventArgs e)
        {
            Response.Redirect("Default.aspx", false);
        }
    }
}
