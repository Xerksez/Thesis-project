namespace BuildBuddy.Contract;

public class ConversationDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int? TeamId { get; set; }
    public List<UserDto> Users { get; set; } = new List<UserDto>();
}
