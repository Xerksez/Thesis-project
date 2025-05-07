using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using Microsoft.EntityFrameworkCore;

namespace BuildBuddy.Data.Repositories
{
    public static class ServiceCollectionsExtensions
    {
        public static IServiceCollection AddBuildBuddyData(this IServiceCollection services, IConfiguration configuration) 
        {
            return services.AddDbContext<BuildBuddyDbContext>(options =>
                    options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")))
                .AddScoped<IRepository<User, int>, MainRepository<User, int>>()
                .AddScoped<IRepository<Conversation, int>, MainRepository<Conversation, int>>()
                .AddScoped<IRepository<BuildingArticles, int>, MainRepository<BuildingArticles, int>>()
                .AddScoped<IRepository<Message, int>, MainRepository<Message, int>>()
                .AddScoped<IRepository<Address, int>, MainRepository<Address, int>>()
                .AddScoped<IRepository<JobActualization, int>, MainRepository<JobActualization, int>>()
                .AddScoped<IRepository<Job, int>, MainRepository<Job, int>>()
                .AddScoped<IRepository<Team, int>, MainRepository<Team, int>>()
                .AddScoped<IRepository<TeamUser, int>, MainRepository<TeamUser, int>>()
                .AddScoped<IRepository<User, int>, MainRepository<User, int>>()
                .AddScoped<IRepository<UserConversation, int>, MainRepository<UserConversation, int>>()
                .AddScoped<IRepository<UserJob,int>,MainRepository<UserJob,int>>()
                .AddScoped<IRepository<Role,int>,MainRepository<Role,int>>()
                .AddScoped<IRepositoryCatalog, UnitOfWork>();
        }
    }
}