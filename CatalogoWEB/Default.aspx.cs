using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Dominio;
using Consultas;
using System.Web.DynamicData;

namespace CatalogoWEB
{
    public partial class Default : System.Web.UI.Page
    {
        ConsultasCatalogo catalogo = new ConsultasCatalogo();

        // Esto lo hizo claude code ↓.
        private List<int> _idsFavoritos = new List<int>();

        // Esto lo hizo claude code ↓.
        protected bool EsFavorito(int articuloId)
        {
            return _idsFavoritos.Contains(articuloId);
        }

        // Esto lo hizo claude code ↓.
        private void CargarFavoritos()
        {
            if (Seguridad.SesionActiva(Session["Usuario"]))
            {
                Usuario u = (Usuario)Session["Usuario"];
                _idsFavoritos = catalogo.ListarFavoritos(u.Id)
                                        .Select(a => a.Id)
                                        .ToList();
            }
        }

        // Devuelve cuantas unidades de un articulo hay en el carrito (0 si no esta).
        protected int CantidadEnCarrito(int articuloId)
        {
            List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();
            ItemCarrito item = carrito.Find(x => x.Articulo.Id == articuloId);
            return item != null ? item.Cantidad : 0;
        }

        // Esto lo hizo claude code ↓.
        // Vuelve a bindear el catalogo respetando el filtro de busqueda aplicado (si hay), para que carrito/favoritos no lo pisen con la lista completa.
        private void RecargarCatalogo()
        {
            string filtroAplicado = Session["FiltroCatalogo"] as string;
            List<Articulo> lista;

            if (!string.IsNullOrEmpty(filtroAplicado))
                lista = catalogo.FiltrarArticulo(filtroAplicado);
            else
                lista = Session["ListaEnSession"] as List<Articulo> ?? catalogo.ListarArticulo();

            repRepetidor.DataSource = lista;
            repRepetidor.DataBind();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            CargarFavoritos();

            if (!IsPostBack)
            {
                // Entrada nueva a la pagina: no arrastrar la busqueda de una visita anterior.
                Session.Remove("FiltroCatalogo");

                // Carga la lista de articulos y los guarda en sesion.
                List<Articulo> listaOriginal = catalogo.ListarArticulo();
                Session.Add("ListaEnSession", listaOriginal);
                repRepetidor.DataSource = listaOriginal;
                repRepetidor.DataBind();

                CargarFiltros(listaOriginal);
            }
        }

        // Esto lo hizo claude code ↓.
        // Arma el arbol de filtros (categoria -> marcas) a partir de los articulos ya cargados, no de las tablas MARCAS/CATEGORIAS (para no mostrar filtros sin productos detras).
        private void CargarFiltros(List<Articulo> articulos)
        {
            List<FiltroCategoria> filtros = articulos
                .Where(a => !string.IsNullOrWhiteSpace(a.Categoria))
                .GroupBy(a => a.Categoria)
                .OrderBy(g => g.Key)
                .Select(g => new FiltroCategoria
                {
                    Nombre = g.Key,
                    Marcas = g.Where(a => !string.IsNullOrWhiteSpace(a.Marca))
                              .Select(a => a.Marca)
                              .Distinct()
                              .OrderBy(m => m)
                              .Select(m => new FiltroMarca { Categoria = g.Key, Nombre = m })
                              .ToList()
                })
                .ToList();

            repFiltros.DataSource = filtros;
            repFiltros.DataBind();
        }

        // Esto lo hizo claude code ↓.
        // Protected (no private): el markup del .aspx compila en una clase que hereda de esta, asi que necesita acceso a estos tipos para el Container.DataItem del PlaceHolder.
        protected class FiltroCategoria
        {
            public string Nombre { get; set; }
            public List<FiltroMarca> Marcas { get; set; }
        }

        // Esto lo hizo claude code ↓.
        protected class FiltroMarca
        {
            public string Categoria { get; set; }
            public string Nombre { get; set; }
        }

        // El filtro aplicado queda en Session para que sobreviva a los rebinds de carrito/favoritos.
        protected void btnBuscarFiltro_Click(object sender, EventArgs e)
        {
            Session["FiltroCatalogo"] = txtBoxFiltro.Text;
            RecargarCatalogo();
        }

        // Boton de borrar el filtro de nombre.
        protected void btnBorrarFiltro_Click(object sender, EventArgs e)
        {
            Session.Remove("FiltroCatalogo");
            txtBoxFiltro.Text = "";
            RecargarCatalogo();
        }

        // Manda a la pagina de detalle segun el articulo que se haya clickeado.
        protected void btnDetalle_Click(object sender, EventArgs e)
        {
            int articuloId = int.Parse(((Button)sender).CommandArgument);

            List<Articulo> lista = (List<Articulo>)Session["ListaEnSession"];

            if (lista != null)
            {
                Articulo seleccionado = lista.Find(x => x.Id == articuloId);
                Session.Add("ArticuloSeleccionado", seleccionado);
                Session.Add("Origen", "Default.aspx");
                Response.Redirect("Detalle.aspx", false);
            }
            else
            {
                repRepetidor.DataSource = catalogo.ListarArticulo();
                repRepetidor.DataBind();
            }
        }

        protected void btnAgregarAlCarrito_Click(object sender, EventArgs e)
        {
            // Barrera de seguridad para que sin login no se pueda agregar al carrito.
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Session.Add("Error", "Debes estar logueado para añadir un articulo al carrito.");
                Response.Redirect("Error.aspx");
                return;
            }

            try
            {
                List<Articulo> listaArticulo = (List<Articulo>)Session["ListaEnSession"];
                int idArticulo = int.Parse(((Button)sender).CommandArgument);
                Articulo articuloAgregar = listaArticulo.Find(x => x.Id == idArticulo);
                List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();
                bool agregado = false;

                if (articuloAgregar != null)
                {
                    // Si el articulo ya esta en el carrito le sumo una unidad, si no lo agrego con cantidad 1.
                    ItemCarrito item = carrito.Find(x => x.Articulo.Id == idArticulo);
                    if (item != null)
                    {
                        if (item.Cantidad < articuloAgregar.Stock)
                        {
                            item.Cantidad++;
                            agregado = true;
                        }
                    }
                    else if (articuloAgregar.Stock > 0)
                    {
                        ItemCarrito nuevoItem = new ItemCarrito();
                        nuevoItem.Articulo = articuloAgregar;
                        nuevoItem.Cantidad = 1;
                        carrito.Add(nuevoItem);
                        agregado = true;
                    }
                }

                Session.Add("CarritoEnSession", carrito);
                RecargarCatalogo();

                // Esto lo hizo claude code ↓.
                if (agregado)
                    ScriptManager.RegisterStartupScript(this, GetType(), "ToastCarrito", "mostrarToast('Artículo agregado al carrito');", true);
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }


        // Esto lo hizo claude code ↓.
        protected void btnMasCantidad_Click(object sender, EventArgs e)
        {
            // Barrera de seguridad para que sin login no se pueda agregar al carrito (aunque no deberia aparecer, por las dudas).
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Session.Add("Error", "Debes estar logueado para modificar el carrito.");
                Response.Redirect("Error.aspx");
                return;
            }

            try
            {
                int idArticulo = int.Parse(((LinkButton)sender).CommandArgument);
                List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();
                bool agregado = false;

                ItemCarrito item = carrito.Find(x => x.Articulo.Id == idArticulo);
                if (item != null && item.Cantidad < item.Articulo.Stock)
                {
                    item.Cantidad++;
                    agregado = true;
                }

                Session.Add("CarritoEnSession", carrito);
                RecargarCatalogo();

                if (agregado)
                    ScriptManager.RegisterStartupScript(this, GetType(), "ToastCarrito", "mostrarToast('Artículo agregado al carrito');", true);
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto lo hizo claude code ↓.
        // Al llegar a 0 saca el articulo del carrito directamente, sin confirmacion.
        protected void btnMenosCantidad_Click(object sender, EventArgs e)
        {
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Session.Add("Error", "Debes estar logueado para modificar el carrito.");
                Response.Redirect("Error.aspx");
                return;
            }

            try
            {
                int idArticulo = int.Parse(((LinkButton)sender).CommandArgument);
                List<ItemCarrito> carrito = Session["CarritoEnSession"] as List<ItemCarrito> ?? new List<ItemCarrito>();

                ItemCarrito item = carrito.Find(x => x.Articulo.Id == idArticulo);
                if (item != null)
                {
                    item.Cantidad--;
                    if (item.Cantidad <= 0)
                        carrito.Remove(item);
                }

                Session.Add("CarritoEnSession", carrito);
                RecargarCatalogo();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto lo hizo claude code ↓.
        protected void btnFavorito_Click(object sender, EventArgs e)
        {
            // Barrera de seguridad para que no deje agregar a favoritos sin login.
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Session.Add("Error", "Debes estar logueado para añadir un articulo a Favoritos.");
                Response.Redirect("Error.aspx");
                return;
            }
            try
            {
                Usuario usuarioLogueado = (Usuario)Session["Usuario"];
                int idUsuario = usuarioLogueado.Id;
                int idArticuloFavorito = int.Parse(((LinkButton)sender).CommandArgument);

                ConsultasArticulo consultasArticulo = new ConsultasArticulo();

                // Toggle: si ya es favorito lo saca, si no lo agrega.
                if (_idsFavoritos.Contains(idArticuloFavorito))
                    catalogo.EliminarFavorito(idUsuario, idArticuloFavorito);
                else
                    consultasArticulo.AgregarArticuloFavorito(idUsuario, idArticuloFavorito);

                // Recargar favoritos y rebindear para actualizar el corazon.
                CargarFavoritos();
                RecargarCatalogo();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }   
        }
    }
}
