using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using Microsoft.EntityFrameworkCore;

namespace BuildBuddy.Application.Services;

public class ConversationService : IConversationService
{
    private readonly IRepositoryCatalog _context;

    public ConversationService(IRepositoryCatalog context)
    {
        _context = context;
    }

    public async Task AddUserToConversationAsync(int conversationId, int userId)
    {
        var conversation = await _context.Conversations.GetByID(conversationId);
        var user = await _context.Users.GetByID(userId);

        if (conversation == null || user == null)
        throw new ArgumentException("Invalid conversation or user.");

        conversation.UserConversations.Add(new UserConversation
        {
            ConversationId = conversationId,
            UserId = userId
        });

        await _context.SaveChangesAsync();
    }
    public async Task<int> CreateConversationAsync(int user1Id, int user2Id)
    {
        var user1 = await _context.Users.GetByID(user1Id);
        var user2 = await _context.Users.GetByID(user2Id);

        if (user1 == null || user2 == null)
        {
            throw new ArgumentException("One or both users not found.");
        }
        
        var conversation = new Conversation
        {
            Name = $"Conversation_{user1Id}_{user2Id}",
        };
        _context.Conversations.Insert(conversation);
        await _context.SaveChangesAsync();

        await AddUserToConversationAsync(conversation.Id, user1Id);
        await AddUserToConversationAsync(conversation.Id, user2Id);

        return conversation.Id;
    }
    
    public async Task<List<ConversationDto>> GetAllConversationsAsync()
    {
        var conversations = await _context.Conversations.GetAsync(
            includeProperties: "UserConversations.User"
        );

        return conversations.Select(c => new ConversationDto
        {
            Id = c.Id,
            Name = c.Name,
            TeamId = c.TeamId,
            Users = c.UserConversations.Select(uc => new UserDto
            {
                Id = uc.User.Id,
                Name = uc.User.Name,
                Surname = uc.User.Surname,
                Mail = uc.User.Mail,
                TelephoneNr = uc.User.TelephoneNr,
                UserImageUrl = uc.User.UserImageUrl,
                PreferredLanguage = uc.User.PreferredLanguage,
            }).ToList()
        }).ToList();
    }

    public async Task<ConversationDto> GetConversationByIdAsync(int conversationId)
    {
        var conversation = await _context.Conversations.GetAsync(
            filter: c => c.Id == conversationId,
            includeProperties: "UserConversations.User"
        );

        var entity = conversation.FirstOrDefault();

        if (conversation == null) return null;

        return new ConversationDto
        {
            Id = entity.Id,
            Name = entity.Name,
            TeamId = entity.TeamId,
            Users = entity.UserConversations.Select(uc => new UserDto
            {
                Id = uc.User.Id,
                Name = uc.User.Name,
                Surname = uc.User.Surname,
                Mail = uc.User.Mail,
                TelephoneNr = uc.User.TelephoneNr,
                UserImageUrl = uc.User.UserImageUrl,
                PreferredLanguage = uc.User.PreferredLanguage,
            }).ToList()
        };
    }
    public async Task<List<ConversationDto>> GetUserConversationsAsync(int userId)
    {
        var conversations = await _context.Conversations.GetAsync(
            filter: c => c.UserConversations.Any(uc => uc.UserId == userId),
            includeProperties: "UserConversations.User"
        );

        return conversations.Select(c => new ConversationDto
        {
            Id = c.Id,
            Name = c.Name,
            TeamId = c.TeamId,
            Users = c.UserConversations.Select(uc => new UserDto
            {
                Id = uc.User.Id,
                Name = uc.User.Name,
                Surname = uc.User.Surname,
                Mail = uc.User.Mail,
                TelephoneNr = uc.User.TelephoneNr,
                UserImageUrl = uc.User.UserImageUrl,
                PreferredLanguage = uc.User.PreferredLanguage,
            }).ToList()

        }).ToList();
    }
    public async Task<List<UserDto>> GetConversationUsersAsync(int conversationId)
    {
        var conversation = await _context.Conversations.GetAsync(
            filter: c => c.Id == conversationId,
            includeProperties: "UserConversations.User"
        );

        var entity = conversation.FirstOrDefault();

        if (entity == null)
        {
            throw new ArgumentException("Conversation not found");
        }

        return entity.UserConversations.Select(uc => new UserDto
        {
            Id = uc.User.Id,
            Name = uc.User.Name,
            Surname = uc.User.Surname,
            Mail = uc.User.Mail,
            TelephoneNr = uc.User.TelephoneNr,
            UserImageUrl = uc.User.UserImageUrl,
            PreferredLanguage = uc.User.PreferredLanguage
        }).ToList();
    }
    public async Task DeleteConversationAsync(int conversationId)
    {
        var conversation = await _context.Conversations.GetByID(conversationId);

        if (conversation == null)
        {
            throw new ArgumentException("Conversation not found.");
        }

        _context.Conversations.Delete(conversation);
        await _context.SaveChangesAsync();
    }
}