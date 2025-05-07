namespace BuildBuddy.Contract;

public class UserDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public string Mail { get; set; }
    public string TelephoneNr { get; set; }
    public string Password { get; set; }
    public string UserImageUrl { get; set; }
    public string PreferredLanguage { get; set; }
    public int RoleId { get; set; }
    public string RoleName { get; set; }
    public int PowerLevel { get; set; }
}