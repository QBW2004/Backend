namespace YYT.BLL.EF
{
    public class GameParaFactory
    {
        public GameParaFactory(EGameParaType eGameParaType)
        {
            this.GameParaType = eGameParaType;
        }

        public EGameParaType GameParaType { get; }

        public IGamePara GetGameParaQuery()
        {
            switch (this.GameParaType)
            {
                case EGameParaType.Bet:
                    return new B_BetGamePara();
                case EGameParaType.Card:
                    return new B_CardGamePara();
                case EGameParaType.Fish:
                    return new B_FishGamePara();
                case EGameParaType.Laba:
                    return new B_LabaGamePara();
                default:
                    return null;
            }
        }
    }
}
