namespace BuildBuddy.Data.Model;

public class Role : IHaveId<int>
{
    public int Id { get; set; }
    public string Name { get; set; } 
    public int PowerLevel { get; set; }
    public virtual ICollection<User> Users { get; set; }
}