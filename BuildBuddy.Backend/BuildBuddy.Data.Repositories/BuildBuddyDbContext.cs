using System.Globalization;
using BuildBuddy.Data.Model;
using Microsoft.EntityFrameworkCore;

namespace BuildBuddy.Data.Repositories;

public class BuildBuddyDbContext : DbContext
{
    public BuildBuddyDbContext(DbContextOptions<BuildBuddyDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Team> Teams { get; set; }
    public DbSet<Conversation> Conversations { get; set; }
    public DbSet<UserConversation> UserConversations { get; set; }
    public DbSet<Message> Messages { get; set; }
    public DbSet<Job> Job { get; set; }
    public DbSet<JobActualization> JobActualization { get; set; }
    public DbSet<BuildingArticles> BuildingArticles { get; set; }
    public DbSet<Address> Address { get; set; }
    public DbSet<UserJob> UserJob { get; set; }
    public DbSet<Role> Role { get; set; }
}