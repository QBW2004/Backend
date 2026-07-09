using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using YYT.Common;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_UpdateAddr
    {

        public List<M_UpdateAddr> GetSettings()
        {
            using (var ef = new GameDbContext())
            {
                return ef.UpdateAddrs.OrderBy(c => c.ID).ToList();
            }
        }

        public Msg SaveConfig(M_UpdateAddr entity)
        {
            Msg msg = new Msg(0, "保存失败！");
            using (var ef = new GameDbContext())
            {
                // // 该方式是更新整个实体
                //ef.Set<M_UpdateAddr>().Attach(entity);
                //ef.Entry<M_UpdateAddr>(entity).State = EntityState.Modified;

                DbEntityEntry<M_UpdateAddr> entry = ef.Entry<M_UpdateAddr>(entity);
                entry.State = EntityState.Unchanged;

                //设置要更新的属性
                entry.Property(f => f.G0).IsModified = true;
                entry.Property(f => f.G1).IsModified = true;
                entry.Property(f => f.G2).IsModified = true;
                entry.Property(f => f.G3).IsModified = true;
                entry.Property(f => f.G4).IsModified = true;
                entry.Property(f => f.G5).IsModified = true;
                entry.Property(f => f.G6).IsModified = true;
                entry.Property(f => f.G7).IsModified = true;
                entry.Property(f => f.G8).IsModified = true;
                entry.Property(f => f.G9).IsModified = true;
                entry.Property(f => f.G10).IsModified = true;

                entry.Property(f => f.V0).IsModified = true;
                entry.Property(f => f.V1).IsModified = true;
                entry.Property(f => f.V2).IsModified = true;
                entry.Property(f => f.V3).IsModified = true;
                entry.Property(f => f.V4).IsModified = true;
                entry.Property(f => f.V5).IsModified = true;
                entry.Property(f => f.V6).IsModified = true;
                entry.Property(f => f.V7).IsModified = true;
                entry.Property(f => f.V8).IsModified = true;
                entry.Property(f => f.V9).IsModified = true;
                entry.Property(f => f.V10).IsModified = true;

                int val = ef.SaveChanges();
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "保存成功！";
                }
            }
            return msg;
        }
    }
}
