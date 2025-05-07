namespace BuildBuddy.Data;

public interface IHaveId<TId>
{
    TId Id { get; }
}