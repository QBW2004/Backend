namespace YYT.Web.Models
{
    public class GameAccContext
    {
        private IVGameAcc GameAcc;

        public GameAccContext(IVGameAcc gameAcc)
        {
            this.GameAcc = gameAcc;
        }

        public object GetGameAcc()
        {
            return this.GameAcc.GetAcc();
        }
    }
}