using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class TeamController : ControllerBase
    {
        private readonly ITeamService _teamService;

        public TeamController(ITeamService teamService)
        {
            _teamService = teamService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<TeamDto>>> GetAllTeams()
        {
            var teams = await _teamService.GetAllTeamsAsync();
            return Ok(teams);
        }
        
        [Authorize(Policy = "PowerLevel3")]
        [HttpGet("{id}")]
        public async Task<ActionResult<TeamDto>> GetTeamById(int id)
        {
            var team = await _teamService.GetTeamByIdAsync(id);
            if (team == null)
            {
                return NotFound();
            }
            return Ok(team);
        }

        [Authorize(Policy = "PowerLevel3")]
        [HttpPost]
        public async Task<ActionResult<TeamDto>> CreateTeam(TeamDto teamDto)
        {
            var createdTeam = await _teamService.CreateTeamAsync(teamDto);
            return CreatedAtAction(nameof(GetTeamById), new { id = createdTeam.Id }, createdTeam);
        }

        [Authorize(Policy = "PowerLevel3")]
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTeam(int id, TeamDto teamDto)
        {
            await _teamService.UpdateTeamAsync(id, teamDto);
            return NoContent();
        }
        
        [Authorize(Policy = "PowerLevel3")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTeam(int id)
        {
            await _teamService.DeleteTeamAsync(id);
            return NoContent();
        }

        [Authorize(Policy = "PowerLevel3")]
        [HttpPost("{teamId}/users/{userId}")]
        public async Task<IActionResult> AddUserToTeam(int teamId, int userId)
        {
            await _teamService.AddUserToTeamAsync(teamId, userId);
            return NoContent();
        }

        [Authorize(Policy = "PowerLevel3")]
        [HttpDelete("{teamId}/users/{userId}")]
        public async Task<IActionResult> RemoveUserFromTeam(int teamId, int userId)
        {
            await _teamService.RemoveUserFromTeamAsync(teamId, userId);
            return NoContent();
        }
        
        [Authorize(Policy = "PowerLevel2And3")]
        [HttpGet("{teamId}/users")]
        public async Task<IActionResult> GetUsersByTeamId(int teamId)
        {
            var users = await _teamService.GetUsersByTeamIdAsync(teamId);
            if (users == null || !users.Any())
            {
                return NotFound($"No users found for team with ID {teamId}.");
            }

            return Ok(users);
        }
    }

