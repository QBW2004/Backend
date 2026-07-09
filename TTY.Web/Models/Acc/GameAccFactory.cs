namespace YYT.Web.Models
{
    public class GameAccContext
    {
        private IGameAcc GameAcc;

        public GameAccContext(IGameAcc gameAcc)
        {
            this.GameAcc = gameAcc;
        }

        public object GetGameAcc()
        {
            return this.GameAcc.GetAcc();
        }
    }
}