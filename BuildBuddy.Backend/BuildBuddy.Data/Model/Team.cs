namespace BuildBuddy.Data.Model;

public class Team : IHaveId<int>
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int? AddressId { get; set; }
    
    public virtual Address? Address { get; set; }

    public virtual ICollection<TeamUser> TeamUsers { get; set; }
    public virtual Conversation Conversation { get; set; }
}