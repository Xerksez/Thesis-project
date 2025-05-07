using BuildBuddy.Application.Abstractions;
using Microsoft.AspNetCore.SignalR;

namespace BuildBuddy.WebSocets;

public class ChatHub : Hub
{
    private readonly IChatService _chatService;
    
    public ChatHub(IChatService chatService)
    {
        _chatService = chatService;
    }

     public async Task SendMessage(int senderId, int conversationId, string text)
    {
            var message = await _chatService.HandleIncomingMessage(senderId, conversationId, text);
            var translations = await _chatService.PrepareMessageForUsers(senderId, conversationId, text);
            
            foreach (var translation in translations)
            {
                var recipientId = translation.Key;

                if (recipientId == senderId)
                {
                    continue;
                }
                
                var recipient = recipientId.ToString();
                await Clients.User(recipient).SendAsync(
                    "ReceiveMessage",
                    senderId,
                    translation.Value,
                    message.DateTimeDate
                );
            }
            
            await Clients.Caller.SendAsync(
                "ReceiveMessage", 
                senderId,
                text ?? string.Empty,
                message.DateTimeDate
                );
    }

    public async Task FetchHistory(int conversationId, int userId)
    {
        var messages = await _chatService.GetChatHistory(conversationId, userId);
        await Clients.Caller.SendAsync("ReceiveHistory", messages ?? new List<object>());
    }
    
    public override async Task OnConnectedAsync()
    {
        Console.WriteLine($"Connection established: {Context.ConnectionId}");
        var conversationId = Context.GetHttpContext()?.Request.Query["conversationId"];
        var userId = Context.GetHttpContext()?.Request.Query["userId"];

        Console.WriteLine($"Conversation ID: {conversationId}, User ID: {userId} , {Context.User.Identity.Name}");

        if (!string.IsNullOrEmpty(conversationId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, conversationId);
        }

        await base.OnConnectedAsync();
    }
}