using BuildBuddy.Application.Abstractions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class ConversationController : ControllerBase
    {
        private readonly IConversationService _conversationService;

        public ConversationController(IConversationService conversationService)
        {
            _conversationService = conversationService;
        }
        
        [HttpGet("all")]
        public async Task<IActionResult> GetAllConversations()
        {
            var conversations = await _conversationService.GetAllConversationsAsync();
            return Ok(conversations);
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("{conversationId}")]
        public async Task<IActionResult> GetConversationById(int conversationId)
        {
            var conversation = await _conversationService.GetConversationByIdAsync(conversationId);
            if (conversation == null)
            {
                return NotFound();
            }
            return Ok(conversation);
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpPost("create")]
        public async Task<IActionResult> CreateConversation(int user1Id, int user2Id)
        {
            var conversationId = await _conversationService.CreateConversationAsync(user1Id, user2Id);
            return Ok(new { ConversationId = conversationId });
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpPost("{conversationId}/addUser")]
        public async Task<IActionResult> AddUserToConversation(int conversationId, int userId)
        {
            await _conversationService.AddUserToConversationAsync(conversationId, userId);
            return Ok();
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("user/{userId}/conversations")]
        public async Task<IActionResult> GetUserConversations(int userId)
        {
            var conversations = await _conversationService.GetUserConversationsAsync(userId);
            if (conversations == null || !conversations.Any())
                return NotFound("No conversations found for this user.");

            return Ok(conversations);
        }
        
        
        [HttpDelete("{conversationId}")]
        public async Task<IActionResult> DeleteConversation(int conversationId)
        {
            try
            {
                await _conversationService.DeleteConversationAsync(conversationId);
                return NoContent();
            }
            catch (ArgumentException ex)
            {
                return NotFound(ex.Message);
            }
        }

    }