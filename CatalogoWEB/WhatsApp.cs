using System;
using System.Collections.Generic;
using System.Text;
using Dominio;

namespace CatalogoWEB
{
    // Arma los links a WhatsApp (wa.me) con el mensaje ya escrito.
    // Se usa desde el carrito (al hacer el pedido), desde Mis pedidos (reenviar un pedido pendiente)
    // y desde el detalle de un articulo (consultar), asi el formato del mensaje esta en un solo lugar.
    public static class WhatsApp
    {
        // Mensaje del pedido: una linea por articulo y el total.
        public static string LinkPedido(string telefono, int idPedido, IEnumerable<DetallePedido> lineas)
        {
            StringBuilder mensaje = new StringBuilder();
            mensaje.AppendLine("Hola! Quiero confirmar mi pedido #" + idPedido + ":");

            decimal total = 0;
            foreach (DetallePedido linea in lineas)
            {
                mensaje.AppendLine("- " + linea.Articulo.Nombre + " x" + linea.Cantidad + " ($" + linea.Subtotal.ToString("N2") + ")");
                total += linea.Subtotal;
            }
            mensaje.AppendLine("Total: $" + total.ToString("N2"));

            return Link(telefono, mensaje.ToString());
        }

        // Consulta por un articulo desde su detalle (no hace falta tener cuenta).
        public static string LinkConsulta(string telefono, Articulo articulo)
        {
            string texto = "Hola! Quería consultar por " + articulo.Nombre;
            if (!string.IsNullOrWhiteSpace(articulo.Codigo))
                texto += " (código " + articulo.Codigo + ")";
            return Link(telefono, texto + ".");
        }

        // EscapeDataString codifica los espacios como %20, que wa.me interpreta siempre bien.
        public static string Link(string telefono, string texto)
        {
            return "https://wa.me/" + telefono + "?text=" + Uri.EscapeDataString(texto);
        }
    }
}
