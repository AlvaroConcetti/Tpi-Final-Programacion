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
                    lblMensajeValidacion.Text = "El campo email es obligatorio.";
                    return;
                }

                if (Validacion.ValidarVacio(txtBoxContrasena))
                {
                    lblMensajeValidacion.Text = "El campo contraseña es obligatoria.";
                    return;
                }

                if (Validacion.ValidarMaxLength(txtBoxEmail.Text, 100))
                {
                    lblMensajeValidacion.Text = "El maximo de caracteres para el email son 100.";
                    return;
                }

                if (Validacion.ValidarMaxLength(txtBoxContrasena.Text, 20))
                {
                    lblMensajeValidacion.Text = "El maximo de caracteres para la contraseña es 20.";
                    return;
                }

                if (Validacion.VlidarMinLength(txtBoxContrasena.Text, 6))
                {
                    lblMensajeValidacion.Text = "Por favor, ingrese una contraseña con minimo 6 caracteres";
                    return;
                }

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
                Session.Add("Error", ex.ToString());
                Response.Redirect("Error.aspx", false);
            }
        }
    }
}