using Consultas;
using Dominio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Runtime.Remoting.Messaging;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CatalogoWEB
{
    public partial class Registrarse : System.Web.UI.Page
    {
        ConsultasUsuario consultas = new ConsultasUsuario();
        Usuario usuario = new Usuario();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        // Validaciones en el back.
        protected void btnCrearCuenta_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate();
                if (!Page.IsValid)
                    return;

                if (Validacion.ValidarVacio(txtBoxEmail) || Validacion.ValidarVacio(txtBoxContrasena) || Validacion.ValidarVacio(txtBoxconfirmarContrasena))
                {
                    lblMensajeValidacion.Text = "Debes completar todos los campos para poder registrarte.";
                    return;
                }

                if (Validacion.ValidarMaxLength(txtBoxEmail.Text, 100))
                {
                    lblMensajeValidacion.Text = "El maximo de caracteres para el email son 100.";
                    return;
                }

                if (Validacion.ValidarMaxLength(txtBoxContrasena.Text, 20))
                {
                    lblMensajeValidacion.Text = "El maximo de caracteres para la contraseña son 20.";
                    return;
                }

                if (Validacion.ValidarMaxLength(txtBoxconfirmarContrasena.Text, 20))
                {
                    lblMensajeValidacion.Text = "El maximo de caracteres para la contraseña son 20.";
                    return;
                }

                if (consultas.VerificarEmailExiste(txtBoxEmail.Text))
                {
                    lblMensajeValidacion.Text = "El email ya esta registrado. Intente con otro.";
                    return;
                }

                if (Validacion.ValidarSeguridad(txtBoxContrasena.Text))
                {
                    lblMensajeValidacion.Text = "La contraseña debe tener minimo 1 mayúscula , 1 número y 6 caracteres.";
                    return;
                }

                if (txtBoxContrasena.Text != txtBoxconfirmarContrasena.Text)
                {
                    lblMensajeValidacion.Text = "Las contraseñas no coinciden.";
                    return;
                }

                usuario.Email = txtBoxEmail.Text;
                usuario.Contrasena = txtBoxContrasena.Text;
                usuario.Id = consultas.Registrarse(usuario);

                Session.Add("Usuario", usuario);
                Response.Redirect("Default.aspx", false);
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex.ToString());
                Response.Redirect("Default.aspx", false);
            }
        }
    }
}