using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("gamecommandoutbox")]
    public class M_GameCommandOutbox
    {
        [Key]
        public string CommandId { get; set; }
        public string CommandType { get; set; }
        public string TargetUserId { get; set; }
        public string Payload { get; set; }
        public int Status { get; set; }
        public string RawResponse { get; set; }
        public string ErrorMessage { get; set; }
        public int RetryCount { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? SentAt { get; set; }
        public DateTime? LastTriedAt { get; set; }
        public DateTime? NextRetryAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
