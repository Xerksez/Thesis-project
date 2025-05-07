using System.Linq.Expressions;
using BuildBuddy.Data.Abstractions;
using Microsoft.EntityFrameworkCore;

namespace BuildBuddy.Data.Repositories;

internal class MainRepository<TEntity, TId> : IRepository<TEntity, TId> where TEntity : class, IHaveId<TId>
    {
        private readonly DbSet<TEntity> _dbSet;
        private readonly BuildBuddyDbContext _dbContext;

        public MainRepository(BuildBuddyDbContext dbContext)
        {
            _dbContext = dbContext;
            _dbSet = dbContext.Set<TEntity>();
        }

        public virtual Task<List<TEntity>> GetAsync(
            Expression<Func<TEntity, bool>> filter = null,
            Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null,
            string includeProperties = "")
        {
            return GetAsync(x => x, filter, orderBy, includeProperties);
        }

        public Task<List<TDto>> GetAsync<TDto>(
            Expression<Func<TEntity, TDto>> mapper,
            Expression<Func<TEntity, bool>> filter = null,
            Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null,
            string includeProperties = "")
        {
            IQueryable<TEntity> query = _dbSet;

            if (filter != null)
            {
                query = query.Where(filter);
            }

            foreach (var includeProperty in includeProperties.Split
                (new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                query = query.Include(includeProperty);
            }
            if (orderBy != null)
                query = orderBy(query);
            

            if (typeof(TEntity) == typeof(TDto))
                return query.OfType<TDto>().ToListAsync();
            return query.Select(mapper).ToListAsync();

        }

        public virtual ValueTask<TEntity?> GetByID(TId id)
        {
            return _dbSet.FindAsync(id);
        }
        
        
        public virtual void Insert(TEntity entity)
        {
            _dbSet.Add(entity);
        }

        public virtual void Delete(TId id)
        {
            TEntity entityToDelete = _dbSet.Find(id);
            if (entityToDelete != null)
                Delete(entityToDelete);
        }

        public virtual void Delete(TEntity entityToDelete)
        {
            if (_dbContext.Entry(entityToDelete).State == EntityState.Detached)
            {
                _dbSet.Attach(entityToDelete);
            }
            _dbSet.Remove(entityToDelete);
        }

        public virtual void Update(TEntity entityToUpdate)
        {
            _dbSet.Attach(entityToUpdate);
            _dbSet.Entry(entityToUpdate).State = EntityState.Modified;
        }
        
        public async Task SaveMessageAsync(TEntity message)
        {
            _dbContext.Set<TEntity>().Add(message);
            await _dbContext.SaveChangesAsync();
        }
    }