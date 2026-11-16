using System;
using System.Web;

namespace CatalogoWEB
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
        }

        // Si algun error no se atrapo con try/catch en la pagina, llega aca.
        // Lo mandamos a Error.aspx en vez de mostrar la pantalla amarilla de ASP.NET.
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (ex == null || Context.Session == null)
                return;

            Server.ClearError();
            Session.Add("Error", ex.GetBaseException());
            Response.Redirect("~/Error.aspx", false);
        }
    }
}
