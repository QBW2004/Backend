using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 游戏信息
    /// </summary>
    [Table("Games")]
    public class M_Games
    {
        /// <summary>
        /// 游戏标识ID
        /// </summary>
        [Key]
        public int GameId { get; set; }
        /// <summary>
        /// 游戏名称
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// 是否启用
        /// <para>0 禁用</para>
        /// <para>1 启用</para>
        /// </summary>
        public int? Enable { get; set; }

        /// <summary>
        /// 机器人数量
     
        /// </summary>
        public int Num { get; set; }
        /// <summary>
        /// 游戏类型
        /// <para>0 下注类型</para>
        /// <para>1 牌机类型</para>
        /// <para>2 捕鱼类型</para>
        /// </summary>
        public int GameType { get; set; }
    
    }

    
    public class M_Games_Tree
    {
        public int id { get; set; }
        public int text { get; set; }
        public List<M_Games> rows { get; set; }
    }
}
