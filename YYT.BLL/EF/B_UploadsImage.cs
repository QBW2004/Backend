using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;


namespace YYT.BLL.EF
{
    public class B_UploadsImage
    {
        public void AddUploadsImage(M_UploadsImage entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.UploadsImages.Add(entity);
                ef.SaveChangesAsync();
            }
        }
        public Msg AddUploadsImage(GameDbContext ef, M_UploadsImage entity)
        {
            try
            {
                
                ef.UploadsImages.Add(entity);

                if (ef.SaveChanges() > 0)
                    return new Msg(1, "添加成功！");
                return new Msg(0, "添加失败！");
            }
            catch(Exception ex)
            {
                return new Msg(0, "添加失败！"+ex.Message);
            }

        }
        public M_EasyuiGridData<M_UploadsImage> GetUploadsImage(M_LoginUser loginUser, M_Page mPage )
        {
            M_EasyuiGridData<M_UploadsImage> list = new M_EasyuiGridData<M_UploadsImage>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_UploadsImage> rst = ef.UploadsImages;
               
                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public List<UploadsImageList> GetQRCodeList()
        {
            using (var ef = new GameDbContext())
            {
                IQueryable<UploadsImageList> RankList = null;
                var rst = from u in ef.UploadsImages
                          group u by new { ID = u.ID, ImageName = u.ImageName, ImagePath = u.ImagePath, ImageType =u.ImageType} into g
                          select new UploadsImageList
                          {
                              ID = g.Key.ID,
                              ImageName = g.Key.ImageName,
                              ImagePath = g.Key.ImageType + g.Key.ImagePath
                          };
                RankList = rst.OrderByDescending(x => x.ID);
                return RankList.ToList();
            }
        }

        public int UpdateUploadsImage(string ImagePath, int Id)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                try
                {

                    var rst = ef.UploadsImages.Where(c => c.ID.Equals(Id)).SingleOrDefault();
                    if (rst != null)
                    {
                        rst.ImagePath = ImagePath;
                        val = ef.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_UploadsImage), ex);
                }
            }
            return val;

        }
    }
}
