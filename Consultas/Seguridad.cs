using System;
using Dominio;

namespace Consultas
{
    public static class Seguridad
    {
        public static bool SesionActiva(Object user)
        {
            Usuario usuario = user as Usuario;
            return usuario != null && usuario.Id != 0;
        }

        public static bool Admin(Object user)
        {
            Usuario usuario = user as Usuario;
            return usuario != null && usuario.Admin;
        }
    }
}
