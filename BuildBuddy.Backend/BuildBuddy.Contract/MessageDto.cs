namespace BuildBuddy.Contract;

public class MessageDto
{
    public int Id { get; set; }
    public int SenderId { get; set; }
    public string Text { get; set; }
    public DateTime DateTimeDate { get; set; }
    public int ConversationId { get; set; }
}