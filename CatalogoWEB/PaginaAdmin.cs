using System;
using Consultas;

namespace CatalogoWEB
{
    // Todas las paginas de administracion heredan de esta clase en vez de System.Web.UI.Page.
    // Asi el control de "es admin?" esta en un solo lugar y no repetido en cada pagina.
    //
    // Se hace en OnInit porque se ejecuta antes que Page_Load y que los eventos de los botones.
    // Ademas el Redirect va con "true" para que corte la ejecucion de la pagina: con "false"
    // la pagina seguia corriendo y alguien sin permisos podia llegar a disparar un boton
    // (por ejemplo eliminar un articulo).
    public class PaginaAdmin : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (!Seguridad.Admin(Session["Usuario"]))
            {
                Session.Add("Error", "No tienes permisos para ingresar aqui.");
                Response.Redirect("Error.aspx", true);
            }

            base.OnInit(e);
        }
    }
}
