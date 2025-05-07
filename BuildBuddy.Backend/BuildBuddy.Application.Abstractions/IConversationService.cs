
using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IConversationService
{
    Task AddUserToConversationAsync(int conversationId, int userId);
    Task<int> CreateConversationAsync(int user1Id, int user2Id);
    Task<List<ConversationDto>> GetAllConversationsAsync();
    Task<ConversationDto> GetConversationByIdAsync(int conversationId);
    Task<List<ConversationDto>> GetUserConversationsAsync(int userId);
    Task<List<UserDto>> GetConversationUsersAsync(int conversationId);
    Task DeleteConversationAsync(int conversationId);
}