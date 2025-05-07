using Microsoft.AspNetCore.Authorization;

namespace BuildBuddy.Application.Services;

public class PowerLevelRequirement : IAuthorizationRequirement
{
    public int[] AllowedPowerLevels { get; }

    public PowerLevelRequirement(params int[] allowedPowerLevels)
    {
        AllowedPowerLevels = allowedPowerLevels;
    }
}


public class PowerLevelHandler : AuthorizationHandler<PowerLevelRequirement>
{
    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PowerLevelRequirement requirement)
    {
        var powerLevelClaim = context.User.Claims.FirstOrDefault(c => c.Type == "powerLevel");

        if (powerLevelClaim != null && int.TryParse(powerLevelClaim.Value, out int powerLevel))
        {
            if (requirement.AllowedPowerLevels.Contains(powerLevel))
            {
                context.Succeed(requirement);
            }
        }

        return Task.CompletedTask;
    }
}

