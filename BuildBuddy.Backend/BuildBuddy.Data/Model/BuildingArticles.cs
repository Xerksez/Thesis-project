namespace BuildBuddy.Data.Model;

public class BuildingArticles : IHaveId<int>
{
    public int Id { get; set; }
    public string Name { get; set; }
    public double QuantityMax { get; set; }
    public string Metrics { get; set; }
    public double QuantityLeft { get; set; }
    public int? AddressId { get; set; }

    public virtual Address? Address { get; set; }
}