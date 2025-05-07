using System.Linq.Expressions;

namespace BuildBuddy.Data.Abstractions;

public interface IRepository<TEntity, TId> where TEntity : class
{
    void Delete(TId id);
    void Delete(TEntity entityToDelete);
    Task<List<TEntity>> GetAsync(Expression<Func<TEntity, bool>> filter = null, Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null, string includeProperties = "");
    Task<List<TDto>> GetAsync<TDto>(Expression<Func<TEntity, TDto>> mapper, Expression<Func<TEntity, bool>> filter = null, Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null, string includeProperties = "");
    ValueTask<TEntity?> GetByID(TId id);
    void Insert(TEntity entity);
    void Update(TEntity entityToUpdate);
    Task SaveMessageAsync(TEntity message);
}