using ImageToolkit;
using Microsoft.AspNetCore.Http;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System;

namespace StickerApi.Services
{
    public class ImageProcessingService
    {
        public async Task<byte[]> CropAsync(IFormFile file, int x, int y, int width, int height)
        {
            try
            {
                using var stream = file.OpenReadStream();
                var imageBytes = ImageHelper.NormalizeImage(stream);
                return ImageEditor.Crop(imageBytes, x, y, width, height);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("圖片裁剪失敗", ex);
            }
        }

        public async Task<byte[]> ResizeAsync(IFormFile file, int width, int height)
        {
            try
            {
                using var stream = file.OpenReadStream();
                var imageBytes = ImageHelper.NormalizeImage(stream);
                return ImageEditor.Resize(imageBytes, width, height);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("圖片縮放失敗", ex);
            }
        }

        // 你也可以加上 Rotate、Brightness、Export 等
    }
}
