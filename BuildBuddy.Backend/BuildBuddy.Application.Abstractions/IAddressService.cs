
using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IAddressService
{
    Task<IEnumerable<AddressDto>> GetAllAddressesAsync();
    Task<AddressDto> GetAddressByIdAsync(int id);
    Task<AddressDto> CreateAddressAsync(AddressDto conversationDto);
    Task UpdateAddressAsync(int id, AddressDto conversationDto);
    Task DeleteAddressAsync(int id);
    Task<List<UserDto>> GetTeamMembersByAddressIdAsync(int addressId);
}