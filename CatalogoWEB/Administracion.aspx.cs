using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Consultas;
using Dominio;

namespace CatalogoWEB
{
    public partial class Administracion : PaginaAdmin
    {
        ConsultasCatalogo consultasCatalogo = new ConsultasCatalogo();
        ConsultasArticulo consultasArticulo = new ConsultasArticulo();

        protected void Page_Load(object sender, EventArgs e)
        {
            ddlCriterio.Enabled = true;

            if (!IsPostBack)
            {
                CargarAvisoStockBajo();

                // Esto es para que no se actualice el filtro cuando se edita un articulo.
                if (!(string.IsNullOrEmpty(Request.QueryString["Buscar"])))
                {
                    ddlFiltrar.SelectedValue = Request.QueryString["Filtro"].ToString();
                    ddlFiltrar_SelectedIndexChanged(null, EventArgs.Empty);
                    ddlCriterio.SelectedValue = Request.QueryString["Criterio"].ToString();
                    txtBoxFiltrarAvanzado.Text = Request.QueryString["Buscar"];

                    CargarGrilla();
                }
                else
                {
                    ddlFiltrar_SelectedIndexChanged(null, EventArgs.Empty);
                    CargarGrilla();
                }
            }
        }

        // Muestra un aviso arriba de la grilla si hay articulos con 5 unidades o menos.
        private void CargarAvisoStockBajo()
        {
            ConsultasDashboard consultasDashboard = new ConsultasDashboard();
            List<Articulo> stockBajo = consultasDashboard.ArticulosStockBajo(5);

            pnlStockBajo.Visible = stockBajo.Count > 0;
            if (stockBajo.Count == 0)
                return;

            lblCantidadStockBajo.Text = stockBajo.Count == 1
                ? "Hay 1 artículo con poco stock:"
                : "Hay " + stockBajo.Count + " artículos con poco stock:";

            // Mostramos hasta 5 nombres para que el aviso no quede gigante.
            List<string> nombres = new List<string>();
            foreach (Articulo articulo in stockBajo.Take(5))
                nombres.Add(articulo.Nombre + " (" + articulo.Stock + ")");

            string texto = string.Join(", ", nombres);
            if (stockBajo.Count > 5)
                texto += " y " + (stockBajo.Count - 5) + " más.";

            lblArticulosStockBajo.Text = Server.HtmlEncode(texto);
        }

        // Carga la grilla respetando los filtros que esten escritos (el avanzado y el rapido por nombre).
        // Antes al cambiar de pagina o borrar un filtro se cargaba la lista completa y se perdia el otro filtro.
        private void CargarGrilla()
        {
            dgvArticulos.DataSource = ObtenerListaFiltrada();
            dgvArticulos.DataBind();
        }

        // Devuelve los articulos aplicando los filtros escritos. La usa la grilla y tambien la exportacion.
        private List<Articulo> ObtenerListaFiltrada()
        {
            List<Articulo> lista;

            if (!string.IsNullOrEmpty(txtBoxFiltrarAvanzado.Text))
            {
                string campo = ddlFiltrar.SelectedItem.ToString();
                string criterio = ddlCriterio.SelectedItem != null ? ddlCriterio.SelectedItem.ToString() : "";
                lista = consultasCatalogo.FiltrarAvanzado(campo, criterio, txtBoxFiltrarAvanzado.Text);
            }
            else
            {
                lista = consultasCatalogo.ListarArticulo();
            }

            if (!string.IsNullOrEmpty(txtBoxFiltrar.Text))
            {
                lista = lista.FindAll(x => x.Nombre.ToUpper().Contains(txtBoxFiltrar.Text.ToUpper()));
            }

            return lista;
        }

        // Descarga los articulos (con los filtros que esten aplicados) en un CSV con el mismo
        // formato que usa la importacion, asi se puede exportar, editar en Excel y volver a importar.
        protected void btnExportarCsv_Click(object sender, EventArgs e)
        {
            try
            {
                List<Articulo> lista = ObtenerListaFiltrada();

                StringBuilder csv = new StringBuilder();
                csv.AppendLine("Codigo;Nombre;Descripcion;Marca;Categoria;Precio;Stock");

                foreach (Articulo a in lista)
                {
                    csv.AppendLine(LimpiarCampo(a.Codigo) + ";" + LimpiarCampo(a.Nombre) + ";" + LimpiarCampo(a.Descripcion) + ";"
                        + LimpiarCampo(a.Marca) + ";" + LimpiarCampo(a.Categoria) + ";"
                        + a.Precio.ToString("0.##") + ";" + a.Stock);
                }

                string nombreArchivo = "articulos_" + DateTime.Now.ToString("yyyy-MM-dd") + ".csv";

                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + nombreArchivo);
                // UTF-8 con BOM para que Excel muestre bien los acentos.
                Response.ContentEncoding = Encoding.UTF8;
                Response.BinaryWrite(Encoding.UTF8.GetPreamble());
                Response.Write(csv.ToString());
                Response.Flush();
                Context.ApplicationInstance.CompleteRequest();
                // Evita que despues se agregue el HTML de la pagina al archivo.
                Response.SuppressContent = true;
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Saca los ";" y los saltos de linea de un texto, porque romperian las columnas del CSV.
        private string LimpiarCampo(string texto)
        {
            if (texto == null)
                return "";
            return texto.Replace(";", ",").Replace("\r", " ").Replace("\n", " ").Trim();
        }

        // Cuando cambia de pagina el dgv, carga los articulos correspondientes.
        protected void dgvArticulos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            try
            {
                dgvArticulos.PageIndex = e.NewPageIndex;
                CargarGrilla();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Redireccion para agregar articulo.
        protected void btnAgregarArticulo_Click(object sender, EventArgs e)
        {
            Response.Redirect("AgregarArticulo.aspx", false);
        }

        // Redireccion para la importacion masiva de articulos por CSV.
        protected void btnImportarCsv_Click(object sender, EventArgs e)
        {
            Response.Redirect("ImportarArticulos.aspx", false);
        }

        // Redireccion para administrar las marcas y categorias.
        protected void btnCategoriasMarcas_Click(object sender, EventArgs e)
        {
            Response.Redirect("CategoriasMarcas.aspx", false);
        }

        // Manejar los botones del dgv (editar o eliminar).
        protected void dgvArticulos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                // Me guardo el Id de la row seleccionada.
                int index = Convert.ToInt32(e.CommandArgument);
                string id = dgvArticulos.Rows[index].Cells[0].Text;

                // Corte de seguridad (al tener allowpasting=true puede llegar a fallar).
                if (e.CommandName != "Editar" && e.CommandName != "Eliminar")
                {
                    return;
                }
                if (e.CommandName == "Editar")
                {
                    // Va con UrlEncode por si el usuario filtra por algun caracter especial (&,%,#).
                    Response.Redirect("AgregarArticulo.aspx?Id=" + id
                        + "&Filtro=" + Server.UrlEncode(ddlFiltrar.SelectedItem.ToString())
                        + "&Criterio=" + Server.UrlEncode(ddlCriterio.SelectedItem.ToString())
                        + "&Buscar=" + Server.UrlEncode(txtBoxFiltrarAvanzado.Text), false);
                }
                else if (e.CommandName == "Eliminar")
                {
                    List<Articulo> lista = consultasCatalogo.ListarArticulo();
                    Articulo articuloABorrar = lista.Find(x => x.Id == int.Parse(id));

                    if (articuloABorrar != null && !(string.IsNullOrEmpty(articuloABorrar.UrlImagen)))
                    {
                        string rutaFisica = Server.MapPath("~/" + articuloABorrar.UrlImagen);

                        if (System.IO.File.Exists(rutaFisica))
                        {
                            System.IO.File.Delete(rutaFisica);
                        }
                    }

                    consultasArticulo.EliminarArticulo(int.Parse(id));
                    Response.Redirect("Administracion.aspx", false);
                }
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto para poder tirar la alerta de stock bajo.
        protected void dgvArticulos_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                LinkButton btnEliminar = (LinkButton)e.Row.Cells[8].Controls[0];
                btnEliminar.OnClientClick = "return mostrarModalEliminarArticulo(event, this);";

                // Indicador de stock: ⚠️ si esta bajo (1 a 5), 🚨 + fila en rojo si esta en 0.
                int stock;
                if (int.TryParse(e.Row.Cells[3].Text, out stock))
                {
                    if (stock == 0)
                    {
                        e.Row.Cells[3].Text = "🚨 " + stock;
                        e.Row.CssClass = (e.Row.CssClass + " fila-sin-stock").Trim();
                    }
                    else if (stock <= 5)
                    {
                        e.Row.Cells[3].Text = "⚠️ " + stock;
                    }
                }
            }
        }

        protected void btnBorrarFiltro_Click(object sender, EventArgs e)
        {
            txtBoxFiltrar.Text = "";
            dgvArticulos.PageIndex = 0;
            CargarGrilla();
        }

        // Para limpiar los filtros, se uso el redict para que se borren los datos de la querystring.
        protected void btnLimpiarFiltroAvanzado_Click(object sender, EventArgs e)
        {
            Response.Redirect("Administracion.aspx", false);
        }

        // Filtro rapido por nombre.
        // (Antes usaba la lista guardada en Session por el catalogo, que podia no existir si el admin
        // entraba directo aca. Ahora se trae de la base.)
        protected void txtBoxFiltrar_TextChanged(object sender, EventArgs e)
        {
            try
            {
                dgvArticulos.PageIndex = 0;
                CargarGrilla();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto es para el filtro avanzado.
        protected void ddlFiltrar_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlCriterio.Items.Clear();
            if (ddlFiltrar.SelectedItem.ToString() == "Código")
            {
                ddlCriterio.Items.Add("=");

                lblTxtBoxFiltrarAvanzado.Text = "Código";
            }
            else if (ddlFiltrar.SelectedItem.ToString() == "Precio")
            {
                ddlCriterio.Items.Add(">");
                ddlCriterio.Items.Add("=");
                ddlCriterio.Items.Add("<");

                lblTxtBoxFiltrarAvanzado.Text = "Precio";
            }
            else if (ddlFiltrar.SelectedItem.ToString() == "Marca")
            {
                ddlCriterio.Items.Add("Contiene");

                ddlCriterio.Enabled = false;
                lblTxtBoxFiltrarAvanzado.Text = "Marca";
            }
            else if (ddlFiltrar.SelectedItem.ToString() == "Categoría")
            {
                ddlCriterio.Items.Add("Contiene");

                ddlCriterio.Enabled = false;
                lblTxtBoxFiltrarAvanzado.Text = "Categoria";
            }
            else
            {
                txtBoxFiltrarAvanzado.Visible = true;
                lblTxtBoxFiltrarAvanzado.Visible = true;
            }
        }

        // Boton del filtro avanzado que dispara la consulta de busqueda.
        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(txtBoxFiltrarAvanzado.Text))
                {
                    return;
                }

                dgvArticulos.PageIndex = 0;
                CargarGrilla();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }


    }
}