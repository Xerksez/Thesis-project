using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Data.Repositories;

public class UnitOfWork(BuildBuddyDbContext buildBuddyDb, 
    IRepository<User, int> users, 
    IRepository<Conversation, int> conversations, 
    IRepository<BuildingArticles, int> buildingArticles, 
    IRepository<Message, int> messages, 
    IRepository<Address, int> address, 
    IRepository<JobActualization, int> jobActualizations,
    IRepository<Job, int> jobs, 
    IRepository<Team, int> teams, 
    IRepository<TeamUser, int> teamUsers, 
    IRepository<UserConversation, int> userConversations,
    IRepository<Role, int> role,
    IRepository<UserJob,int> userJob) : IDisposable, IRepositoryCatalog
{
    private readonly BuildBuddyDbContext _context = buildBuddyDb;

    public IRepository<BuildingArticles, int> BuildingArticles { get; } = buildingArticles;
    public IRepository<User, int> Users { get; } = users;
    public IRepository<Conversation, int> Conversations { get; } = conversations;
    public IRepository<Message, int> Messages { get; } = messages;
    public IRepository<Address, int> Addresses { get; } = address;
    public IRepository<JobActualization, int> JobActualizations { get; } = jobActualizations;
    public IRepository<Job, int> Jobs { get; } = jobs;
    public IRepository<Team, int> Teams { get; } = teams;
    public IRepository<TeamUser, int> TeamUsers { get; } = teamUsers;
    public IRepository<UserConversation, int> UserConversations { get; } = userConversations;
    public IRepository<UserJob, int> UserJobs { get; } = userJob;
    public IRepository<Role, int> Roles { get; } = role;

    


    public Task SaveChangesAsync()
    {
        return _context.SaveChangesAsync();
    }

    private bool disposed = false;

    protected virtual void Dispose(bool disposing)
    {
        if (!disposed)
        {
            if (disposing)
            {
                _context.Dispose();
            }
        }
        disposed = true;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
}