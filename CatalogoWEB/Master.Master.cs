using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Dominio;
using Consultas;

namespace CatalogoWEB
{
    public partial class Master : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Si esta la sesion activa muestra cerrar sesion, si no esta activa, muestra iniciar sesion.
            if (Seguridad.SesionActiva(Session["Usuario"]))
            {
                btnCerrarSesion.Visible = true;
                btnLogin.Visible = false;
            }
        }

        // Redireccion a login.
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("Login.aspx", false);
        }

        // Cierra sesion, borra los datos en session y redireccion a catalogo principal.
        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Default.aspx");
        }
    }
}