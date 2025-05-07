using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebSocets;

[ApiController]
[Route("[controller]")]
public class HomeController : ControllerBase
{
      
    [HttpGet]
    public IActionResult Test()
    {
        return Ok("Test");
    }
}