using Microsoft.AspNetCore.SignalR;

namespace BuildBuddy.WebSocets;

public class QueryStringUserIdProvider : IUserIdProvider
{
    private readonly ILogger<QueryStringUserIdProvider> _logger;

    public QueryStringUserIdProvider(ILogger<QueryStringUserIdProvider> logger)
    {
        _logger = logger;
    }

    public string GetUserId(HubConnectionContext connection)
    {
        var userId = connection.GetHttpContext()?.Request.Query["userId"].ToString();
        _logger.LogInformation("Mapping connection {ConnectionId} to userId {UserId}", 
            connection.ConnectionId, userId);
        return userId;
    }
}