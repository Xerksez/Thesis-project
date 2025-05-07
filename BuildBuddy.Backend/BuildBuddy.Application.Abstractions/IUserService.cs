
using BuildBuddy.Contract;
using Microsoft.AspNetCore.JsonPatch;

namespace BuildBuddy.Application.Abstractions;

public interface IUserService
{
    Task<UserDto> GetUserByIdAsync(int userId);
    Task<UserDto?> GetUserByEmailAsync(string email);
    Task<IEnumerable<UserDto>> GetAllUsersAsync();
    Task<UserDto> CreateUserAsync(UserDto userDto);
    Task UpdateUserAsync(int userId, JsonPatchDocument<UserDto> patchDoc);
    Task DeleteUserAsync(int userId);
    Task<List<TeamDto>> GetTeamsByUserId(int userId);
    Task UpdateUserImageAsync(int userId, Stream imageStream, string imageName);
    Task<IEnumerable<string>> GetUserImageAsync(string imageUrl);
    Task<IEnumerable<UserDto>> GetUserByJobIdAsync(int jobId);
    string GenerateJwtToken(UserDto user);
}