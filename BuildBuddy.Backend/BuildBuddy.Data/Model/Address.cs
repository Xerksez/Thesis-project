namespace BuildBuddy.Data.Model;

public class Address : IHaveId<int>
{
    public int Id { get; set; }
    public string City { get; set; }
    public string Country { get; set; }
    public string Street { get; set; }
    public string HouseNumber { get; set; }
    public string LocalNumber { get; set; }
    public string PostalCode { get; set; }
    public string Description { get; set; }
    
    public virtual Team Team { get; set; }
    public virtual ICollection<BuildingArticles> BuildingArticles { get; set; }
}