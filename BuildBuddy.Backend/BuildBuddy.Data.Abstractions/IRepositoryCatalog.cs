using BuildBuddy.Data.Model;

namespace BuildBuddy.Data.Abstractions;

public interface IRepositoryCatalog
{
    IRepository<BuildingArticles, int> BuildingArticles { get; }
    IRepository<User, int> Users { get; } 
    IRepository<Conversation, int> Conversations { get; } 
    IRepository<Message, int> Messages { get; } 
    IRepository<Address, int> Addresses { get; } 
    IRepository<JobActualization, int> JobActualizations { get; } 
    IRepository<Job, int> Jobs { get; } 
    IRepository<Team, int> Teams { get; } 
    IRepository<TeamUser, int> TeamUsers { get; } 
    IRepository<UserConversation, int> UserConversations { get; } 
    IRepository<UserJob, int> UserJobs { get; } 
    IRepository<Role, int> Roles { get; }
    

    void Dispose();
    Task SaveChangesAsync();
}