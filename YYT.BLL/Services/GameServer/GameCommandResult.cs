using System;

namespace YYT.BLL.Services.GameServer
{
    public class GameCommandResult
    {
        public string Command { get; set; }
        public string CommandId { get; set; }
        public string TargetUserId { get; set; }
        public string RawResponse { get; set; }
        public string Message { get; set; }
        public int Code { get; set; }
        public bool Accepted { get; set; }
        public bool Executed { get; set; }
        public DateTime CreatedAt { get; set; }

        public GameCommandResult()
        {
            CreatedAt = DateTime.Now;
        }

        public static GameCommandResult Fail(string command, string targetUserId, string message, string rawResponse = null)
        {
            return new GameCommandResult
            {
                Command = command,
                TargetUserId = targetUserId,
                RawResponse = rawResponse,
                Message = message,
                Code = 0,
                Accepted = false,
                Executed = false
            };
        }

        public static GameCommandResult Success(string command, string targetUserId, string message, string rawResponse)
        {
            return new GameCommandResult
            {
                Command = command,
                TargetUserId = targetUserId,
                RawResponse = rawResponse,
                Message = message,
                Code = 1,
                Accepted = true,
                Executed = true
            };
        }
    }
}
