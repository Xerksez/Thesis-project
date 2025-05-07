using BuildBuddy.Application;
using BuildBuddy.WebSocets;
using Microsoft.AspNetCore.SignalR;

var builder = WebApplication.CreateBuilder(args);


var configuration = builder.Configuration;

builder.Services.AddBuildBuddyApp(configuration);

builder.Services.AddSignalR();
builder.Services.AddSingleton<IUserIdProvider, QueryStringUserIdProvider>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});


var app = builder.Build();

app.UseRouting();
app.UseCors("CorsPolicy");

app.MapHub<ChatHub>("/Chat");

app.Run();
