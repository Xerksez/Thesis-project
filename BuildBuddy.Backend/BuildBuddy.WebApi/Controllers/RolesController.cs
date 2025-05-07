using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;


    [ApiController]
    [Route("api/[controller]")]
    public class RolesController : ControllerBase
    {
        private readonly IRoleService _roleService;

        public RolesController(IRoleService roleService)
        {
            _roleService = roleService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<RoleDto>>> GetAllRoles()
        {
            var roles = await _roleService.GetAllRolesAsync();
            return Ok(roles);
        }

        [Authorize(Policy = "PowerLevel2And3")]
        [HttpGet("{id}")]
        public async Task<ActionResult<RoleDto>> GetRoleById(int id)
        {
            var role = await _roleService.GetRoleByIdAsync(id);
            if (role == null)
            {
                return NotFound();
            }
            return Ok(role);
        }
        
        [Authorize(Policy = "PowerLevel3")]
        [HttpPost]
        public async Task<ActionResult<RoleDto>> CreateRole([FromBody] RoleDto roleDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var createdRole = await _roleService.CreateRoleAsync(roleDto);
            return CreatedAtAction(nameof(GetRoleById), new { id = createdRole.Id }, createdRole);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRole(int id, [FromBody] RoleDto roleDto)
        {
            if (id != roleDto.Id)
            {
                return BadRequest("ID roli nie pasuje do ID w danych.");
            }

            var existingRole = await _roleService.GetRoleByIdAsync(id);
            if (existingRole == null)
            {
                return NotFound();
            }

            await _roleService.UpdateRoleAsync(id, roleDto);
            return NoContent();
        }

        
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRole(int id)
        {
            var existingRole = await _roleService.GetRoleByIdAsync(id);
            if (existingRole == null)
            {
                return NotFound();
            }

            await _roleService.DeleteRoleAsync(id);
            return NoContent();
        }
        
        [Authorize(Policy = "PowerLevel3")]
        [HttpPost("{roleId}/users/{userId}")]
        public async Task<IActionResult> AssignRoleToUser(int roleId, int userId)
        {
            var role = await _roleService.GetRoleByIdAsync(roleId);
            if (role == null)
            {
                return NotFound($"Rola o ID {roleId} nie została znaleziona.");
            }

            await _roleService.AssignUserToRoleAsync(userId, roleId);
            return Ok();
        }

        [Authorize(Policy = "PowerLevel3")]
        [HttpDelete("{roleId}/users/{userId}")]
        public async Task<IActionResult> RemoveRoleFromUser(int userId)
        {
            await _roleService.RemoveRoleFromUserAsync(userId);
            return Ok();
        }

        
        [HttpGet("role/{roleId}")]
        public async Task<IActionResult> GetUsersByRoleIdAsync(int roleId)
        {
            try
            {
                var users = await _roleService.GetUsersByRoleIdAsync(roleId);
                if (users == null || !users.Any())
                {
                    return NotFound(new { message = "No users found for the specified role ID." });
                }

                return Ok(users);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while processing your request.", error = ex.Message });
            }
        }
    }