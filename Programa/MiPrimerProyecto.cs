/*
Esta es mi primera aplicacion de C#
*/


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MiPrimerProyecto
{
    class Program
    {
        static void Main(string [] args)
        {
            //Este programa solo imprime un mensaje
            #region Imprimir
            Console.writeline("Probando mi primer proyecto");
            #endregion
            int a=10;

            string nombre = "Noemi";
            var apellido = "Leon";
            Console.writeline("ingrese su nombre:");
            nombre = Console.ReadLine();
            Console.writeline("ingrese su apellido:");
            apellido = Console.ReadLine();
            Console.writeline("su nombre es:" + nombre + apellido);
            Console.ReadKey();
        }
    }
}