namespace BuildBuddy.Data.Model;

public class UserJob : IHaveId<int>
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int JobId { get; set; }

    public virtual User User { get; set; }
    public virtual Job Job { get; set; }
}