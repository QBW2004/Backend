using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Collections.Specialized;
using System.Data;
using System.Text;

namespace YYT.Entity
{
    /// <summary>
    /// 分页类
    /// </summary>
    public class Pagination
    {
        public DataTable pageData { get; set; }

        /// <summary>
        /// 分页类
        /// </summary>
        /// <param name="srcData">数据源</param>
        /// <param name="totalCount">总数据条数</param>
        /// <param name="pageIndex">当前页码</param>
        /// <param name="pageSize">页大小</param>
        public Pagination(DataTable srcData, int totalCount, int pageIndex = 1, int pageSize = 10)
        {
            this.PageIndex = pageIndex;
            this.PageSize = pageSize;
            this.TotalCount = totalCount;

            this.TotalPage = this.TotalCount / this.PageSize;
            if ((this.TotalCount % this.PageSize) > 0)
                this.TotalPage += 1;

            this.IsPreviousPage = (this.PageIndex > 1);
            this.IsNextPage = (this.PageIndex < this.TotalPage);

            this.pageData = srcData;
        }

        /// <summary>
        /// DataTable 转 JSON Array
        /// </summary>
        /// <returns></returns>
        private string GetJsonFromDataTable()
        {
            if (this.pageData == null || this.pageData.Rows.Count == 0)
                return "[]";
            else
                return JsonConvert.SerializeObject(this.pageData, new DataTableConverter());
        }

        /// <summary>
        /// Json数据
        /// </summary>
        /// <returns></returns>
        public virtual string GetEasyUIGridJson()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("{");
            sb.AppendFormat("total:{0},", this.TotalCount);
            sb.AppendFormat("rows:{0}", GetJsonFromDataTable());
            sb.Append("}");
            return sb.ToString();
        }

        /// <summary>
        /// 总页数
        /// </summary>
        public int TotalPage { get; set; }
        /// <summary>
        /// 总条数
        /// </summary>
        public int TotalCount { get; set; }
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
        /// <summary>
        /// 是否有上一页
        /// </summary>
        public bool IsPreviousPage { get; set; }
        /// <summary>
        /// 是否有下一页
        /// </summary>
        public bool IsNextPage { get; set; }
        /// <summary>
        /// 查询条件
        /// </summary>
        public NameValueCollection Condition { get; set; }
    }
}
