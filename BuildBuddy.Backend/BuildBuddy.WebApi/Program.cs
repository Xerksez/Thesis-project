using System.Text;
using BuildBuddy.Application;
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Application.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;


var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;



builder.Services.AddBuildBuddyApp(configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllOrigins", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader()
              .SetIsOriginAllowed(_ => true)
              .SetPreflightMaxAge(TimeSpan.FromMinutes(10));
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Your API", Version = "v1" });
    
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement{
    {
        new OpenApiSecurityScheme{
            Reference = new OpenApiReference{
                Id = "Bearer",
                Type = ReferenceType.SecurityScheme
            }
        }, new List<string>()
    }});
});
builder.Services.AddControllers()
    .AddNewtonsoftJson();



builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = configuration["Jwt:Issuer"],
        ValidAudience = configuration["Jwt:Issuer"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"])),
        RoleClaimType = "PowerLevel"
    };

    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            Console.WriteLine($"Authentication failed: {context.Exception.Message}");
            return Task.CompletedTask;
        },
        OnTokenValidated = context =>
        {
            Console.WriteLine("Token successfully validated.");
            return Task.CompletedTask;
        }
    };
});
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("PowerLevel1", policy =>
        policy.Requirements.Add(new PowerLevelRequirement(1)));

    options.AddPolicy("PowerLevel2", policy =>
        policy.Requirements.Add(new PowerLevelRequirement(2)));

    options.AddPolicy("PowerLevel3", policy =>
        policy.Requirements.Add(new PowerLevelRequirement(3)));

    options.AddPolicy("PowerLevel1And2", policy =>
        policy.Requirements.Add(new PowerLevelRequirement(1, 2)));

    options.AddPolicy("PowerLevel2And3", policy =>
        policy.Requirements.Add(new PowerLevelRequirement(2, 3)));

    options.AddPolicy("PowerLevelAll", policy =>
        policy.Requirements.Add(new PowerLevelRequirement(1, 2, 3)));
});


var app = builder.Build();


app.UseSwagger();
app.UseSwaggerUI();


app.UseHttpsRedirection();

// Włączenie CORS
app.UseCors("AllowAllOrigins");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
//app.Urls.Add("http://*:5088");
app.Run();