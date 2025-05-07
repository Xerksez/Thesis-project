
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class JobController : ControllerBase
    {
        private readonly IJobService _jobService;

        public JobController(IJobService jobService)
        {
            _jobService = jobService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobDto>>> GetAllTasks()
        {
            var tasks = await _jobService.GetAllJobsAsync();
            return Ok(tasks);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<JobDto>> GetTaskById(int id)
        {
            var task = await _jobService.GetJobIdAsync(id);
            if (task == null)
            {
                return NotFound();
            }
            return Ok(task);
        }

        [Authorize(Policy = "PowerLevel2And3")]
        [HttpPost]
        public async Task<ActionResult<JobDto>> CreateTask(JobDto jobDto)
        {
            var createdTask = await _jobService.CreateJobAsync(jobDto);
            return CreatedAtAction(nameof(GetTaskById), new { id = createdTask.Id }, createdTask);
        }
        
        [Authorize(Policy = "PowerLevel2And3")]
        [HttpPatch("{id}")]
        public async Task<IActionResult> PatchTask(int id, [FromBody] JsonPatchDocument<JobDto> patchDoc)
        {
            if (patchDoc == null)
            {
                return BadRequest("Invalid patch document.");
            }

            await _jobService.PatchJobAsync(id, patchDoc);

            return NoContent();
        }

        [Authorize(Policy = "PowerLevel2And3")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(int id)
        {
            await _jobService.DeleteJobAsync(id);
            return NoContent();
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetJobsByUserId(int userId)
        {
            var tasks = await _jobService.GetJobByUserIdAsync(userId);
            if (tasks == null || !tasks.Any())
                return NotFound("No tasks found for this user.");

            return Ok(tasks);
        }

        [Authorize(Policy = "PowerLevel2And3")]
        [HttpPost("assign")]
        public async Task<IActionResult> AssignTaskToUser(int taskId, int userId)
        {
            if (taskId <= 0 || userId <= 0)
                return BadRequest("Invalid taskId or userId.");

            try
            {
                await _jobService.AssignJobToUserAsync(taskId, userId);
                return Ok("Task successfully assigned to user.");
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        
        [Authorize(Policy = "PowerLevelAll")]
        [HttpGet("user/{userId}/address/{addressId}")]
        public async Task<IActionResult> GetJobsByUserIdAndAddressId(int userId, int addressId)
        {
            var jobs = await _jobService.GetJobByUserIdAndAddressIdAsync(userId, addressId);
            if (jobs == null || !jobs.Any())
                return NotFound("No jobs found for this user and address.");

            return Ok(jobs);
        }
        
        
        [Authorize(Policy = "PowerLevel2And3")]
        [HttpGet("address/{addressId}")]
        public async Task<IActionResult> GetJobsByAddressId(int addressId)
        {
            var jobs = await _jobService.GetJobByAddressIdAsync(addressId);
            if (jobs == null || !jobs.Any())
                return NotFound("No jobs found for this address.");

            return Ok(jobs);
        }
        
        [Authorize(Policy = "PowerLevel2And3")]
        [HttpDelete("{jobId}/user/{userId}")]
        public async Task<IActionResult> RemoveUserFromJob(int jobId, int userId)
        {
            await _jobService.RemoveUserFromJobAsync(jobId, userId);
            return NoContent();
        }
    }
