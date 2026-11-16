using Dominio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Consultas
{
    public class ConsultasUsuario
    {
        public int Registrarse(Usuario usuario)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("RegistrarUsuarioSP");
                datos.setearParametro("@email", usuario.Email);
                // Se guarda el hash, nunca la contraseña en texto plano.
                datos.setearParametro("@pass", HashContrasena.Generar(usuario.Contrasena));

                int id = datos.ejecutarAccionScalar();
                usuario.Contrasena = null; // no dejar la contraseña guardada en la sesion
                return id;
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Busca el usuario por email y despues compara la contraseña con el hash guardado.
        // Si es un usuario viejo (contraseña sin hashear) y entra bien, se la hasheamos.
        public bool Login(Usuario usuario)
        {
            string passGuardada;
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("ObtenerUsuarioPorEmailSP");
                datos.setearParametro("@email", usuario.Email);
                datos.ejecutarLectura();

                if (!datos.Lector.Read())
                    return false;

                passGuardada = (string)datos.Lector["pass"];
                usuario.Id = (int)datos.Lector["id"];
                usuario.Admin = (bool)datos.Lector["admin"];

                if (!(datos.Lector["nombre"] is DBNull))
                    usuario.Nombre = (string)datos.Lector["nombre"];
                if (!(datos.Lector["apellido"] is DBNull))
                    usuario.Apellido = (string)datos.Lector["apellido"];
            }
            finally
            {
                datos.cerrarConexion();
            }

            bool correcta;
            if (HashContrasena.EstaHasheada(passGuardada))
            {
                correcta = HashContrasena.Verificar(usuario.Contrasena, passGuardada);
            }
            else
            {
                correcta = passGuardada == usuario.Contrasena;
                if (correcta)
                    ActualizarContrasena(usuario.Id, usuario.Contrasena);
            }

            usuario.Contrasena = null; // para no dejar la contraseña guardada en Session
            return correcta;
        }

        public void ActualizarPerfil(Usuario usuario)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("ActualizarPerfilSP");
                datos.setearParametro("@id", usuario.Id);
                datos.setearParametro("@nombre", usuario.Nombre);
                datos.setearParametro("@apellido", usuario.Apellido);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public void ActualizarContrasena(int idUsuario, string contrasenaNueva)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearProcedimiento("ActualizarPassUsuarioSP");
                datos.setearParametro("@id", idUsuario);
                datos.setearParametro("@pass", HashContrasena.Generar(contrasenaNueva));
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public bool VerificarEmailExiste(string email)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.setearConsulta("SELECT id FROM USERS WHERE email = @email");
                datos.setearParametro("@email", email);
                datos.ejecutarLectura();

                return datos.Lector.Read(); // Devuelve true si encuentra una fila o sea, ya existe
            }

            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
