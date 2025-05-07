using Amazon.Translate;
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Application.Services;
using BuildBuddy.Data.Repositories;
using BuildBuddy.Storage.Repository;
using Microsoft.AspNetCore.Authorization;

namespace BuildBuddy.Application;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddBuildBuddyApp(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<IBuildingArticlesService, BuildingArticlesService>()
            .AddScoped<IConversationService, ConversationService>()
            .AddScoped<IJobActualizationService, JobActualizationService>()
            .AddScoped<IJobService, JobService>()
            .AddScoped<IAddressService, AddressService>()
            .AddScoped<ITeamService, TeamService>()
            .AddScoped<IUserService, UserService>()
            .AddScoped<IChatService, ChatService>()
            .AddScoped<ITranslationService, TranslationService>()
            .AddScoped<IRoleService, RoleService>()
            .AddScoped<IAuthorizationHandler, PowerLevelHandler>()
            .AddBuildBuddyData(configuration)
            .AddStorageServices(configuration)
            .AddSingleton<AmazonTranslateClient>(sp =>
            {
                var awsOptions = new AwsOptions();
                sp.GetService<IConfiguration>().GetSection("AWS").Bind(awsOptions);

                var credentials = new Amazon.Runtime.BasicAWSCredentials(awsOptions.AccessKey, awsOptions.SecretKey);
                var config = new AmazonTranslateConfig { RegionEndpoint = Amazon.RegionEndpoint.GetBySystemName(awsOptions.Region) };

                return new AmazonTranslateClient(credentials, config);
            });
        return services;
    }

}