namespace YYT.Entity
{
    public class M_GameRoomDeskPara
    {
        /// <summary>
        /// 房间索引
        /// <para>0 初级场</para>
        /// <para>1 中级场</para>
        /// <para>2 高级场</para>
        /// <para>3 VIP级场</para>
        /// </summary>
        public int RoomIndex { get; set; }
        /// <summary>
        /// 桌子数量
        /// </summary>
        public int DeskCount { get; set; }
    }
}