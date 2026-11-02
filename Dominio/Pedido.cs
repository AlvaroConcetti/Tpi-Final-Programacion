using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Pedido
    {
        public int Id { get; set; }
        public int IdUser { get; set; }
        public string EmailUsuario { get; set; }
        public string Estado { get; set; }
        public DateTime FechaPedido { get; set; }
        public DateTime? FechaConfirmacion { get; set; }
        public List<DetallePedido> Detalle { get; set; }

        public decimal Total
        {
            get { return Detalle.Sum(d => d.Subtotal); }
        }
    }
}
