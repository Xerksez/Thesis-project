using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services;

public class RoleService : IRoleService
{
    private readonly IRepositoryCatalog _dbContext;

    public RoleService(IRepositoryCatalog dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IEnumerable<RoleDto>> GetAllRolesAsync()
    {
        return await _dbContext.Roles
            .GetAsync(role => new RoleDto
            {
                Id = role.Id,
                Name = role.Name,
                PowerLevel = role.PowerLevel
            });
    }

    public async Task<RoleDto> GetRoleByIdAsync(int id)
    {
        var role = await _dbContext.Roles.GetByID(id);

        if (role == null)
        {
            return null;
        }

        return new RoleDto
        {
            Id = role.Id,
            Name = role.Name,
            PowerLevel = role.PowerLevel
        };
    }

    public async Task<RoleDto> CreateRoleAsync(RoleDto roleDto)
    {
        var role = new Role
        {
            Name = roleDto.Name,
            PowerLevel = roleDto.PowerLevel
        };

        _dbContext.Roles.Insert(role);
        await _dbContext.SaveChangesAsync();

        roleDto.Id = role.Id;
        return roleDto;
    }

    public async Task UpdateRoleAsync(int id, RoleDto roleDto)
    {
        var role = await _dbContext.Roles.GetByID(id);

        if (role != null)
        {
            role.Name = roleDto.Name;
            role.PowerLevel = roleDto.PowerLevel;

            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task DeleteRoleAsync(int id)
    {
        var role = await _dbContext.Roles.GetByID(id);
        if (role != null)
        {
            _dbContext.Roles.Delete(role);
            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task AssignUserToRoleAsync(int userId, int roleId)
    {
        var user = await _dbContext.Users.GetByID(userId);
        if (user == null)
        {
            throw new KeyNotFoundException($"User with ID {userId} not found.");
        }

        var role = await _dbContext.Roles.GetByID(roleId);
        if (role == null)
        {
            throw new KeyNotFoundException($"Role with ID {roleId} not found.");
        }

        user.RoleId = role.Id;
        _dbContext.Users.Update(user);
        await _dbContext.SaveChangesAsync();
    }


    public async Task RemoveRoleFromUserAsync(int userId)
    {
        var user = await _dbContext.Users.GetByID(userId);
        if (user == null)
        {
            throw new KeyNotFoundException($"User with ID {userId} not found.");
        }

        user.RoleId = 0;
        _dbContext.Users.Update(user);
        await _dbContext.SaveChangesAsync();
    }

    public async Task<List<UserDto>> GetUsersByRoleIdAsync(int roleId)
    {
        var users = await _dbContext.Users.GetAsync(
            filter: u => u.RoleId == roleId,
            mapper: u => new UserDto
            {
                Id = u.Id,
                Name = u.Name,
                Surname = u.Surname,
                Mail = u.Mail,
                TelephoneNr = u.TelephoneNr,
                UserImageUrl = u.UserImageUrl,
                PreferredLanguage = u.PreferredLanguage,
                RoleId = u.RoleId ?? 0,
                RoleName = u.Role != null ? u.Role.Name : "No Role",
                PowerLevel = u.Role != null ? u.Role.PowerLevel : 0
            },
            includeProperties: "Role"
        );

        return users.ToList();
    }

}

