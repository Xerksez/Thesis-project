namespace BuildBuddy.Data.Model;

public class TeamUser : IHaveId<int>
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int TeamId { get; set; }

    public virtual User User { get; set; }
    public virtual Team Team { get; set; }
}