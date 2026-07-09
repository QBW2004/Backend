using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_GameAccLaba
    {
        public List<M_GameAccLaba> GetAccLabas(M_GameAccLaba entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.GameAccLabas.Where(c => c.GameId == entity.GameId).ToList();
            }
        }
    }
}
