using ImageToolkit;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

public class ImageProcessingService
{
    public async Task<byte[]> CropAsync(IFormFile file, int x, int y, int width, int height)
    {
        using var stream = file.OpenReadStream();
        var image = Image.Load<Rgba32>(stream);
        var cropped = ImageHelper.Crop(image, x, y, width, height);
        return ImageHelper.ExportToPng(cropped);
    }

    public async Task<byte[]> ResizeAsync(IFormFile file, int width, int height)
    {
        using var stream = file.OpenReadStream();
        var image = Image.Load<Rgba32>(stream);
        var resized = ImageHelper.Resize(image, width, height);
        return ImageHelper.ExportToPng(resized);
    }

    // 你也可以加上 Rotate、Brightness、Export 等
}
