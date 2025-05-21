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
        private readonly ILogger<StickerController> _logger;

        public StickerController(ImageProcessingService imageService, ILogger<StickerController> logger)
        {
            _imageService = imageService;
            _logger = logger;
        }

        [HttpPost("crop")]
        public async Task<IActionResult> Crop([FromForm] CropRequest req)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(new { 
                        title = "驗證失敗",
                        errors = ModelState.Values
                            .SelectMany(v => v.Errors)
                            .Select(e => e.ErrorMessage)
                    });
                }

                var result = await _imageService.CropAsync(req.File, req.X, req.Y, req.Width, req.Height);
                return File(result, "image/png");
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex, "圖片裁剪失敗");
                return StatusCode(500, new { title = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "圖片裁剪發生未預期的錯誤");
                return StatusCode(500, new { title = "圖片處理失敗，請稍後再試" });
            }
        }

        [HttpPost("resize")]
        public async Task<IActionResult> Resize([FromForm] ResizeRequest req)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(new { 
                        title = "驗證失敗",
                        errors = ModelState.Values
                            .SelectMany(v => v.Errors)
                            .Select(e => e.ErrorMessage)
                    });
                }

                var result = await _imageService.ResizeAsync(req.File, req.Width, req.Height);
                return File(result, "image/png");
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex, "圖片縮放失敗");
                return StatusCode(500, new { title = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "圖片縮放發生未預期的錯誤");
                return StatusCode(500, new { title = "圖片處理失敗，請稍後再試" });
            }
        }

        [HttpGet("ping")]
        public IActionResult Ping()
        {
            return Ok("Sticker API is working!");
        }
    }
}
