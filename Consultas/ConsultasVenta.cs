using Consultas;
using Dominio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Consultas
{
    public class ConsultasVenta
    {
        // Esto lo hizo claude code ↓.
        public int CrearPedido(int idUser)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("CrearPedidoSP");
                datos.setearParametro("@idUser", idUser);

                return datos.ejecutarAccionScalar();
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

        public void AgregarDetallePedido(int idPedido, int idArticulo, int cantidad, decimal precioUnitario)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("AgregarDetallePedidoSP");
                datos.setearParametro("@idPedido", idPedido);
                datos.setearParametro("@idArticulo", idArticulo);
                datos.setearParametro("@cantidad", cantidad);
                datos.setearParametro("@precioUnitario", precioUnitario);

                datos.ejecutarAccion();
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

        public List<Pedido> ListarPedidosPendientes()
        {
            List<Pedido> lista = new List<Pedido>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ListarPedidosPendientesSP");
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    Pedido aux = new Pedido();
                    aux.Id = (int)datos.Lector["Id"];
                    aux.IdUser = (int)datos.Lector["IdUser"];
                    aux.EmailUsuario = (string)datos.Lector["EmailUsuario"];
                    aux.Estado = (string)datos.Lector["Estado"];
                    aux.FechaPedido = (DateTime)datos.Lector["FechaPedido"];

                    if (!(datos.Lector["FechaConfirmacion"] is DBNull))
                        aux.FechaConfirmacion = (DateTime)datos.Lector["FechaConfirmacion"];

                    aux.Detalle = new List<DetallePedido>();

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

        public List<DetallePedido> ListarDetallePedido(int idPedido)
        {
            List<DetallePedido> lista = new List<DetallePedido>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ListarDetallePedidoSP");
                datos.setearParametro("@idPedido", idPedido);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    DetallePedido aux = new DetallePedido();
                    aux.Id = (int)datos.Lector["Id"];
                    aux.IdPedido = (int)datos.Lector["IdPedido"];
                    aux.Cantidad = (int)datos.Lector["Cantidad"];
                    aux.PrecioUnitario = (decimal)datos.Lector["PrecioUnitario"];

                    aux.Articulo = new Articulo();
                    aux.Articulo.Id = (int)datos.Lector["IdArticulo"];
                    aux.Articulo.Codigo = (string)datos.Lector["Codigo"];
                    aux.Articulo.Nombre = (string)datos.Lector["Nombre"];
                    aux.Articulo.Descripcion = (string)datos.Lector["Descripcion"];
                    aux.Articulo.Stock = (int)datos.Lector["Stock"];

                    if (!(datos.Lector["ImagenUrl"] is DBNull))
                        aux.Articulo.UrlImagen = (string)datos.Lector["ImagenUrl"];

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

        public string ConfirmarVenta(int idPedido)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ConfirmarVentaSP");
                datos.setearParametro("@idPedido", idPedido);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                {
                    bool exito = (bool)datos.Lector["Exito"];
                    if (!exito)
                        return (string)datos.Lector["ArticuloSinStock"];
                }

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

        public void CancelarPedido(int idPedido)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("CancelarPedidoSP");
                datos.setearParametro("@idPedido", idPedido);
                datos.ejecutarAccion();
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

        public List<Pedido> ListarComprasConfirmadas(int idUser)
        {
            List<Pedido> lista = new List<Pedido>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ListarPedidosConfirmadosPorUsuarioSP");
                datos.setearParametro("@idUser", idUser);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    Pedido aux = new Pedido();
                    aux.Id = (int)datos.Lector["Id"];
                    aux.IdUser = (int)datos.Lector["IdUser"];
                    aux.EmailUsuario = (string)datos.Lector["EmailUsuario"];
                    aux.Estado = (string)datos.Lector["Estado"];
                    aux.FechaPedido = (DateTime)datos.Lector["FechaPedido"];

                    if (!(datos.Lector["FechaConfirmacion"] is DBNull))
                        aux.FechaConfirmacion = (DateTime)datos.Lector["FechaConfirmacion"];

                    aux.Detalle = new List<DetallePedido>();

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

        public List<Pedido> ListarPedidosCancelados()
        {
            List<Pedido> lista = new List<Pedido>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ListarPedidosCanceladosSP");
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    Pedido aux = new Pedido();
                    aux.Id = (int)datos.Lector["Id"];
                    aux.IdUser = (int)datos.Lector["IdUser"];
                    aux.EmailUsuario = (string)datos.Lector["EmailUsuario"];
                    aux.Estado = (string)datos.Lector["Estado"];
                    aux.FechaPedido = (DateTime)datos.Lector["FechaPedido"];

                    if (!(datos.Lector["FechaConfirmacion"] is DBNull))
                        aux.FechaConfirmacion = (DateTime)datos.Lector["FechaConfirmacion"];

                    aux.Detalle = new List<DetallePedido>();

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

        public void ReactivarPedido(int idPedido)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ReactivarPedidoSP");
                datos.setearParametro("@idPedido", idPedido);
                datos.ejecutarAccion();
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

        public void EliminarPedidoDefinitivo(int idPedido)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("EliminarPedidoDefinitivoSP");
                datos.setearParametro("@idPedido", idPedido);
                datos.ejecutarAccion();
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

        public string ObtenerTelefonoWhatsApp()
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ObtenerTelefonoWhatsAppSP");
                datos.ejecutarLectura();

                if (datos.Lector.Read() && !(datos.Lector["TelefonoWhatsApp"] is DBNull))
                    return (string)datos.Lector["TelefonoWhatsApp"];

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

        public void GuardarTelefonoWhatsApp(string telefono)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("GuardarTelefonoWhatsAppSP");
                datos.setearParametro("@telefono", telefono);
                datos.ejecutarAccion();
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
