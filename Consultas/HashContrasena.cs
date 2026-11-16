using System;
using System.Security.Cryptography;

namespace Consultas
{
    // Para no guardar las contraseñas en texto plano en la base de datos.
    // Se guarda: PBKDF2$iteraciones$salt$hash
    // El salt es un valor al azar distinto para cada usuario, asi dos usuarios con la
    // misma contraseña no quedan con el mismo hash.
    public static class HashContrasena
    {
        private const int Iteraciones = 10000;

        public static string Generar(string contrasena)
        {
            byte[] salt = new byte[16];
            using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            string hash = CalcularHash(contrasena, salt, Iteraciones);
            return "PBKDF2$" + Iteraciones + "$" + Convert.ToBase64String(salt) + "$" + hash;
        }

        // Vuelve a calcular el hash con el mismo salt y lo compara con el guardado.
        public static bool Verificar(string contrasena, string guardado)
        {
            string[] partes = guardado.Split('$');
            if (partes.Length != 4)
                return false;

            int iteraciones = int.Parse(partes[1]);
            byte[] salt = Convert.FromBase64String(partes[2]);

            return CalcularHash(contrasena, salt, iteraciones) == partes[3];
        }

        // Los usuarios creados antes de este cambio tienen la contraseña en texto plano.
        public static bool EstaHasheada(string guardado)
        {
            return guardado.StartsWith("PBKDF2$");
        }

        private static string CalcularHash(string contrasena, byte[] salt, int iteraciones)
        {
            using (Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(contrasena, salt, iteraciones, HashAlgorithmName.SHA256))
            {
                return Convert.ToBase64String(pbkdf2.GetBytes(32));
            }
        }
    }
}
