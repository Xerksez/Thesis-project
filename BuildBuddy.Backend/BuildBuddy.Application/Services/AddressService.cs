using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services
{
    public class AddressService : IAddressService
    {
        private readonly IRepositoryCatalog _dbContext;

        public AddressService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<AddressDto>> GetAllAddressesAsync()
        {
            return await _dbContext.Addresses
                .GetAsync(place => new AddressDto
                {
                    Id = place.Id,
                    City = place.City,
                    Country = place.Country,
                    Street = place.Street,
                    HouseNumber = place.HouseNumber,
                    LocalNumber = place.LocalNumber,
                    PostalCode = place.PostalCode,
                    Description = place.Description
                });
        }

        public async Task<AddressDto> GetAddressByIdAsync(int id)
        {
            var place = await _dbContext.Addresses
                .GetByID(id);

            if (place == null)
            {
                return null;
            }

            return new AddressDto
            {
                Id = place.Id,
                City = place.City,
                Country = place.Country,
                Street = place.Street,
                HouseNumber = place.HouseNumber,
                LocalNumber = place.LocalNumber,
                PostalCode = place.PostalCode,
                Description = place.Description
            };
        }

        public async Task<AddressDto> CreateAddressAsync(AddressDto addressDto)
        {
            var place = new Address
            {
                Id = addressDto.Id,
                City = addressDto.City,
                Country = addressDto.Country,
                Street = addressDto.Street,
                HouseNumber = addressDto.HouseNumber,
                LocalNumber = addressDto.LocalNumber,
                PostalCode = addressDto.PostalCode,
                Description = addressDto.Description
            };

            _dbContext.Addresses.Insert(place);
            await _dbContext.SaveChangesAsync();

            addressDto.Id = place.Id;
            return addressDto;
        }

        public async Task UpdateAddressAsync(int id, AddressDto addressDto)
        {
            var place = await _dbContext.Addresses.GetByID(id);

            if (place != null)
            {
                place.City = addressDto.City;
                place.Country = addressDto.Country;
                place.Street = addressDto.Street;
                place.HouseNumber = addressDto.HouseNumber;
                place.LocalNumber = addressDto.LocalNumber;
                place.PostalCode = addressDto.PostalCode;
                place.Description = addressDto.Description;
                
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteAddressAsync(int id)
        {
            var place = await _dbContext.Addresses.GetByID(id);
            if (place != null)
            {
                _dbContext.Addresses.Delete(place);
                await _dbContext.SaveChangesAsync();
            }
        }
        public async Task<List<UserDto>> GetTeamMembersByAddressIdAsync(int addressId)
        {
            var teams = await _dbContext.Teams.GetAsync(
                filter: t => t.AddressId == addressId,
                includeProperties: "TeamUsers.User.Role"
            );

            if (teams == null || !teams.Any())
            {
                return new List<UserDto>();
            }

            var users = teams
                .Where(t => t.TeamUsers != null)
                .SelectMany(t => t.TeamUsers)
                .Where(tu => tu.User != null)
                .Select(tu => new UserDto
                {
                    Id = tu.User.Id,
                    Name = tu.User.Name,
                    Surname = tu.User.Surname,
                    Mail = tu.User.Mail,
                    TelephoneNr = tu.User.TelephoneNr,
                    UserImageUrl = tu.User.UserImageUrl,
                    PreferredLanguage = tu.User.PreferredLanguage,
                    RoleId = tu.User.RoleId ?? 0, 
                    RoleName = tu.User.Role != null ? tu.User.Role.Name : "No Role", 
                    PowerLevel = tu.User.Role != null ? tu.User.Role.PowerLevel : 0
                })
                .DistinctBy(u => u.Id)
                .ToList();

            return users;
        }

    }
}
