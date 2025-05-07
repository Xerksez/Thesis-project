using System.Security.Claims;
using BuildBuddy.Application.Abstractions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;

    public ChatController(IChatService chatService)
    {
        _chatService = chatService;
    }
    
    
    [Authorize(Policy = "PowerLevelAll")]
    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadMessagesCount(int conversationId, int userId)
    {
        var time = await _chatService.GetUnreadMessagesCount(userId, conversationId);
        return Ok(new { Time = time });
    }
    
    
    [Authorize(Policy = "PowerLevelAll")]
    [HttpPost("exit-chat")]
    public async Task<IActionResult> ExitChat(int conversationId, int userId)
    {
        await _chatService.ResetReadStatus(conversationId, userId);
        return Ok();
    }
  
}