using System;
using System.Collections.Generic;
using Dominio;

namespace Consultas
{
    public class ConsultasCatalogo
    {
        // Arma un Articulo con la fila actual del lector.
        // Lo usan todos los metodos que traen articulos, asi no se repite el mismo codigo 4 veces.
        private Articulo LeerArticulo(AccesoDatos datos)
        {
            Articulo aux = new Articulo();
            aux.Id = (int)datos.Lector["Id"];
            aux.Codigo = (string)datos.Lector["Codigo"];
            aux.Nombre = (string)datos.Lector["Nombre"];
            aux.Descripcion = (string)datos.Lector["Descripcion"];
            aux.Precio = (decimal)datos.Lector["Precio"];
            aux.Stock = (int)datos.Lector["Stock"];
            aux.Marca = (string)datos.Lector["Marca"];
            aux.Categoria = (string)datos.Lector["Categoria"];

            if (!(datos.Lector["ImagenUrl"] is DBNull))
                aux.UrlImagen = (string)datos.Lector["ImagenUrl"];

            return aux;
        }

        public List<Articulo> ListarArticulo()
        {
            List<Articulo> lista = new List<Articulo>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ListarArticulosSP");
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                    lista.Add(LeerArticulo(datos));

                return lista;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<Articulo> FiltrarArticulo(string busqueda)
        {
            List<Articulo> lista = new List<Articulo>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("FiltrarArticulosSP");
                datos.setearParametro("@busqueda", busqueda);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                    lista.Add(LeerArticulo(datos));

                return lista;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<Articulo> FiltrarAvanzado(string campo, string criterio, string filtro)
        {
            List<Articulo> lista = new List<Articulo>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                string consulta = "SELECT A.Id, A.Codigo, A.Nombre, A.Descripcion, A.ImagenUrl, A.Precio, A.Stock, M.Descripcion AS Marca, C.Descripcion AS Categoria FROM ARTICULOS A INNER JOIN MARCAS M ON A.IdMarca = M.Id INNER JOIN CATEGORIAS C ON A.IdCategoria = C.Id WHERE ";

                switch (campo)
                {
                    case "Código":
                        consulta += "A.Codigo = @filtro";
                        datos.setearParametro("@filtro", filtro);
                        break;

                    case "Precio":
                        // Si escribieron algo que no es un numero devolvemos la lista vacia en vez de romper.
                        decimal precio;
                        if (!decimal.TryParse(filtro, out precio))
                            return lista;

                        string operador = criterio == ">" ? ">" : criterio == "<" ? "<" : "=";
                        consulta += "A.Precio " + operador + " @filtro";
                        datos.setearParametro("@filtro", precio);
                        break;

                    case "Marca":
                        consulta += "M.Descripcion LIKE @filtro";
                        datos.setearParametro("@filtro", "%" + filtro + "%");
                        break;

                    case "Categoría":
                        consulta += "C.Descripcion LIKE @filtro";
                        datos.setearParametro("@filtro", "%" + filtro + "%");
                        break;

                    default:
                        // Campo desconocido: sin esto la consulta quedaba terminada en "WHERE " y fallaba.
                        return lista;
                }

                datos.setearConsulta(consulta);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                    lista.Add(LeerArticulo(datos));

                return lista;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<Articulo> ListarFavoritos(int idUser)
        {
            List<Articulo> lista = new List<Articulo>();
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("ListarFavoritosSP");
                datos.setearParametro("@IdUser", idUser);
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                    lista.Add(LeerArticulo(datos));

                return lista;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public void EliminarFavorito(int idUser, int idArticulo)
        {
            AccesoDatos datos = new AccesoDatos();

            try
            {
                datos.setearProcedimiento("EliminarFavoritoSP");

                datos.setearParametro("@IdUser", idUser);
                datos.setearParametro("@IdArticulo", idArticulo);

                datos.ejecutarAccion();
            }

            finally
            {
                datos.cerrarConexion();
            }
        }

        public List<Marca> ListarMarcas()
        {
            List<Marca> lista = new List<Marca>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearConsulta("SELECT Id, Descripcion FROM MARCAS");
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    Marca aux = new Marca();
                    aux.Id = (int)datos.Lector["Id"];
                    aux.Descripcion = (string)datos.Lector["Descripcion"];
                    lista.Add(aux);
                }
                return lista;
            }

            finally { datos.cerrarConexion(); }
        }

        public List<Categoria> ListarCategorias()
        {
            List<Categoria> lista = new List<Categoria>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearConsulta("SELECT Id, Descripcion FROM CATEGORIAS");
                datos.ejecutarLectura();

                while (datos.Lector.Read())
                {
                    Categoria aux = new Categoria();
                    aux.Id = (int)datos.Lector["Id"];
                    aux.Descripcion = (string)datos.Lector["Descripcion"];
                    lista.Add(aux);
                }
                return lista;
            }

            finally { datos.cerrarConexion(); }
        }

        // Devuelve false si ya existia una marca con esa Descripcion (no la agrega de nuevo)
        public bool AgregarMarca(string descripcion)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("AgregarMarcaSP");
                datos.setearParametro("@descripcion", descripcion);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                    return (bool)datos.Lector["Exito"];

                return false;
            }

            finally { datos.cerrarConexion(); }
        }

        // Devuelve false si el nuevo nombre ya lo usa otra marca (no aplica el cambio)
        public bool ModificarMarca(int id, string descripcion)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("ModificarMarcaSP");
                datos.setearParametro("@id", id);
                datos.setearParametro("@descripcion", descripcion);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                    return (bool)datos.Lector["Exito"];

                return false;
            }

            finally { datos.cerrarConexion(); }
        }

        public bool EliminarMarca(int id)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("EliminarMarcaSP");
                datos.setearParametro("@id", id);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                    return (bool)datos.Lector["Exito"];

                return false;
            }

            finally { datos.cerrarConexion(); }
        }

        // Devuelve false si ya existia una categoria con esa Descripcion (no la agrega de nuevo)
        public bool AgregarCategoria(string descripcion)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("AgregarCategoriaSP");
                datos.setearParametro("@descripcion", descripcion);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                    return (bool)datos.Lector["Exito"];

                return false;
            }

            finally { datos.cerrarConexion(); }
        }

        // Devuelve false si el nuevo nombre ya lo usa otra categoria (no aplica el cambio)
        public bool ModificarCategoria(int id, string descripcion)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("ModificarCategoriaSP");
                datos.setearParametro("@id", id);
                datos.setearParametro("@descripcion", descripcion);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                    return (bool)datos.Lector["Exito"];

                return false;
            }

            finally { datos.cerrarConexion(); }
        }

        public bool EliminarCategoria(int id)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("EliminarCategoriaSP");
                datos.setearParametro("@id", id);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                    return (bool)datos.Lector["Exito"];

                return false;
            }

            finally { datos.cerrarConexion(); }
        }
    }

}
