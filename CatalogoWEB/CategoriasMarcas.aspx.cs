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
    public partial class CategoriasMarcas : System.Web.UI.Page
    {
        ConsultasCatalogo consultasCatalogo = new ConsultasCatalogo();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad para que no puedan entrar usuarios al panel administracion.
            if (Seguridad.Admin(Session["Usuario"]) == false)
            {
                Session.Add("Error", "No tienes permisos para ingresar aqui.");
                Response.Redirect("Error.aspx", false);
            }

            if (!IsPostBack)
            {
                CargarListas();
            }
        }

        // Carga los repeaters con las Categorias y Marcas actuales.
        private void CargarListas()
        {
            try
            {
                repMarcas.DataSource = consultasCatalogo.ListarMarcas();
                repMarcas.DataBind();

                repCategorias.DataSource = consultasCatalogo.ListarCategorias();
                repCategorias.DataBind();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Redireccion para administracion.
        protected void btnVolverAdmin_Click(object sender, EventArgs e)
        {
            Response.Redirect("Administracion.aspx", false);
        }

        // Boton para agregar Marca.
        protected void btnAgregarMarca_Click(object sender, EventArgs e)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(txtNuevaMarca.Text))
                {
                    bool agregada = consultasCatalogo.AgregarMarca(txtNuevaMarca.Text.Trim());

                    if (agregada)
                        txtNuevaMarca.Text = "";
                    else
                        ScriptManager.RegisterStartupScript(this, GetType(), "ToastMarcaDuplicada",
                            "mostrarToast('Esa marca ya existe.');", true);
                }
                CargarListas();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Boton para agregar Categoria.
        protected void btnAgregarCategoria_Click(object sender, EventArgs e)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(txtNuevaCategoria.Text))
                {
                    bool agregada = consultasCatalogo.AgregarCategoria(txtNuevaCategoria.Text.Trim());

                    if (agregada)
                        txtNuevaCategoria.Text = "";
                    else
                        ScriptManager.RegisterStartupScript(this, GetType(), "ToastCategoriaDuplicada",
                            "mostrarToast('Esa categoría ya existe.');", true);
                }
                CargarListas();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto lo hizo claude code ↓.
        protected void repMarcas_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Guardar")
                {
                    int id = int.Parse(e.CommandArgument.ToString());
                    TextBox txtDescripcion = (TextBox)e.Item.FindControl("txtDescripcionMarca");

                    if (!string.IsNullOrWhiteSpace(txtDescripcion.Text))
                    {
                        bool modificada = consultasCatalogo.ModificarMarca(id, txtDescripcion.Text.Trim());

                        if (modificada)
                            ScriptManager.RegisterStartupScript(this, GetType(), "ToastGuardarMarca",
                                "mostrarToast('Marca actualizada');", true);
                        else
                            ScriptManager.RegisterStartupScript(this, GetType(), "ToastMarcaDuplicada",
                                "mostrarToast('Esa marca ya existe.');", true);
                    }

                    CargarListas();
                }
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto lo hizo claude code ↓.
        protected void repCategorias_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Guardar")
                {
                    int id = int.Parse(e.CommandArgument.ToString());
                    TextBox txtDescripcion = (TextBox)e.Item.FindControl("txtDescripcionCategoria");

                    if (!string.IsNullOrWhiteSpace(txtDescripcion.Text))
                    {
                        bool modificada = consultasCatalogo.ModificarCategoria(id, txtDescripcion.Text.Trim());

                        if (modificada)
                            ScriptManager.RegisterStartupScript(this, GetType(), "ToastGuardarCategoria",
                                "mostrarToast('Categoría actualizada');", true);
                        else
                            ScriptManager.RegisterStartupScript(this, GetType(), "ToastCategoriaDuplicada",
                                "mostrarToast('Esa categoría ya existe.');", true);
                    }

                    CargarListas();
                }
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto lo hizo claude code ↓.
        protected void btnEliminarMarcaOculto_Click(object sender, EventArgs e)
        {
            try
            {
                int id = int.Parse(hdnIdMarcaAEliminar.Value);
                bool exito = consultasCatalogo.EliminarMarca(id);

                if (!exito)
                    ScriptManager.RegisterStartupScript(this, GetType(), "ToastAlertaMarca",
                        "mostrarToastAlerta('No se puede eliminar: hay artículos que usan esta marca.');", true);

                CargarListas();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        // Esto lo hizo claude code ↓.
        protected void btnEliminarCategoriaOculto_Click(object sender, EventArgs e)
        {
            try
            {
                int id = int.Parse(hdnIdCategoriaAEliminar.Value);
                bool exito = consultasCatalogo.EliminarCategoria(id);

                if (!exito)
                    ScriptManager.RegisterStartupScript(this, GetType(), "ToastAlertaCategoria",
                        "mostrarToastAlerta('No se puede eliminar: hay artículos que usan esta categoría.');", true);

                CargarListas();
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }
    }
}
