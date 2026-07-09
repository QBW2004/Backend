using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 机器人设置
    /// </summary>
    [Table("robot_seat")]
    public class M_Robot
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }
        /// <summary>
        /// 游戏标识ID
        /// </summary>
        public int GAME_ID { get; set; }

        public string GAME_NAME { get; set; }
        /// <summary>
        /// 游戏类型
        /// </summary>
        public int GAME_TYPE { get; set; }
        /// <summary>
        /// 房间选择
        /// </summary>
        public int ROOM_ID { get; set; }



        public string ROOM_NAME { get; set; }
        /// <summary>
        /// 机台选择
        /// </summary>
        public int TABLE_ID { get; set; }
        /// <summary>
        /// 机器人 人数
        /// </summary>
        public int ROBOT_NO { get; set; }
      
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }


}
