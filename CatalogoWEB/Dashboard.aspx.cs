using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using Consultas;
using Dominio;

namespace CatalogoWEB
{
    // Esto lo hizo claude code ↓.
    public partial class Dashboard : System.Web.UI.Page
    {
        ConsultasDashboard consultasDashboard = new ConsultasDashboard();

        // Datos que consume el markup via <%= %> (KPIs y JSON para Chart.js)
        protected KpisDashboard Kpis { get; private set; }
        protected string VentasPorDiaJson { get; private set; }
        protected string CategoriasJson { get; private set; }
        protected string TopArticulosJson { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Seguridad.Admin(Session["Usuario"]) == false)
            {
                Session.Add("Error", "No tienes permisos para ingresar aqui.");
                Response.Redirect("Error.aspx", false);
                // Datos vacios para que el render de esta pagina no explote antes del redirect
                Kpis = new KpisDashboard();
                VentasPorDiaJson = "[]";
                CategoriasJson = "[]";
                TopArticulosJson = "[]";
                return;
            }

            CargarDatos();
        }

        protected void ddlRango_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarDatos();
        }

        private void CargarDatos()
        {
            try
            {
                int dias = int.Parse(ddlRango.SelectedValue);

                // El rango es [desde, hasta): desde la medianoche de hace N dias hasta manana
                DateTime hasta = DateTime.Today.AddDays(1);
                DateTime desde;

                if (dias > 0)
                {
                    desde = DateTime.Today.AddDays(-(dias - 1));
                }
                else
                {
                    // "Todo el historial": arranca en la primera venta registrada
                    DateTime? primera = consultasDashboard.FechaPrimeraVenta();
                    desde = primera.HasValue ? primera.Value.Date : DateTime.Today;
                }

                Kpis = consultasDashboard.ObtenerKpis(desde, hasta);

                List<VentaPorDia> ventasPorDia = RellenarDiasSinVentas(consultasDashboard.VentasPorDia(desde, hasta), desde, hasta);
                List<VentaPorCategoria> categorias = consultasDashboard.VentasPorCategoria(desde, hasta);
                List<ArticuloVendido> topArticulos = consultasDashboard.TopArticulosVendidos(desde, hasta, 5);

                JavaScriptSerializer serializer = new JavaScriptSerializer();
                VentasPorDiaJson = serializer.Serialize(ventasPorDia.Select(v => new
                {
                    Fecha = v.Fecha.ToString("dd/MM", CultureInfo.InvariantCulture),
                    Total = v.Total
                }).ToList());
                CategoriasJson = serializer.Serialize(categorias);
                TopArticulosJson = serializer.Serialize(topArticulos);

                List<Articulo> stockBajo = consultasDashboard.ArticulosStockBajo(5);
                repStockBajo.DataSource = stockBajo;
                repStockBajo.DataBind();
                lblSinStockBajo.Visible = stockBajo.Count == 0;

                List<FavoritoPopular> favoritos = consultasDashboard.TopFavoritos(5);
                repFavoritos.DataSource = favoritos;
                repFavoritos.DataBind();
                lblSinFavoritos.Visible = favoritos.Count == 0;
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
                Kpis = Kpis ?? new KpisDashboard();
                VentasPorDiaJson = VentasPorDiaJson ?? "[]";
                CategoriasJson = CategoriasJson ?? "[]";
                TopArticulosJson = TopArticulosJson ?? "[]";
            }
        }

        // Completa con $0 los dias del rango que no tuvieron ventas, para que el
        // grafico muestre el eje de tiempo continuo (los huecos son informacion).
        // Con rangos muy largos ("Todo el historial" viejo) no rellena para no
        // generar miles de barras.
        private List<VentaPorDia> RellenarDiasSinVentas(List<VentaPorDia> ventas, DateTime desde, DateTime hasta)
        {
            int totalDias = (int)(hasta.Date - desde.Date).TotalDays;
            if (totalDias <= 0 || totalDias > 120)
                return ventas;

            List<VentaPorDia> completa = new List<VentaPorDia>();
            for (DateTime dia = desde.Date; dia < hasta.Date; dia = dia.AddDays(1))
            {
                VentaPorDia venta = ventas.Find(v => v.Fecha.Date == dia);
                completa.Add(venta ?? new VentaPorDia { Fecha = dia, Total = 0 });
            }
            return completa;
        }
    }
}
