using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;
using YYT.Entity;

namespace UnitTestProj
{
    [TestClass]
    public class GameParaTest
    {

        [TestMethod]
        public void GetBetParams()
        {
            GameParaFactory factory = new GameParaFactory(EGameParaType.Bet);
            IGamePara iquery = factory.GetGameParaQuery();
            // gameId :  10 幸运六狮
            Dictionary<string, dynamic> kv = iquery.GetGameParams(10);
            Assert.AreNotEqual(null, kv);
        }
        [TestMethod]
        public void GetFishParams()
        {
            GameParaFactory factory = new GameParaFactory(EGameParaType.Fish);
            IGamePara iquery = factory.GetGameParaQuery();
            // gameId :  6  牛魔王
            Dictionary<string, dynamic> kv = iquery.GetGameParams(6);
            Assert.AreNotEqual(null, kv);
        }
        [TestMethod]
        public void GetCardParams()
        {
            GameParaFactory factory = new GameParaFactory(EGameParaType.Card);
            IGamePara iquery = factory.GetGameParaQuery();
            // gameId :  5 火凤凰
            Dictionary<string, dynamic> kv = iquery.GetGameParams(5);
            Assert.AreNotEqual(null, kv);
        }


    }
}
