using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace YYT.BLL.EF
{
    /// <summary>与现有送牌选项一致的赔率目录。固定赔率使用实际押注计算，变动奖项标记为预估上界。</summary>
    public static class CardPrizeQuoteRules
    {
        public class Choice
        {
            public int Action { get; set; }
            public int GameId { get; set; }
            public int Value { get; set; }
            public decimal Multiplier { get; set; }
            public bool Estimated { get; set; }
            public string Name { get; set; }
        }

        private static readonly Lazy<List<Choice>> Choices = new Lazy<List<Choice>>(() =>
            JsonConvert.DeserializeObject<List<Choice>>(File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Config/card-prize-quotes.json"))));

        public static Choice Find(int action, int value)
        {
            return Choices.Value.FirstOrDefault(c => c.Action == action && c.Value == value);
        }

        public static int ActionForGame(int gameId)
        {
            var choice = Choices.Value.FirstOrDefault(c => c.GameId == gameId);
            return choice == null ? 0 : choice.Action;
        }
    }
}
