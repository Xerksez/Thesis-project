﻿
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetAllUsers()
        {
            var users = await _userService.GetAllUsersAsync();
            return Ok(users);
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("{id}")]
        public async Task<ActionResult<UserDto>> GetUserById(int id)
        {
            var user = await _userService.GetUserByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }

        [Authorize(Policy = "PowerLevel3")]
        [HttpPost]
        public async Task<ActionResult<UserDto>> CreateUser(UserDto userDto)
        {
            var createdUser = await _userService.CreateUserAsync(userDto);
            return CreatedAtAction(nameof(GetUserById), new { id = createdUser.Id }, createdUser);
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpPatch("{id}")]
        public async Task<IActionResult> PatchUser(int id, [FromBody] JsonPatchDocument<UserDto> patchDoc)
        {
            if (patchDoc == null)
            {
                return BadRequest("Invalid patch document.");
            }

            try
            {
                await _userService.UpdateUserAsync(id, patchDoc);
                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
        
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            await _userService.DeleteUserAsync(id);
            return NoContent();
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("{id}/teams")]
        public async Task<ActionResult<IEnumerable<TeamDto>>> GetUserTeams(int id)
        {
            var teams = await _userService.GetTeamsByUserId(id);
            if (teams.Count == 0)
            {
                return NotFound($"No teams found for user with ID {id}.");
            }

            return Ok(teams);
        }
        
        [HttpPost("register")]
        public async Task<IActionResult> Register(UserDto userDto)
        {
            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(userDto.Password);
            userDto.Password = hashedPassword;

            var createdUser = await _userService.CreateUserAsync(userDto);
            return CreatedAtAction(nameof(GetUserById), new { id = createdUser.Id }, createdUser);
        }
        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDto loginDto)
        {
            var user = await _userService.GetUserByEmailAsync(loginDto.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.Password))
            {
                return Unauthorized();
            }

            var token = _userService.GenerateJwtToken(user);
            return Ok(new { token, user.Id});
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpPost("{userId}/upload-image")]
        public async Task<IActionResult> UploadUserImage(int userId, IFormFile image)
        {
            using var stream = image.OpenReadStream();
            await _userService.UpdateUserImageAsync(userId, stream, image.FileName);
            return NoContent();
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("{userId}/image")]
        public async Task<IActionResult> GetUserImage(int userId)
        {
            var user = await _userService.GetUserByIdAsync(userId);
            if (user == null || string.IsNullOrEmpty(user.UserImageUrl))
            {
                return NotFound("User or image not found.");
            }

            var image = await _userService.GetUserImageAsync(user.UserImageUrl);
            if (image == null)
            {
                return NotFound("Image not found.");
            }

            return Ok(image);
        }
        
        [Authorize(Policy = "PowerLevel2And3")]
        [HttpGet("job/{jobId}")]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetUsersByJobId(int jobId)
        {
            var users = await _userService.GetUserByJobIdAsync(jobId);
            if (users == null || !users.Any())
            {
                return NotFound($"No users found for job with ID {jobId}.");
            }
            return Ok(users);
        }
    }