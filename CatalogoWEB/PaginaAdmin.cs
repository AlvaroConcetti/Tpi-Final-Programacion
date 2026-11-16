using System;
using Consultas;

namespace CatalogoWEB
{
    // Clase base para todas las paginas del panel de administracion.
    // Hace el control de permisos en OnInit, ANTES de Page_Load y de los eventos de botones:
    // si el usuario no es admin, redirige a Error.aspx y corta la ejecucion de la pagina.
    //
    // Por que no alcanza con el chequeo en Page_Load + Response.Redirect(url, false):
    // con "false" la pagina sigue ejecutandose despues del redirect, asi que se cargan los datos
    // y se procesan los clicks (eliminar articulo, confirmar venta, etc.) igual. Un cliente que
    // arme el POST a mano podria disparar acciones de admin. Con "true" se termina el request ahi.
    public class PaginaAdmin : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (!Seguridad.Admin(Session["Usuario"]))
            {
                Session["Error"] = "No tenés permisos para ingresar a esta sección.";
                Response.Redirect("Error.aspx", true);
                return;
            }

            base.OnInit(e);
        }
    }
}
