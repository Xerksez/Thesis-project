namespace BuildBuddy.Data.Model;

public class JobActualization : IHaveId<int>
{
    public int Id { get; set; }
    public int ImageId { get; set; }
    public string Message { get; set; }
    public bool IsDone { get; set; }
    public List<string>? JobImageUrl { get; set; }
    public int? JobId { get; set; }
    public virtual Job Job { get; set; }
}