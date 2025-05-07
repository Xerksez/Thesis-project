
using Microsoft.AspNetCore.Mvc;
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Authorization;

namespace BuildBuddy.WebApi.Controllers;
    [Route("api/[controller]")]
    [ApiController]
    public class AddressController : ControllerBase
    {
        private readonly IAddressService _addressService;

        public AddressController(IAddressService addressService)
        {
            _addressService = addressService;
        }

        [HttpGet]
        [Authorize(Policy = "PowerLevelAll")]
        public async Task<ActionResult<IEnumerable<AddressDto>>> GetAllPlaces()
        {
            var places = await _addressService.GetAllAddressesAsync();
            return Ok(places);
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("{id}")]
        public async Task<ActionResult<AddressDto>> GetPlaceById(int id)
        {
            var place = await _addressService.GetAddressByIdAsync(id);
            if (place == null)
            {
                return NotFound();
            }
            return Ok(place);
        }

        [Authorize(Policy = "PowerLevel3")]
        [HttpPost]
        public async Task<ActionResult<AddressDto>> CreatePlace(AddressDto addressDto)
        {
            var createdPlace = await _addressService.CreateAddressAsync(addressDto);
            return CreatedAtAction(nameof(GetPlaceById), new { id = createdPlace.Id }, createdPlace);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePlace(int id, AddressDto addressDto)
        {
            await _addressService.UpdateAddressAsync(id, addressDto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePlace(int id)
        {
            await _addressService.DeleteAddressAsync(id);
            return NoContent();
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("{addressId}/teammembers")]
        public async Task<ActionResult<List<UserDto>>> GetTeamMembersByAddressId(int addressId)
        {
            var teamMembers = await _addressService.GetTeamMembersByAddressIdAsync(addressId);
            if (teamMembers == null || !teamMembers.Any())
            {
                return NotFound();
            }
            return Ok(teamMembers);
        }
    }
