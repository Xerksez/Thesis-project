using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using Microsoft.AspNetCore.JsonPatch;


namespace BuildBuddy.Application.Services
{
    public class JobService : IJobService
    {
        private readonly IRepositoryCatalog _dbContext;

        public JobService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<JobDto>> GetAllJobsAsync()
        {
            return await _dbContext.Jobs
                .GetAsync(t => new JobDto
                {
                    Id = t.Id,
                    Name = t.Name,
                    Message = t.Message,
                    StartTime = t.StartTime,
                    EndTime = t.EndTime,
                    AllDay = t.AllDay,
                    AddressId = t.AddressId ?? 0
                });
        }

        public async Task<JobDto> GetJobIdAsync(int id)
        {
            var task = await _dbContext.Jobs
                .GetByID(id);

            if (task == null)
            {
                return null;
            }

            return new JobDto
            {
                Id = task.Id,
                Name = task.Name,
                Message = task.Message,
                StartTime = task.StartTime,
                EndTime = task.EndTime,
                AllDay = task.AllDay,
                AddressId = task.AddressId ?? 0
            };
        }

        public async Task<JobDto> CreateJobAsync(JobDto jobDto)
        {
            var job = new Job()
            {
                Name = jobDto.Name,
                Message = jobDto.Message,
                StartTime = jobDto.StartTime,
                EndTime = jobDto.EndTime,
                AllDay = jobDto.AllDay,
                AddressId = jobDto.AddressId
            };

            _dbContext.Jobs.Insert(job);
            await _dbContext.SaveChangesAsync();
            jobDto.Id = job.Id;
            return jobDto;
        }

        public async Task PatchJobAsync(int id, JsonPatchDocument<JobDto> patchDoc)
        {
            var job = await _dbContext.Jobs.GetByID(id);

            if (job == null)
            {
                throw new KeyNotFoundException($"Job with ID {id} not found.");
            }

            var jobDto = new JobDto
            {
                Id = job.Id,
                Name = job.Name,
                Message = job.Message,
                StartTime = job.StartTime,
                EndTime = job.EndTime,
                AllDay = job.AllDay,
                AddressId = job.AddressId ?? 0
            };

            patchDoc.ApplyTo(jobDto);

            job.Name = jobDto.Name;
            job.Message = jobDto.Message;
            job.StartTime = jobDto.StartTime;
            job.EndTime = jobDto.EndTime;
            job.AllDay = jobDto.AllDay;
            job.AddressId = jobDto.AddressId;

            await _dbContext.SaveChangesAsync();
        }
        
        public async Task DeleteJobAsync(int id)
        {
            var job = await _dbContext.Jobs.GetByID(id);
            if (job != null)
            {
                var jobActualizations = await _dbContext.JobActualizations.GetAsync(
                    filter: ja => ja.JobId == id
                );

                foreach (var jobActualization in jobActualizations)
                {
                    _dbContext.JobActualizations.Delete(jobActualization);
                }

                _dbContext.Jobs.Delete(job);
                await _dbContext.SaveChangesAsync();
            }
        }
        
        public async Task<IEnumerable<JobDto>> GetJobByUserIdAsync(int userId)
        {
            var tasks = await _dbContext.UserJobs.GetAsync(
                    mapper: t => new JobDto
                    {
                        Id = t.Job.Id,
                        Name = t.Job.Name,
                        Message = t.Job.Message,
                        StartTime = t.Job.StartTime,
                        EndTime = t.Job.EndTime,
                        AllDay = t.Job.AllDay,
                        AddressId = t.Job.AddressId ?? 0
                    },
                    filter:ut => ut.UserId == userId,
                    includeProperties: "Job");

            return tasks;
        }
        public async Task AssignJobToUserAsync(int taskId, int userId)
        {
            var task = await _dbContext.Jobs.GetByID(taskId);
            if (task == null)
                throw new Exception("Task not found");

            var user = await _dbContext.Users.GetByID(userId);
            if (user == null)
                throw new Exception("User not found");

            var existingAssignments = await _dbContext.UserJobs.GetAsync(
                filter: ut => ut.JobId == taskId && ut.UserId == userId
            );

            if (existingAssignments.Any())
                throw new Exception("Task is already assigned to this user");

            var userTask = new UserJob
            {
                JobId = taskId,
                UserId = userId
            };

            _dbContext.UserJobs.Insert(userTask);
            await _dbContext.SaveChangesAsync();
        }
        public async Task<IEnumerable<JobDto>> GetJobByUserIdAndAddressIdAsync(int userId, int addressId)
        {
            var jobs = await _dbContext.UserJobs.GetAsync(
                mapper: uj => new JobDto
                {
                    Id = uj.Job.Id,
                    Name = uj.Job.Name,
                    Message = uj.Job.Message,
                    StartTime = uj.Job.StartTime,
                    EndTime = uj.Job.EndTime,
                    AllDay = uj.Job.AllDay,
                    AddressId = uj.Job.AddressId ?? 0
                },
                filter: uj => uj.UserId == userId && uj.Job.AddressId == addressId,
                includeProperties: "Job"
            );

            return jobs;
        }
        public async Task<IEnumerable<JobDto>> GetJobByAddressIdAsync(int addressId)
        {
            var jobs = await _dbContext.Jobs.GetAsync(
                mapper: j => new JobDto
                {
                    Id = j.Id,
                    Name = j.Name,
                    Message = j.Message,
                    StartTime = j.StartTime,
                    EndTime = j.EndTime,
                    AllDay = j.AllDay,
                    AddressId = j.AddressId ?? 0
                },
                filter: j => j.AddressId == addressId
            );

            return jobs;
        }
        public async Task RemoveUserFromJobAsync(int jobId, int userId)
        {
            var userJob = await _dbContext.UserJobs.GetAsync(
                filter: uj => uj.JobId == jobId && uj.UserId == userId
            );

            if (userJob != null)
            {
                _dbContext.UserJobs.Delete(userJob.FirstOrDefault());
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
