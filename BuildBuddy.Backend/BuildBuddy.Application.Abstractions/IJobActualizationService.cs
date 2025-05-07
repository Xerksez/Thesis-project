using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IJobActualizationService
{
    Task<IEnumerable<JobActualizationDto>> GetAllJobsActualizationAsync();
   Task<List<JobActualizationDto>> GetJobActualizationByIdAsync(int id);

    Task<JobActualizationDto> CreateJobActualizationAsync(JobActualizationDto conversationDto);
    Task UpdateJobActualizationAsync(int id, JobActualizationDto conversationDto);
    Task DeleteJobActualizationAsync(int id);
    Task AddJobImageAsync(int taskId, Stream imageStream, string imageName);
    Task<IEnumerable<string>> GetJobImagesAsync(int taskId);
    Task RemoveJobImageAsync(int taskId, string imageUrl);
    Task ToggleJobActualizationStatusAsync(int jobActualizationId);
}