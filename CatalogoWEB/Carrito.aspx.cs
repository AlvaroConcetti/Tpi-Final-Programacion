using Consultas;
using Dominio;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Caching;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CatalogoWEB
{
    public partial class Carrito : System.Web.UI.Page
	{
		ConsultasVenta consultasVenta = new ConsultasVenta();

		protected void Page_Load(object sender, EventArgs e)
		{
            // Barrera de seguridad para que no puedan entrar usuarios al panel administracion.
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                lblParrafo.Text = "Inicie sesion para que pueda ver su carrito.";
                return;
            }

            if (!IsPostBack)
			{
				CargarCarrito();
			}
		}

        // Bindea el carrito (List<ItemCarrito>) y actualiza el total
        private void CargarCarrito()
        {
            List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();

            repRepetidor.DataSource = carrito;
            repRepetidor.DataBind();

            decimal total = 0;
            foreach (ItemCarrito item in carrito)
            {
                total += item.Subtotal;
            }
            lblTotal.Text = "$" + total.ToString("N2");

            // Si el carrito esta vacio ocultamos el total y el boton de compra
            pnlFooter.Visible = carrito.Count > 0;

            if (carrito.Count == 0)
                lblParrafo.Text = "Tu carrito esta vacio.";
            else
                lblParrafo.Text = "";
        }

        // Boton de detalle que manda su origen para poder volver al carrito y que no vuelva a catalogo.
        protected void btnDetalle_Click(object sender, EventArgs e)
        {
            List<Articulo> buscarArticulos = (List<Articulo>)Session["ListaEnSession"];
            int articuloId = int.Parse(((Button)sender).CommandArgument);
            Articulo seleccionado = buscarArticulos.Find(x => x.Id == articuloId);

            Session.Add("ArticuloSeleccionado", seleccionado);
            Session.Add("Origen", "Carrito.aspx");
            Response.Redirect("Detalle.aspx", false);
        }

        // Redireccion para catalogo principal.
        protected void btnCarritoVolver_Click(object sender, EventArgs e)
        {
            Response.Redirect("Default.aspx", false);
        }

        // Redireccion para historial de pedidos.
        protected void btnVerHistorial_Click(object sender, EventArgs e)
        {
            Response.Redirect("Historial.aspx", false);
        }

        // Esto lo hizo claude code ↓.
        protected void btnMasCantidad_Click(object sender, EventArgs e)
        {
            try
            {
                int articuloId = int.Parse(((LinkButton)sender).CommandArgument);
                List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();
                bool agregado = false;

                ItemCarrito item = carrito.Find(x => x.Articulo.Id == articuloId);
                if (item != null && item.Cantidad < item.Articulo.Stock)
                {
                    item.Cantidad++;
                    agregado = true;
                }

                Session.Add("CarritoEnSession", carrito);
                CargarCarrito();

                if (agregado)
                    ScriptManager.RegisterStartupScript(this, GetType(), "ToastCarrito", "mostrarToast('Artículo agregado al carrito');", true);
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Al llegar a 0 saca el articulo del carrito directamente, sin confirmacion.
        protected void btnMenosCantidad_Click(object sender, EventArgs e)
        {
            try
            {
                int articuloId = int.Parse(((LinkButton)sender).CommandArgument);
                List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();

                ItemCarrito item = carrito.Find(x => x.Articulo.Id == articuloId);
                if (item != null)
                {
                    item.Cantidad--;
                    if (item.Cantidad <= 0)
                        carrito.Remove(item);
                }

                Session.Add("CarritoEnSession", carrito);
                CargarCarrito();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Boton de quitar articulo completo del carrito (se dispara cuando se acepta el modal).
        protected void btnQuitarDelCarrito_Click(object sender, EventArgs e)
        {
            int articuloId = int.Parse(hdnIdAQuitar.Value);
            List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito>;

            if (carrito == null) return;

            ItemCarrito seleccionado = carrito.Find(x => x.Articulo.Id == articuloId);
            if (seleccionado != null)
            {
                carrito.Remove(seleccionado);
            }

            Session.Add("CarritoEnSession", carrito);
            CargarCarrito();
        }

        // Esto lo hizo claude code ↓.
        // Crea el Pedido pendiente con su detalle, vacia el carrito y deriva a WhatsApp
        protected void btnIniciarCompra_Click(object sender, EventArgs e)
        {
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Session.Add("Error", "Debes estar logueado para continuar la compra.");
                Response.Redirect("Error.aspx", false);
                return;
            }

            try
            {
                List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();

                if (carrito.Count == 0)
                    return;

                string numeroWhatsApp = consultasVenta.ObtenerTelefonoWhatsApp();
                if (string.IsNullOrWhiteSpace(numeroWhatsApp))
                {
                    Session.Add("Error", "El comercio todavía no configuró su número de WhatsApp. Probá de nuevo más tarde.");
                    Response.Redirect("Error.aspx", false);
                    return;
                }

                Usuario usuarioLogueado = (Usuario)Session["Usuario"];
                int idPedido = consultasVenta.CrearPedido(usuarioLogueado.Id);

                StringBuilder mensaje = new StringBuilder();
                mensaje.AppendLine("Hola! Quiero confirmar mi pedido #" + idPedido + ":");

                decimal total = 0;
                foreach (ItemCarrito item in carrito)
                {
                    consultasVenta.AgregarDetallePedido(idPedido, item.Articulo.Id, item.Cantidad, item.Articulo.Precio);
                    mensaje.AppendLine("- " + item.Articulo.Nombre + " x" + item.Cantidad + " ($" + item.Subtotal.ToString("N2") + ")");
                    total += item.Subtotal;
                }
                mensaje.AppendLine("Total: $" + total.ToString("N2"));

                Session.Remove("CarritoEnSession");

                // Con esto derivamos el pedido a whatsapp.
                string urlWhatsApp = "https://wa.me/" + numeroWhatsApp + "?text=" + HttpUtility.UrlEncode(mensaje.ToString());
                Response.Redirect(urlWhatsApp, false);
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

    }
}