using Microsoft.AspNetCore.Mvc;

namespace StickerApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StickerController : ControllerBase
    {
        [HttpGet("ping")]
        public IActionResult Ping()
        {
            return Ok("Sticker API is working!");
        }
    }
}
