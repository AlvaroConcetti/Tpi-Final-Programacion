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

    public partial class Login : System.Web.UI.Page
    {
        ConsultasUsuario Consultas = new ConsultasUsuario();
        Usuario usuario = new Usuario();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        // Validaciones en el backend.
        protected void btnIngresar_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate();
                if (!Page.IsValid)
                    return;


                if (Validacion.ValidarVacio(txtBoxEmail))
                {
                    lblMensajeValidacion.Text = "El email es obligatorio.";
                    return;
                }

                if (Validacion.ValidarVacio(txtBoxContrasena))
                {
                    lblMensajeValidacion.Text = "La contraseña es obligatoria.";
                    return;
                }

                if (Validacion.ValidarMaxLength(txtBoxEmail.Text, 100))
                {
                    lblMensajeValidacion.Text = "El email puede tener hasta 100 caracteres.";
                    return;
                }

                if (Validacion.ValidarMaxLength(txtBoxContrasena.Text, 20))
                {
                    lblMensajeValidacion.Text = "La contraseña puede tener hasta 20 caracteres.";
                    return;
                }

                // El minimo de 6 caracteres (y mayuscula/numero) se exige al registrarse y al cambiar la contraseña.
                // En el login no: si no, las cuentas creadas antes de esa regla (ej. admin@admin.com) no podrian entrar.

                usuario.Email = txtBoxEmail.Text;
                usuario.Contrasena = txtBoxContrasena.Text;

                // Verifica que exista la cuenta / que los datos esten correctos.
                if (Consultas.Login(usuario))
                {
                    Session.Add("Usuario", usuario);
                    Response.Redirect("Default.aspx", false);
                }
                else
                {
                    lblMensajeValidacion.Text = "Usuario o contraseña incorrectos.";
                }
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }
    }
}