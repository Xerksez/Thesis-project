using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services
{
    public class TeamService : ITeamService
    {
        private readonly IRepositoryCatalog _dbContext;
        private readonly IConversationService _conversationService;

        public TeamService(IRepositoryCatalog dbContext, IConversationService conversationService)
        {
            _dbContext = dbContext;
            _conversationService = conversationService;
        }

        public async Task<IEnumerable<TeamDto>> GetAllTeamsAsync()
        {
            return await _dbContext.Teams
                .GetAsync(team => new TeamDto
                {
                    Id = team.Id,
                    Name = team.Name,
                    AddressId = team.AddressId
                });
        }

        public async Task<TeamDto> GetTeamByIdAsync(int id)
        {
            var team = await _dbContext.Teams
                .GetByID(id);

            if (team == null)
            {
                return null;
            }

            return new TeamDto
            {
                Id = team.Id,
                Name = team.Name,
                AddressId = team.AddressId
            };
        }

        public async Task<TeamDto> CreateTeamAsync(TeamDto teamDto)
        {
            if (!teamDto.AddressId.HasValue)
            {
                throw new ArgumentException("AddressId is null.");
            }

            var existingTeam = await _dbContext.Teams.GetAsync(
                filter: t => t.AddressId == teamDto.AddressId.Value
            );

            if (existingTeam.Any())
            {
                throw new InvalidOperationException("A team with this AddressId already exists.");
            }

            var address = await _dbContext.Addresses.GetByID(teamDto.AddressId.Value);
            if (address == null)
            {
                throw new ArgumentException("Address not found.");
            }

            var team = new Team
            {
                Name = teamDto.Name,
                AddressId = teamDto.AddressId
            };

            _dbContext.Teams.Insert(team);
            await _dbContext.SaveChangesAsync();

            var conversation = new Conversation
            {
                Name = $"{address.Street}{address.HouseNumber}{address.City}",
                TeamId = team.Id
            };

            _dbContext.Conversations.Insert(conversation);
            await _dbContext.SaveChangesAsync();

            teamDto.Id = team.Id;
            return teamDto;
        }


        public async Task UpdateTeamAsync(int id, TeamDto teamDto)
        {
            var team = await _dbContext.Teams.GetByID(id);

            if (team != null)
            {
                team.Name = teamDto.Name;
                team.AddressId = teamDto.AddressId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteTeamAsync(int id)
        {
            var team = await _dbContext.Teams.GetByID(id);
            if (team != null)
            {
                var conversations = await _dbContext.Conversations.GetAsync(filter: c => c.TeamId == id);
                foreach (var conversation in conversations)
                {
                    _dbContext.Conversations.Delete(conversation);
                }

                var jobs = await _dbContext.Jobs.GetAsync(filter: j => j.Id == id);
                foreach (var job in jobs)
                {
                    var jobActualizations = await _dbContext.JobActualizations.GetAsync(filter: ja => ja.JobId == job.Id);
                    foreach (var jobActualization in jobActualizations)
                    {
                        _dbContext.JobActualizations.Delete(jobActualization);
                    }
                    _dbContext.Jobs.Delete(job);
                }

                var address = await _dbContext.Addresses.GetByID(team.AddressId.Value);
                if (address != null)
                {
                    _dbContext.Addresses.Delete(address);
                }

                _dbContext.Teams.Delete(team);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task AddUserToTeamAsync(int teamId, int userId)
        {
            var team = (await _dbContext.Teams.GetAsync(
                filter: t => t.Id == teamId,
                includeProperties: "TeamUsers"
            )).FirstOrDefault();

            if (team != null && !team.TeamUsers.Any(tu => tu.UserId == userId))
            {
                team.TeamUsers.Add(new TeamUser
                {
                    TeamId = teamId,
                    UserId = userId
                });

                await _dbContext.SaveChangesAsync();

                var conversations = await _dbContext.Conversations.GetAsync(filter: t=> t.TeamId ==teamId);
                foreach (var conversation in conversations)
                {
                    await _conversationService.AddUserToConversationAsync(conversation.Id, userId);
                }
            }
        }

        public async Task RemoveUserFromTeamAsync(int teamId, int userId)
        {
            var team = (await _dbContext.Teams.GetAsync(
                filter: t => t.Id == teamId,
                includeProperties: "TeamUsers"
            )).FirstOrDefault();

            if (team == null)
            {
                throw new InvalidOperationException($"Team with ID {teamId} not found.");
            }

            var teamUser = team.TeamUsers.FirstOrDefault(tu => tu.UserId == userId);
            if (teamUser == null)
            {
                throw new InvalidOperationException($"User with ID {userId} is not part of the team.");
            }

            team.TeamUsers.Remove(teamUser);
            await _dbContext.SaveChangesAsync();
        }


        public async Task<List<UserDto>> GetUsersByTeamIdAsync(int teamId)
        {
            var usersWithRoles = await _dbContext.TeamUsers.GetAsync(
                filter: tu => tu.TeamId == teamId,
                mapper: tu => new UserDto
                {
                    Id = tu.User.Id,
                    Name = tu.User.Name,
                    Surname = tu.User.Surname,
                    Mail = tu.User.Mail,
                    Password = tu.User.Password,
                    TelephoneNr = tu.User.TelephoneNr,
                    UserImageUrl = tu.User.UserImageUrl,
                    PreferredLanguage = tu.User.PreferredLanguage,
                    RoleId = tu.User.RoleId ?? 0,
                    RoleName = tu.User.Role != null ? tu.User.Role.Name : "No Role", 
                    PowerLevel = tu.User.Role != null ? tu.User.Role.PowerLevel : 0 
                },
                includeProperties: "User.Role"
            );

            return usersWithRoles.ToList();
        }
    }
}
