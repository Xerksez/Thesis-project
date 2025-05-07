namespace BuildBuddy.Data.Model;

public class Job : IHaveId<int>
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Message { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public bool AllDay { get; set; }
    public int? AddressId {get; set;}
    public virtual ICollection<UserJob> UserJob  { get; set; }
    public virtual ICollection<JobActualization> JobActualization { get; set; }
    public virtual Address Address { get; set; }
}