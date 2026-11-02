using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Consultas;
using Dominio;

namespace CatalogoWEB
{
    public partial class Administracion : System.Web.UI.Page
    {
        ConsultasCatalogo consultasCatalogo = new ConsultasCatalogo();
        ConsultasArticulo consultasArticulo = new ConsultasArticulo();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que no puedan entrar usuarios al panel administracion.
            if (Seguridad.Admin(Session["Usuario"]) == false)
            {
                Session.Add("Error", "No tienes permisos para ingresar aqui.");
                Response.Redirect("Error.aspx", false);
            }

            ddlCriterio.Enabled = true;

            if (!IsPostBack)
            {
                // Esto es para que no se actualice el filtro cuando se edita un articulo.
                if (!(string.IsNullOrEmpty(Request.QueryString["Buscar"])))
                {
                    string filtro = Request.QueryString["Filtro"];
                    string criterio = Request.QueryString["Criterio"];
                    string buscar = Request.QueryString["Buscar"];

                    ddlFiltrar.SelectedValue = Request.QueryString["Filtro"].ToString();
                    ddlFiltrar_SelectedIndexChanged(null, EventArgs.Empty);
                    ddlCriterio.SelectedValue = Request.QueryString["Criterio"].ToString();
                    txtBoxFiltrarAvanzado.Text = Request.QueryString["Buscar"];

                    dgvArticulos.DataSource = consultasCatalogo.FiltrarAvanzado(filtro, criterio, buscar);
                    dgvArticulos.DataBind();
                }
                else
                {
                    dgvArticulos.DataSource = consultasCatalogo.ListarArticulo();
                    dgvArticulos.DataBind();

                    ddlFiltrar_SelectedIndexChanged(null, EventArgs.Empty);
                }
            }
        }

        // Cuando cambia de pagina el dgv, carga los articulos correspondientes.
        protected void dgvArticulos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            try
            {
                dgvArticulos.PageIndex = e.NewPageIndex;
                dgvArticulos.DataSource = consultasCatalogo.ListarArticulo();
                dgvArticulos.DataBind();
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
        // Esto lo hizo claude code ↓.
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
            dgvArticulos.DataSource = Session["ListaEnSession"];
            dgvArticulos.DataBind();
            txtBoxFiltrar.Text = "";
        }

        // Para limpiar los filtros, se uso el redict para que se borren los datos de la querystring.
        protected void btnLimpiarFiltroAvanzado_Click(object sender, EventArgs e)
        {
            Response.Redirect("Administracion.aspx", false);
        }

        // Filtro rapido por nombre.
        protected void txtBoxFiltrar_TextChanged(object sender, EventArgs e)
        {
            List<Articulo> articulos = (List<Articulo>)Session["ListaEnSession"];
            List<Articulo> listaFiltrada = articulos.FindAll(x => x.Nombre.ToUpper().Contains(txtBoxFiltrar.Text.ToUpper()));
            dgvArticulos.DataSource = listaFiltrada;
            dgvArticulos.DataBind();
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
                string campo = ddlFiltrar.SelectedItem.ToString();
                string criterio = ddlCriterio.SelectedItem != null ? ddlCriterio.SelectedItem.ToString() : "";
                string filtro = "";

                if (campo == "Marca")
                {
                    filtro = txtBoxFiltrarAvanzado.Text;
                }
                else if (campo == "Categoría")
                {
                    filtro = txtBoxFiltrarAvanzado.Text;
                }
                else
                {
                    filtro = txtBoxFiltrarAvanzado.Text;
                }

                if (string.IsNullOrEmpty(filtro))
                {
                    return;
                }

                dgvArticulos.DataSource = consultasCatalogo.FiltrarAvanzado(campo, criterio, filtro);
                dgvArticulos.DataBind();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }


    }
}