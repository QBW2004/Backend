using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.Entity.Validation;
using System.Diagnostics;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class GameDbContext : DbContext
    {
        public GameDbContext() : base("DbConnString")
        {
            this.Database.Log = message => Trace.WriteLine($"【SQL语句】{message}");
            this.Configuration.ValidateOnSaveEnabled = false;
        }

        /// <summary>
        /// 后台用户信息
        /// </summary>
        public DbSet<M_Admin> Admins { get; set; }
        /// <summary>
        /// 点杀记录
        /// </summary>
        public DbSet<M_ManagerOpt> ManagerOpts { get; set; }
        /// <summary>
        /// 公告信息
        /// </summary>
        public DbSet<M_Notice> Notices { get; set; }
        /// <summary>
        /// 【下注类型游戏机台参数】
        /// </summary>
        public DbSet<M_ParaBet> ParaBets { get; set; }
        /// <summary>
        /// 游戏参数
        /// </summary>
        public DbSet<M_ParaBetRoom> ParaBetRooms { get; set; }
        /// <summary>
        /// 【牌机类型游戏参数】
        /// </summary>
        public DbSet<M_ParaCard> ParaCards { get; set; }
        /// <summary>
        /// 【鱼机类型游戏参数】
        /// </summary>
        public DbSet<M_ParaFish> ParaFishes { get; set; }
        /// <summary>
        /// 【牌机类型参数】
        /// </summary>
        public DbSet<M_ParaGame> ParaGames { get; set; }
        /// <summary>
        /// 【牌机类型游戏房间参数】
        /// </summary>
        public DbSet<M_ParaRoom> ParaRoom { get; set; }
        /// <summary>
        /// 程序包信息
        /// </summary>
        public DbSet<M_UpdateAddr> UpdateAddrs { get; set; }
        /// <summary>
        /// 玩家信息
        /// </summary>
        public DbSet<M_Users> Users { get; set; }
        /// <summary>
        /// 游戏信息
        /// </summary>
        public DbSet<M_Games> Games { get; set; }

        /// <summary>
        /// 视讯平台信息
        /// </summary>
        public DbSet<M_PlatType> PlatTypes { get; set; }
        /// <summary>
        /// 收款人信息
        /// </summary>
        public DbSet<M_CashierInfo> CashierInfos { get; set; }
        /// <summary>
        /// 充值记录
        /// </summary>
        public DbSet<M_ReChargeRecords> ReChargeRecords{ get; set; }
        /// <summary>
        /// 点杀记录视图
        /// </summary>
        public DbSet<View_ManagerOpt> View_ManagerOpts { get; set; }
        /// <summary>
        /// 权限信息
        /// </summary>
        public DbSet<M_MgrPermission> MgrPermissions { get; set; }
        /// <summary>
        /// 玩家账号标识信息
        /// </summary>
        public DbSet<M_UserRelations> UserRelations { get; set; }
        /// <summary>
        /// 视讯日志
        /// </summary>
        public DbSet<M_TransferLog> TransferLogs { get; set; }

        /// <summary>
        /// 进入游戏日志
        /// </summary>
        public DbSet<M_AccountLog> AccountLogs { get; set; }

        /// <summary>
        /// 图片
        /// </summary>
        public DbSet<M_UploadsImage> UploadsImages { get; set; }

        /// <summary>
        /// 代理日志
        /// </summary>
        public DbSet<M_AgencyOptLog> AgencyOptLogs { get; set; }
        /// <summary>
        /// 玩家日志
        /// </summary>
        public DbSet<M_UserOptLog> UserOptLogs { get; set; }
        /// <summary>
        /// 拉霸参数
        /// </summary>
        public DbSet<M_GameConfigLaba> GameConfigLabas { get; set; }
        /// <summary>
        /// 拉霸库存
        /// </summary>
        public DbSet<M_GameAccLaba> GameAccLabas { get; set; }
        /// <summary>
        /// 游戏服务命令Outbox
        /// </summary>
        public DbSet<M_GameCommandOutbox> GameCommandOutboxes { get; set; }
        /// <summary>
        /// 桌子帐目
        /// </summary>
        public DbSet<M_TableCoinRecord> TableCoinRecords { get; set; }
        /// <summary>
        /// 用户账号锁定记录
        /// </summary>
        public DbSet<M_UserLockRecord> UserLockRecords { get; set; }
        /// <summary>
        /// 登录错误记录
        /// </summary>
        public DbSet<M_LoginMissRecord> LoginMissRecords { get; set; }

        public DbSet<M_GameMo> GameMos { get; set; }

        public DbSet<M_UserRobot> userRobots { get; set; }

        public DbSet<M_Robot> Robots { get; set; }

        /// <summary>
        /// 保险柜存入取出日志
        /// </summary>
        public DbSet<M_SafeCoinsLog> safeCoinsLogs { get; set; }
        /// <summary>
        /// 兑换记录表
        /// </summary>
        public DbSet<M_ExChange> exChanges { get; set; }

        /// <summary>
        /// 活动表
        /// </summary>
        public DbSet<M_Activity> Activities { get; set; }
        public DbSet<M_UserControlStatus> UserControlStatuses { get; set; }
        protected override DbEntityValidationResult ValidateEntity(DbEntityEntry entityEntry, IDictionary<object, object> items)
        {
            //当实体不为null且实体状态为已发生变化时执行
            if (entityEntry != null && entityEntry.State == EntityState.Modified)
            {
                //获取实体验证结果
                var ValidateEntity = base.ValidateEntity(entityEntry, items);
                //获取实体当前属性的属性名称列表
                var PropertyNames = ValidateEntity.Entry.CurrentValues.PropertyNames;

                foreach (var PropertyName in PropertyNames)
                {
                    //判断当前属性的值是否发生了变化
                    if (ValidateEntity.Entry.Property(PropertyName).IsModified == false)
                    {
                        //如果当前实体属性未发生变化，则查询验证结果中该属性的验证错误信息
                        var ve = ValidateEntity.ValidationErrors.FirstOrDefault(a => a.PropertyName == PropertyName);
                        //如果获取的该实体当前属性的验证错误信息存在，则从验证错误信息中移除它
                        if (ve != null)
                        {
                            ValidateEntity.ValidationErrors.Remove(ve);
                        }
                    }
                }
                //返回最终的验证结果
                return ValidateEntity;
            }
            else
            {
                return base.ValidateEntity(entityEntry, items);
            }
        }
    }
}
