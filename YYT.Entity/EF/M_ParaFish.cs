using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 捕鱼类参数设定表
    /// </summary>
    [Table("ParaFish")]
    public class M_ParaFish
    {
        /// <summary>
        /// 桌台编号（gameId*1000 + tableIndex，与 roomtableconfig 同编码）
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ID { get; set; }
        /// <summary>
        /// 游戏编号
        /// </summary>
        public int GAME_ID { get; set; }
        /// <summary>
        /// 桌号（0-based，对齐 roomtableconfig.TableIndex）
        /// </summary>
        public int TableIndex { get; set; }
        /// <summary>
        /// 桌名（冗余，便于后台查询，与 roomtableconfig.TableName 同步）
        /// </summary>
        public string TableName { get; set; }
        /// <summary>
        /// 鱼机难度
        /// </summary>
        public int DIF { get; set; }
        public int HAR { get; set; }
        /// <summary>
        /// 场地类型
        /// </summary>
        public int SITE_TYPE { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
