using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;
using System.IO;

namespace StickerApi.Models
{
    public class CropRequest
    {
        [Required(ErrorMessage = "請選擇要裁剪的圖片")]
        [CustomFileExtensions(Extensions = new[] { ".jpg", ".jpeg", ".png", ".gif" }, ErrorMessage = "只允許上傳 jpg、jpeg、png 或 gif 格式的圖片")]
        [MaxFileSize(5 * 1024 * 1024, ErrorMessage = "圖片大小不能超過 5MB")]
        public IFormFile File { get; set; } = default!;

        [Required(ErrorMessage = "請指定 X 座標")]
        [Range(0, int.MaxValue, ErrorMessage = "X 座標必須大於或等於 0")]
        public int X { get; set; }

        [Required(ErrorMessage = "請指定 Y 座標")]
        [Range(0, int.MaxValue, ErrorMessage = "Y 座標必須大於或等於 0")]
        public int Y { get; set; }

        [Required(ErrorMessage = "請指定寬度")]
        [Range(1, int.MaxValue, ErrorMessage = "寬度必須大於 0")]
        public int Width { get; set; }

        [Required(ErrorMessage = "請指定高度")]
        [Range(1, int.MaxValue, ErrorMessage = "高度必須大於 0")]
        public int Height { get; set; }
    }

    // 自定義檔案副檔名驗證屬性
    public class CustomFileExtensionsAttribute : ValidationAttribute
    {
        public string[] Extensions { get; set; } = Array.Empty<string>();

        public CustomFileExtensionsAttribute()
        {
        }

        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value is IFormFile file)
            {
                var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (!Extensions.Contains(extension))
                {
                    return new ValidationResult(ErrorMessage);
                }
            }
            return ValidationResult.Success;
        }
    }

    // 檔案大小驗證屬性
    public class MaxFileSizeAttribute : ValidationAttribute
    {
        private readonly int _maxFileSize;
        public MaxFileSizeAttribute(int maxFileSize)
        {
            _maxFileSize = maxFileSize;
        }

        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value is IFormFile file)
            {
                if (file.Length > _maxFileSize)
                {
                    return new ValidationResult(ErrorMessage ?? $"最大檔案大小為 {_maxFileSize} bytes");
                }
            }
            return ValidationResult.Success;
        }
    }
}
