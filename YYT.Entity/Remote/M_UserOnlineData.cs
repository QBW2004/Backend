using Newtonsoft.Json;

namespace YYT.Entity
{
    /// <summary>
    /// 用户实时在线数据
    /// </summary>
    public class M_UserOnlineData
    {
        // {"Cmd":"QU","Coin":0,"GameID":43,"Ret":0,"Score":0}
        public string Cmd { get; set; }
        /// <summary>
        /// 位置
        /// <para>0 :未登陆过游戏</para>
        /// <para>1：游戏中</para>
        /// <para>2：大厅</para>
        /// <para>3：登出</para>
        /// </summary>
        public int Ret { get; set; }
        /// <summary>
        /// 金币数
        /// </summary>
        public long? Coin { get; set; }
        /// <summary>
        /// 游戏ID
        /// </summary>
        public int? GameID { get; set; }
        /// <summary>
        /// 游戏里面的分
        /// </summary>
        public long? Score { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
