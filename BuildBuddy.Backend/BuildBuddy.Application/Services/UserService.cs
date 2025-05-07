﻿using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using BuildBuddy.Storage.Abstraction;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.IdentityModel.Tokens;

namespace BuildBuddy.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IConfiguration _configuration;
        private readonly IRepositoryCatalog _dbContext;
        private readonly IFileStorageRepository _fileStorage;

        public UserService(IRepositoryCatalog dbContext, IConfiguration configuration, IFileStorageRepository fileStorage)
        {
            _dbContext = dbContext;
            _configuration = configuration;
            _fileStorage = fileStorage;
        }

        public async Task<UserDto> GetUserByIdAsync(int userId)
        {
            var user = await _dbContext.Users
                .GetAsync(
                    filter: u => u.Id == userId,
                    includeProperties: "Role"
                );

            if (user == null || !user.Any())
            {
                return null;
            }

            var userEntity = user.First();

            return new UserDto
            {
                Id = userEntity.Id,
                Name = userEntity.Name,
                Surname = userEntity.Surname,
                Mail = userEntity.Mail,
                TelephoneNr = userEntity.TelephoneNr,
                UserImageUrl = userEntity.UserImageUrl,
                PreferredLanguage = userEntity.PreferredLanguage,
                RoleId = userEntity.RoleId ?? 0,
                RoleName = userEntity.Role != null ? userEntity.Role.Name : "No Role",
                PowerLevel = userEntity.Role != null ? userEntity.Role.PowerLevel : 0
            };
        }

        public async Task<UserDto?> GetUserByEmailAsync(string email)
        {
            var user = await _dbContext.Users
                .GetAsync(
                    filter: u => u.Mail == email,
                    includeProperties: "Role"
                );

            var userEntity = user.FirstOrDefault();

            if (userEntity == null)
            {
                return null;
            }

            return new UserDto
            {
                Id = userEntity.Id,
                Name = userEntity.Name,
                Surname = userEntity.Surname,
                Mail = userEntity.Mail,
                TelephoneNr = userEntity.TelephoneNr,
                Password = userEntity.Password,
                UserImageUrl = userEntity.UserImageUrl,
                PreferredLanguage = userEntity.PreferredLanguage,
                RoleId = userEntity.RoleId ?? 0,
                RoleName = userEntity.Role != null ? userEntity.Role.Name : "No Role",
                PowerLevel = userEntity.Role != null ? userEntity.Role.PowerLevel : 0
            };
        }

        
        public async Task<IEnumerable<UserDto>> GetAllUsersAsync()
        {
            var users = await _dbContext.Users.GetAsync(includeProperties: "Role");

            return users.Select(user => new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Surname = user.Surname,
                Mail = user.Mail,
                TelephoneNr = user.TelephoneNr,
                UserImageUrl = user.UserImageUrl,
                PreferredLanguage = user.PreferredLanguage,
                RoleId = user.RoleId ?? 0,
                RoleName = user.Role != null ? user.Role.Name : "No Role",
                PowerLevel = user.Role != null ? user.Role.PowerLevel : 0
            });
        }


        public async Task<UserDto> CreateUserAsync(UserDto userDto)
        {
            var user = new User
            {
                Name = userDto.Name,
                Surname = userDto.Surname,
                TelephoneNr = userDto.TelephoneNr,
                Mail = userDto.Mail,
                Password = userDto.Password,
                UserImageUrl = userDto.UserImageUrl,
                PreferredLanguage = userDto.PreferredLanguage,
            };

            var role = await _dbContext.Roles.GetAsync(filter: r => r.PowerLevel == 1);
            var roleEntity = role.FirstOrDefault();
            if (roleEntity != null)
            {
                user.RoleId = roleEntity.Id;
            }

            _dbContext.Users.Insert(user);
            await _dbContext.SaveChangesAsync();

            userDto.Id = user.Id;
            userDto.RoleId = user.RoleId ?? 0;
            userDto.RoleName = roleEntity?.Name ?? "No Role";
            userDto.PowerLevel = roleEntity?.PowerLevel ?? 0;

            return userDto;
        }


        public async Task UpdateUserAsync(int userId, JsonPatchDocument<UserDto> patchDoc)
        {
            var user = await _dbContext.Users.GetByID(userId);

            if (user == null)
            {
                throw new KeyNotFoundException($"User with ID {userId} not found.");
            }

            var userDto = new UserDto
            {
                Name = user.Name,
                Surname = user.Surname,
                TelephoneNr = user.TelephoneNr,
                Mail = user.Mail,
                Password = user.Password,
                UserImageUrl = user.UserImageUrl,
                PreferredLanguage = user.PreferredLanguage
            };

            patchDoc.ApplyTo(userDto);

            user.Name = userDto.Name;
            user.Surname = userDto.Surname;
            user.TelephoneNr = userDto.TelephoneNr;
            user.Mail = userDto.Mail;
            user.Password = userDto.Password;
            user.UserImageUrl = userDto.UserImageUrl;
            user.PreferredLanguage = userDto.PreferredLanguage;

            await _dbContext.SaveChangesAsync();
        }
        
        public async Task DeleteUserAsync(int userId)
        {
            var user = await _dbContext.Users.GetByID(userId);
            if (user != null)
            {
                _dbContext.Users.Delete(user);
                await _dbContext.SaveChangesAsync();
            }
        }
        
        public async Task<List<TeamDto>> GetTeamsByUserId(int userId)
        {
            var teams = await _dbContext.TeamUsers.GetAsync(
                mapper: tu => new TeamDto
                {
                    Id = tu.Team.Id,
                    Name = tu.Team.Name,
                    AddressId = tu.Team.AddressId
                },
                filter: tu => tu.UserId == userId,
                includeProperties: "Team" 
            );
            return teams; 
        }
        
        public async Task UpdateUserImageAsync(int userId, Stream imageStream, string imageName)
        {
            const string prefix = "user";
            var user = await _dbContext.Users.GetByID(userId);
            if (user == null) throw new Exception("User not found");

            if (!string.IsNullOrEmpty(user.UserImageUrl))
            {
                await _fileStorage.DeleteFileAsync(user.UserImageUrl);
            }

            user.UserImageUrl = await _fileStorage.UploadImageAsync(imageStream, imageName, prefix);

            _dbContext.Users.Update(user);
            await _dbContext.SaveChangesAsync();
        }
        
        public async Task<IEnumerable<string>> GetUserImageAsync(string imageUrl)
        {
            return await _fileStorage.GetFilesByPrefixAsync(imageUrl);
        }
        
        public async Task<IEnumerable<UserDto>> GetUserByJobIdAsync(int jobId)
        {
            var users = await _dbContext.UserJobs.GetAsync(
                mapper: uj => new UserDto
                {
                    Id = uj.User.Id,
                    Name = uj.User.Name,
                    Surname = uj.User.Surname,
                    Mail = uj.User.Mail,
                    TelephoneNr = uj.User.TelephoneNr,
                    UserImageUrl = uj.User.UserImageUrl,
                    PreferredLanguage = uj.User.PreferredLanguage,
                    RoleId = uj.User.RoleId ?? 0,
                    RoleName = uj.User.Role != null ? uj.User.Role.Name : "No Role",
                    PowerLevel = uj.User.Role != null ? uj.User.Role.PowerLevel : 0
                },
                filter: uj => uj.JobId == jobId,
                includeProperties: "User.Role"
            );

            return users;
        }

        
        public string GenerateJwtToken(UserDto user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"] ?? string.Empty);

            var claims = new List<Claim>
            {
                new("id", user.Id.ToString()),
                new("mail", user.Mail),
                new("role", user.RoleName ?? string.Empty),
                new("powerLevel", user.PowerLevel.ToString())
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(8),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Issuer"],
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}
