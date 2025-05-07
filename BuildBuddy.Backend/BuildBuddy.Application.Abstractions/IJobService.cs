using BuildBuddy.Contract;
using Microsoft.AspNetCore.JsonPatch;

namespace BuildBuddy.Application.Abstractions;

public interface IJobService
{
    Task<IEnumerable<JobDto>> GetAllJobsAsync();
    Task<JobDto> GetJobIdAsync(int id);
    Task<JobDto> CreateJobAsync(JobDto conversationDto);
    Task PatchJobAsync(int id, JsonPatchDocument<JobDto> patchDoc);
    Task DeleteJobAsync(int id);
    Task<IEnumerable<JobDto>> GetJobByUserIdAsync(int userId);
    Task AssignJobToUserAsync(int taskId, int userId);
    Task<IEnumerable<JobDto>> GetJobByUserIdAndAddressIdAsync(int userId, int addressId);
    Task<IEnumerable<JobDto>> GetJobByAddressIdAsync(int addressId);
    Task RemoveUserFromJobAsync(int jobId, int userId);

}