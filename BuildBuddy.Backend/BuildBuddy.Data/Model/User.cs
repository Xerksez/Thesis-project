namespace BuildBuddy.Data.Model;
public class User : IHaveId<int>
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public string Mail { get; set; }
    public string TelephoneNr { get; set; }
    public string Password { get; set; }
    public string UserImageUrl { get; set; }
    public string PreferredLanguage { get; set; }
    public int? RoleId { get; set; }
    public virtual Role? Role { get; set; }
    
    public virtual ICollection<UserJob> UserJob  { get; set; }
    public virtual ICollection<TeamUser> TeamUsers  { get; set; }
    public virtual ICollection<UserConversation> UserConversations { get; set; }
    public virtual ICollection<Message> Message { get; set; }
}