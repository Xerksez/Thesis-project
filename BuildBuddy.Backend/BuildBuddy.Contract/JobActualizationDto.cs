namespace BuildBuddy.Contract;

public class JobActualizationDto
{
    public int Id { get; set; }
    public string Message { get; set; }
    public bool IsDone { get; set; }
    public List<string> JobImageUrl { get; set; }
    public int? JobId { get; set; }
    
}