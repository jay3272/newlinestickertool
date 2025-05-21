using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using StickerApi.Services;
using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "貼圖工具 API", Version = "v1" });
});

builder.Services.AddScoped<ImageProcessingService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "貼圖工具 API v1");
        c.RoutePrefix = "swagger"; // 設定 Swagger 路徑為 /swagger
    });
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAuthorization();

app.MapControllers();

// 設定預設路由指向 index.html
app.MapGet("/", async context =>
{
    context.Response.Redirect("/index.html");
});

// 顯示啟動訊息
Console.WriteLine("\n=== 貼圖工具 API 已啟動 ===");
Console.WriteLine("請在瀏覽器中開啟以下網址：");
Console.WriteLine("https://localhost:7064");
Console.WriteLine("Swagger 文件：https://localhost:7064/swagger");
Console.WriteLine("========================\n");

// 自動開啟瀏覽器
var url = "https://localhost:7064";
try
{
    Process.Start(new ProcessStartInfo
    {
        FileName = url,
        UseShellExecute = true
    });
}
catch (Exception ex)
{
    Console.WriteLine($"無法自動開啟瀏覽器：{ex.Message}");
    Console.WriteLine($"請手動開啟網址：{url}");
}

app.Run();
