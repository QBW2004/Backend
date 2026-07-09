using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 图片
    /// </summary>
    [Table("UploadsImage")]
    public class M_UploadsImage
    {
     
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }
 
        public string ImageName { get; set; }
     
        public string ImagePath { get; set; }
        public string ImageType { get; set; }

    
    }
    public class UploadsImageList
    {
        public long ID { get; set; }
        public string ImageName { get; set; }

        public string ImagePath { get; set; }


    }

}
