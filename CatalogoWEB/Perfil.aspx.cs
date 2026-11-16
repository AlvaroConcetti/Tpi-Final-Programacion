using System;
using Consultas;
using Dominio;

namespace CatalogoWEB
{
    public partial class Perfil : System.Web.UI.Page
    {
        ConsultasUsuario consultasUsuario = new ConsultasUsuario();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Barrera de seguridad: sin sesion no hay perfil para mostrar.
            if (!Seguridad.SesionActiva(Session["Usuario"]))
            {
                Response.Redirect("Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                Usuario usuario = (Usuario)Session["Usuario"];
                txtBoxEmail.Text = usuario.Email;
                txtBoxNombre.Text = usuario.Nombre;
                txtBoxApellido.Text = usuario.Apellido;
            }
        }

        protected void btnGuardarDatos_Click(object sender, EventArgs e)
        {
            try
            {
                Usuario usuario = (Usuario)Session["Usuario"];
                usuario.Nombre = txtBoxNombre.Text.Trim();
                usuario.Apellido = txtBoxApellido.Text.Trim();

                consultasUsuario.ActualizarPerfil(usuario);

                // El usuario de Session es el mismo objeto, asi que ya queda actualizado.
                MostrarMensaje(lblMensajeDatos, "Datos guardados.", true);
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        protected void btnCambiarContrasena_Click(object sender, EventArgs e)
        {
            try
            {
                Page.Validate("Contrasena");
                if (!Page.IsValid)
                    return;

                Usuario usuarioSesion = (Usuario)Session["Usuario"];
                string nueva = txtBoxContrasenaNueva.Text;

                // Mismas reglas que al registrarse.
                if (Validacion.ValidarSeguridad(nueva))
                {
                    MostrarMensaje(lblMensajeContrasena, "La contraseña debe tener mínimo 6 caracteres, 1 mayúscula, 1 minúscula y 1 número.", false);
                    return;
                }

                // Para comprobar la contraseña actual reutilizamos el Login con un usuario auxiliar,
                // asi no tocamos el usuario que esta en Session.
                Usuario verificacion = new Usuario();
                verificacion.Email = usuarioSesion.Email;
                verificacion.Contrasena = txtBoxContrasenaActual.Text;

                if (!consultasUsuario.Login(verificacion))
                {
                    MostrarMensaje(lblMensajeContrasena, "La contraseña actual no es correcta.", false);
                    return;
                }

                consultasUsuario.ActualizarContrasena(usuarioSesion.Id, nueva);
                MostrarMensaje(lblMensajeContrasena, "Contraseña actualizada.", true);
            }
            catch (Exception ex)
            {
                Session.Add("Error", ex);
                Response.Redirect("Error.aspx", false);
            }
        }

        private void MostrarMensaje(System.Web.UI.WebControls.Label label, string texto, bool exito)
        {
            label.Text = texto;
            label.ForeColor = exito ? System.Drawing.Color.SeaGreen : System.Drawing.Color.Firebrick;
        }
    }
}
