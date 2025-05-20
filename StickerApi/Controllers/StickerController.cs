using Microsoft.AspNetCore.Mvc;
using StickerApi.Models;
using StickerApi.Services;

namespace StickerApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StickerController : ControllerBase
    {
        private readonly ImageProcessingService _imageService;

        public StickerController(ImageProcessingService imageService)
        {
            _imageService = imageService;
        }

        [HttpPost("crop")]
        public async Task<IActionResult> Crop([FromForm] CropRequest req)
        {
            var result = await _imageService.CropAsync(req.File, req.X, req.Y, req.Width, req.Height);
            return File(result, "image/png");
        }

        [HttpPost("resize")]
        public async Task<IActionResult> Resize([FromForm] ResizeRequest req)
        {
            var result = await _imageService.ResizeAsync(req.File, req.Width, req.Height);
            return File(result, "image/png");
        }

        [HttpGet("ping")]
        public IActionResult Ping()
        {
            return Ok("Sticker API is working!");
        }

    }
}
