using System;
using System.Collections.Generic;
using Dominio;

namespace Consultas
{
    // Esto lo hizo claude code ↓
    public class KpisDashboard
    {
        public decimal TotalVentas { get; set; }
        public int CantidadVentas { get; set; }
        public int UnidadesVendidas { get; set; }
        public decimal TicketPromedio { get; set; }
        public int PedidosPendientes { get; set; }
        public int PedidosCancelados { get; set; }
    }

    public class VentaPorDia
    {
        public DateTime Fecha { get; set; }
        public decimal Total { get; set; }
    }

    public class ArticuloVendido
    {
        public string Nombre { get; set; }
        public int Unidades { get; set; }
        public decimal Total { get; set; }
    }

    public class VentaPorCategoria
    {
        public string Categoria { get; set; }
        public decimal Total { get; set; }
    }

    public class FavoritoPopular
    {
        public string Nombre { get; set; }
        public int Cantidad { get; set; }
    }

    public class ConsultasDashboard
    {
        public KpisDashboard ObtenerKpis(DateTime desde, DateTime hasta)
        {
            KpisDashboard kpis = new KpisDashboard();

            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearConsulta("SELECT ISNULL(SUM(D.Cantidad * D.PrecioUnitario), 0) AS Total, COUNT(DISTINCT P.Id) AS Pedidos, ISNULL(SUM(D.Cantidad), 0) AS Unidades FROM PEDIDOS P INNER JOIN DETALLE_PEDIDOS D ON D.IdPedido = P.Id WHERE P.Estado = 'Confirmado' AND P.FechaConfirmacion >= @desde AND P.FechaConfirmacion < @hasta");
                datos.setearParametro("@desde", desde);
                datos.setearParametro("@hasta", hasta);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                {
                    kpis.TotalVentas = (decimal)datos.Lector["Total"];
                    kpis.CantidadVentas = (int)datos.Lector["Pedidos"];
                    kpis.UnidadesVendidas = (int)datos.Lector["Unidades"];
                    kpis.TicketPromedio = kpis.CantidadVentas > 0 ? kpis.TotalVentas / kpis.CantidadVentas : 0;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datos.cerrarConexion();
            }

            AccesoDatos datosPendientes = new AccesoDatos();
            try
            {
                datosPendientes.setearConsulta("SELECT COUNT(*) AS Cant FROM PEDIDOS WHERE Estado = 'Pendiente'");
                datosPendientes.ejecutarLectura();
                if (datosPendientes.Lector.Read())
                    kpis.PedidosPendientes = (int)datosPendientes.Lector["Cant"];
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datosPendientes.cerrarConexion();
            }

            AccesoDatos datosCancelados = new AccesoDatos();
            try
            {
                datosCancelados.setearConsulta("SELECT COUNT(*) AS Cant FROM PEDIDOS WHERE Estado = 'Cancelado' AND FechaPedido >= @desde AND FechaPedido < @hasta");
                datosCancelados.setearParametro("@desde", desde);
                datosCancelados.setearParametro("@hasta", hasta);
                datosCancelados.ejecutarLectura();
                if (datosCancelados.Lector.Read())
                    kpis.PedidosCancelados = (int)datosCancelados.Lector["Cant"];
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datosCancelados.cerrarConexion();
            }

            return kpis;
        }

        public List<VentaPorDia> VentasPorDia(DateTime desde, DateTime hasta)
        {
            List<VentaPorDia> lista = new List<VentaPorDia>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearConsulta("SELECT CONVERT(date, P.FechaConfirmacion) AS Fecha, SUM(D.Cantidad * D.PrecioUnitario) AS Total FROM PEDIDOS P INNER JOIN DETALLE_PEDIDOS D ON D.IdPedido = P.Id WHERE P.Estado = 'Confirmado' AND P.FechaConfirmacion >= @desde AND P.FechaConfirmacion < @hasta GROUP BY CONVERT(date, P.FechaConfirmacion) ORDER BY Fecha");
                datos.setearParametro("@desde", desde);
                datos.setearParametro("@hasta", hasta);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    VentaPorDia aux = new VentaPorDia();
                    aux.Fecha = (DateTime)datos.Lector["Fecha"];
                    aux.Total = (decimal)datos.Lector["Total"];
                    lista.Add(aux);
                }

                return lista;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<ArticuloVendido> TopArticulosVendidos(DateTime desde, DateTime hasta, int cantidad)
        {
            List<ArticuloVendido> lista = new List<ArticuloVendido>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearConsulta("SELECT TOP (@top) A.Nombre, SUM(D.Cantidad) AS Unidades, SUM(D.Cantidad * D.PrecioUnitario) AS Total FROM PEDIDOS P INNER JOIN DETALLE_PEDIDOS D ON D.IdPedido = P.Id INNER JOIN ARTICULOS A ON A.Id = D.IdArticulo WHERE P.Estado = 'Confirmado' AND P.FechaConfirmacion >= @desde AND P.FechaConfirmacion < @hasta GROUP BY A.Nombre ORDER BY Total DESC");
                datos.setearParametro("@top", cantidad);
                datos.setearParametro("@desde", desde);
                datos.setearParametro("@hasta", hasta);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    ArticuloVendido aux = new ArticuloVendido();
                    aux.Nombre = (string)datos.Lector["Nombre"];
                    aux.Unidades = (int)datos.Lector["Unidades"];
                    aux.Total = (decimal)datos.Lector["Total"];
                    lista.Add(aux);
                }

                return lista;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<VentaPorCategoria> VentasPorCategoria(DateTime desde, DateTime hasta)
        {
            List<VentaPorCategoria> lista = new List<VentaPorCategoria>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearConsulta("SELECT C.Descripcion AS Categoria, SUM(D.Cantidad * D.PrecioUnitario) AS Total FROM PEDIDOS P INNER JOIN DETALLE_PEDIDOS D ON D.IdPedido = P.Id INNER JOIN ARTICULOS A ON A.Id = D.IdArticulo INNER JOIN CATEGORIAS C ON C.Id = A.IdCategoria WHERE P.Estado = 'Confirmado' AND P.FechaConfirmacion >= @desde AND P.FechaConfirmacion < @hasta GROUP BY C.Descripcion ORDER BY Total DESC");
                datos.setearParametro("@desde", desde);
                datos.setearParametro("@hasta", hasta);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    VentaPorCategoria aux = new VentaPorCategoria();
                    aux.Categoria = (string)datos.Lector["Categoria"];
                    aux.Total = (decimal)datos.Lector["Total"];
                    lista.Add(aux);
                }

                return lista;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<Articulo> ArticulosStockBajo(int umbral)
        {
            List<Articulo> lista = new List<Articulo>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearConsulta("SELECT Id, Codigo, Nombre, Stock FROM ARTICULOS WHERE Stock <= @umbral ORDER BY Stock ASC, Nombre");
                datos.setearParametro("@umbral", umbral);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    Articulo aux = new Articulo();
                    aux.Id = (int)datos.Lector["Id"];
                    aux.Codigo = (string)datos.Lector["Codigo"];
                    aux.Nombre = (string)datos.Lector["Nombre"];
                    aux.Stock = (int)datos.Lector["Stock"];
                    lista.Add(aux);
                }

                return lista;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<FavoritoPopular> TopFavoritos(int cantidad)
        {
            List<FavoritoPopular> lista = new List<FavoritoPopular>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearConsulta("SELECT TOP (@top) A.Nombre, COUNT(*) AS Cantidad FROM FAVORITOS F INNER JOIN ARTICULOS A ON A.Id = F.IdArticulo GROUP BY A.Nombre ORDER BY Cantidad DESC");
                datos.setearParametro("@top", cantidad);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    FavoritoPopular aux = new FavoritoPopular();
                    aux.Nombre = (string)datos.Lector["Nombre"];
                    aux.Cantidad = (int)datos.Lector["Cantidad"];
                    lista.Add(aux);
                }

                return lista;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public DateTime? FechaPrimeraVenta()
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearConsulta("SELECT MIN(FechaConfirmacion) AS Primera FROM PEDIDOS WHERE Estado = 'Confirmado'");
                datos.ejecutarLectura();

                if (datos.Lector.Read() && !(datos.Lector["Primera"] is DBNull))
                    return (DateTime)datos.Lector["Primera"];

                return null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
