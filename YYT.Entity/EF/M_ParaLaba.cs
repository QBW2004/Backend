using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 拉霸类机台参数设定表（一桌一行，替代 gameconfiglaba key-value 散存）
    /// </summary>
    [Table("paralaba")]
    public class M_ParaLaba
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
        /// 拉霸子类型 1=明星97 2=水果拉霸 3=水浒传
        /// </summary>
        public int SubType { get; set; }

        /// <summary>
        /// 难度（水浒传复用 parabet.DIF）
        /// </summary>
        public int DIF { get; set; }

        /// <summary>
        /// 加难（水浒传复用 parabet.HAR）
        /// </summary>
        public int HAR { get; set; }

        // ── 符号赔率 ──
        public int Payout0 { get; set; }
        public int Payout1 { get; set; }
        public int Payout2 { get; set; }
        public int Payout3 { get; set; }
        public int Payout4 { get; set; }
        public int Payout5 { get; set; }
        public int Payout6 { get; set; }
        public int Payout7 { get; set; }
        public int Payout8 { get; set; }

        // ── 符号出现率（万分比）──
        public int Prob0 { get; set; }
        public int Prob1 { get; set; }
        public int Prob2 { get; set; }
        public int Prob3 { get; set; }
        public int Prob4 { get; set; }
        public int Prob5 { get; set; }
        public int Prob6 { get; set; }
        public int Prob7 { get; set; }
        public int Prob8 { get; set; }

        // ── 水果拉霸大转盘 24 面板指向概率 ──
        public int WheelProb0 { get; set; }
        public int WheelProb1 { get; set; }
        public int WheelProb2 { get; set; }
        public int WheelProb3 { get; set; }
        public int WheelProb4 { get; set; }
        public int WheelProb5 { get; set; }
        public int WheelProb6 { get; set; }
        public int WheelProb7 { get; set; }
        public int WheelProb8 { get; set; }
        public int WheelProb9 { get; set; }
        public int WheelProb10 { get; set; }
        public int WheelProb11 { get; set; }
        public int WheelProb12 { get; set; }
        public int WheelProb13 { get; set; }
        public int WheelProb14 { get; set; }
        public int WheelProb15 { get; set; }
        public int WheelProb16 { get; set; }
        public int WheelProb17 { get; set; }
        public int WheelProb18 { get; set; }
        public int WheelProb19 { get; set; }
        public int WheelProb20 { get; set; }
        public int WheelProb21 { get; set; }
        public int WheelProb22 { get; set; }
        public int WheelProb23 { get; set; }

        // ── 押分与兑换参数 ──
        public int BetMin { get; set; }
        public int BetMax { get; set; }
        public int CoinsNeed { get; set; }
        public int ExCoin { get; set; }
        public int CoinSc { get; set; }
        public int GameMo { get; set; }
        public int ScoreSwitchX10 { get; set; }
        public int DefaultBetIndex { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
