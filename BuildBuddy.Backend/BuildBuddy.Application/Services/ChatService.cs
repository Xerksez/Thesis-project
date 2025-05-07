using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

public class ChatService : IChatService
{
    private readonly IRepositoryCatalog _repositoryCatalog;
    private readonly ITranslationService _translationService;

    public ChatService(IRepositoryCatalog repositoryCatalog, ITranslationService translationService)
    {
        _repositoryCatalog = repositoryCatalog;
        _translationService = translationService;
    }

    public async Task<MessageDto> HandleIncomingMessage(int senderId, int conversationId, string text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            throw new ArgumentException("Message cannot be empty");
        }

        var userConversations = await _repositoryCatalog.UserConversations.GetAsync(
            filter: uc => uc.UserId == senderId && uc.ConversationId == conversationId
        );

        if (userConversations.Count == 0)
        {
            throw new UnauthorizedAccessException("User is not part of this conversation");
        }

        var message = new Message
        {
            SenderId = senderId,
            Text = text,
            DateTimeDate = DateTime.UtcNow,
            ConversationId = conversationId
        };

        _repositoryCatalog.Messages.Insert(message);
        await _repositoryCatalog.SaveChangesAsync();

        return new MessageDto
        {
            SenderId = senderId,
            Text = text,
            DateTimeDate = message.DateTimeDate
        };
    }

    public async Task<Dictionary<int, string>> PrepareMessageForUsers(int senderId, int conversationId, string text)
    {
        var sender = await _repositoryCatalog.Users.GetByID(senderId);
        var senderPreferredLanguage = sender.PreferredLanguage;

        var conversationUsers = await _repositoryCatalog.UserConversations.GetAsync(
            filter: uc => uc.ConversationId == conversationId
        );

        var translations = new Dictionary<int, string>();

        foreach (var userConversation in conversationUsers)
        {
            var user = await _repositoryCatalog.Users.GetByID(userConversation.UserId);
            string translatedText = text;

            if (user.Id != senderId && !string.IsNullOrEmpty(user.PreferredLanguage) && user.PreferredLanguage != senderPreferredLanguage)
            {
                translatedText = await _translationService.TranslateText(text, senderPreferredLanguage, user.PreferredLanguage);
            }
            
            translations[user.Id] = translatedText;
        }

        return translations;
    }
    
    public async Task<List<MessageDto>> GetChatHistory(int conversationId, int userId)
    {
        var messages = await _repositoryCatalog.Messages.GetAsync(
            filter: m => m.ConversationId == conversationId
        );

        var user = await _repositoryCatalog.Users.GetByID(userId);
        var preferredLanguage = user.PreferredLanguage;

        var translatedMessages = new List<MessageDto>();

        foreach (var message in messages.OrderBy(m => m.DateTimeDate))
        {
            var sender = await _repositoryCatalog.Users.GetByID(message.SenderId);
            var senderPreferredLanguage = sender.PreferredLanguage;
            string translatedText = message.Text;

            if (!string.IsNullOrEmpty(preferredLanguage) && preferredLanguage != senderPreferredLanguage)
            {
                translatedText = await _translationService.TranslateText(message.Text, senderPreferredLanguage, preferredLanguage);
            }

            translatedMessages.Add(new MessageDto
            {
                SenderId = message.SenderId,
                Text = translatedText,
                DateTimeDate = message.DateTimeDate
            });
        }

        return translatedMessages;
    }
    
    public async Task<DateTime> GetUnreadMessagesCount(int userId, int conversationId)
    {
        var userConversations = await _repositoryCatalog.UserConversations
            .GetAsync(filter: uc => uc.UserId == userId && uc.ConversationId == conversationId);

        var userConversation = userConversations.FirstOrDefault();
        if (userConversation == null)
        {
            return DateTime.MinValue;
        }
        var lastReadTime = userConversation.LastReadTime ?? DateTime.MinValue;

        var unreadMessages = await _repositoryCatalog.Messages
            .GetAsync(filter: m => m.ConversationId == conversationId && m.DateTimeDate > lastReadTime);

        return unreadMessages.LastOrDefault()?.DateTimeDate ?? DateTime.MinValue;
    }
    public async Task ResetReadStatus(int conversationId, int userId)
    {
        var userConversations = await _repositoryCatalog.UserConversations
            .GetAsync(filter: uc => uc.UserId == userId && uc.ConversationId == conversationId);

        var userConversation = userConversations.FirstOrDefault();
        if (userConversation != null)
        {
            userConversation.LastReadTime = DateTime.UtcNow;
            await _repositoryCatalog.SaveChangesAsync();
        }
    }
}