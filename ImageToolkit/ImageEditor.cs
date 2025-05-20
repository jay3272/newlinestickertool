using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

namespace ImageToolkit
{
    public static class ImageEditor
    {
        /// <summary>
        /// 裁切圖片
        /// </summary>
        public static byte[] Crop(byte[] imageBytes, int x, int y, int width, int height)
        {
            using var image = Image.Load<Rgba32>(imageBytes);
            image.Mutate(ctx => ctx.Crop(new Rectangle(x, y, width, height)));
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }

        /// <summary>
        /// 縮放圖片至指定大小
        /// </summary>
        public static byte[] Resize(byte[] imageBytes, int width, int height)
        {
            using var image = Image.Load<Rgba32>(imageBytes);
            image.Mutate(ctx => ctx.Resize(width, height));
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }

        /// <summary>
        /// 旋轉圖片（角度順時針）
        /// </summary>
        public static byte[] Rotate(byte[] imageBytes, float angle)
        {
            using var image = Image.Load<Rgba32>(imageBytes);
            image.Mutate(ctx => ctx.Rotate(angle));
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }

        /// <summary>
        /// 調整圖片亮度（-100 ~ 100）
        /// </summary>
        public static byte[] AdjustBrightness(byte[] imageBytes, int brightness)
        {
            float b = brightness / 100f;
            using var image = Image.Load<Rgba32>(imageBytes);
            image.Mutate(ctx => ctx.Brightness(1 + b));
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }

        /// <summary>
        /// 調整圖片對比度（-100 ~ 100）
        /// </summary>
        public static byte[] AdjustContrast(byte[] imageBytes, int contrast)
        {
            float c = contrast / 100f;
            using var image = Image.Load<Rgba32>(imageBytes);
            image.Mutate(ctx => ctx.Contrast(1 + c));
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }

        /// <summary>
        /// 將白色背景轉為透明（容差 0~255）
        /// </summary>
        public static byte[] MakeWhiteTransparent(byte[] imageBytes, byte tolerance = 10)
        {
            using var image = Image.Load<Rgba32>(imageBytes);
            image.Mutate(ctx =>
            {
                for (int y = 0; y < image.Height; y++)
                {
                    for (int x = 0; x < image.Width; x++)
                    {
                        var pixel = image[x, y];
                        if (pixel.R >= 255 - tolerance && pixel.G >= 255 - tolerance && pixel.B >= 255 - tolerance)
                        {
                            image[x, y] = new Rgba32(pixel.R, pixel.G, pixel.B, 0);
                        }
                    }
                }
            });

            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }
        
        /// <summary>
        /// 套用灰階濾鏡
        /// </summary>
        public static byte[] ApplyGrayscale(byte[] imageBytes)
        {
            using var image = Image.Load<Rgba32>(imageBytes);
            image.Mutate(ctx => ctx.Grayscale());
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }

    }

    public static class ImageHelper
    {
        /// <summary>
        /// 驗證圖片格式是否有效，並轉為統一格式
        /// </summary>
        public static byte[] NormalizeImage(Stream inputStream)
        {
            using var image = Image.Load<Rgba32>(inputStream); // 讀取並解析圖片格式
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder()); // 轉存為 PNG 格式
            return ms.ToArray(); // 回傳 byte[]
        }

        /// <summary>
        /// 將 ImageSharp Image 輸出為 PNG 格式 byte[]
        /// </summary>
        public static byte[] ExportToPng(Image<Rgba32> image)
        {
            using var ms = new MemoryStream();
            image.Save(ms, new PngEncoder());
            return ms.ToArray();
        }

        /// <summary>
        /// 從 byte[] 載入 Image 物件（供外部使用）
        /// </summary>
        public static Image<Rgba32> LoadImage(byte[] imageBytes)
        {
            return Image.Load<Rgba32>(imageBytes);
        }
    }

}
