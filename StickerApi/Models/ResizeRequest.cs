using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace StickerApi.Models
{
    public class ResizeRequest
    {
        [Required(ErrorMessage = "請選擇要調整大小的圖片")]
        [CustomFileExtensions(Extensions = new[] { ".jpg", ".jpeg", ".png", ".gif" }, ErrorMessage = "只允許上傳 jpg、jpeg、png 或 gif 格式的圖片")]
        [MaxFileSize(5 * 1024 * 1024, ErrorMessage = "圖片大小不能超過 5MB")]
        public IFormFile File { get; set; } = default!;

        [Required(ErrorMessage = "請指定寬度")]
        [Range(1, int.MaxValue, ErrorMessage = "寬度必須大於 0")]
        public int Width { get; set; }

        [Required(ErrorMessage = "請指定高度")]
        [Range(1, int.MaxValue, ErrorMessage = "高度必須大於 0")]
        public int Height { get; set; }
    }
}