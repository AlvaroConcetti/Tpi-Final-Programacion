using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CatalogoWEB
{
    public static class Validacion
    {
        // Esto lo hizo claude code
        // Formato internacional para WhatsApp: solo numeros, con codigo de pais, sin +/espacios/guiones
        public static bool ValidarTelefono(string texto)
        {
            if (string.IsNullOrWhiteSpace(texto)) return true;
            return !Regex.IsMatch(texto, @"^[1-9]\d{7,14}$");
        }

        public static bool ValidarVacio(object control)
        {
            if (control is TextBox txtBox)
            {
                if (string.IsNullOrWhiteSpace(txtBox.Text))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            return false;
        }

        public static bool ValidarMaxLength(string texto, int maximo)
        {
            if (string.IsNullOrEmpty(texto)) return false;
            return texto.Length > maximo;
        }

        public static bool VlidarMinLength(string texto, int minimo)
        {
            if (string.IsNullOrEmpty(texto)) return false;
            return texto.Length < minimo;
        }

        public static bool ValidarSeguridad(string contrasena)
        {
            int contadorMayusculas = 0;
            int contadorMinusculas = 0;
            int contadorNumeros = 0;

            for (int i = 0; i < contrasena.Length; i++)
            {

                if (char.IsUpper(contrasena[i]))
                {
                    contadorMayusculas++;

                }
                if (char.IsLower(contrasena[i]))
                {
                    contadorMinusculas++;
                }
                if (char.IsNumber(contrasena[i]))
                {
                    contadorNumeros++;
                }
            }

            if (contadorMayusculas >= 1 && contadorMinusculas >= 1 && contadorNumeros >= 1 && contrasena.Length >= 6)
            {
                return false;
            }
            else
            {
                return true;
            }

        }
    }
}