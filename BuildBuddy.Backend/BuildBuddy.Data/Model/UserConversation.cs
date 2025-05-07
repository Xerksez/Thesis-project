namespace BuildBuddy.Data.Model;

public class UserConversation : IHaveId<int>
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int ConversationId { get; set; }
    public DateTime? LastReadTime { get; set; }

    public virtual User User { get; set; }
    public virtual Conversation Conversation { get; set; }
}