using System.ComponentModel;

namespace YYT.Entity
{
    public class M_Page
    {
        /// <summary>
        /// 总页数
        /// </summary>
        public int TotalPage { get; private set; }
        /// <summary>
        /// 总条数
        /// </summary>
        public int TotalCount { get; private set; }
        /// <summary>
        /// 页码
        /// </summary>
        public int PageIndex { get; set; }
        /// <summary>
        /// 页大小
        /// </summary>
        public int PageSize { get; set; }
        /// <summary>
        /// 排序字段
        /// </summary>
        public string ColSort { get; set; }

        public M_Page(int pageIndex,int pageSize)
        {
            this.PageIndex = pageIndex;
            this.PageSize = pageSize;
        }

        public void SetTotalCount(int count)
        {
            this.TotalCount = count;
            this.TotalPage = count / this.PageSize;

            if (count % this.PageSize > 0)
                this.TotalPage += 1;
        }
    }
}
