using System;

namespace CatalogoWEB
{
	public partial class Error : System.Web.UI.Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			object error = Session["Error"];
			Session.Remove("Error");

			// Si es un mensaje nuestro (string) lo mostramos tal cual.
			// Si es una excepcion no mostramos el detalle, porque trae rutas del servidor y
			// consultas SQL. Solo lo mostramos cuando estamos probando en nuestra maquina.
			if (error is Exception && !Request.IsLocal)
			{
				lblError.Text = "Ocurrió un error inesperado. Intentá de nuevo en unos minutos.";
			}
			else if (error is Exception)
			{
				lblError.Text = Server.HtmlEncode(((Exception)error).Message);
			}
			else if (error != null)
			{
				lblError.Text = Server.HtmlEncode(error.ToString());
			}
			else
			{
				lblError.Text = "Ocurrió un error inesperado.";
			}
		}
	}
}
