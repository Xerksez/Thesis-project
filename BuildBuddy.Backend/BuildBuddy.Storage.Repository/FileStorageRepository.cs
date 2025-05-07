using Amazon.S3;
using Amazon.S3.Model;
using BuildBuddy.Storage.Abstraction;
using Microsoft.Extensions.Options;

namespace BuildBuddy.Storage.Repository;

public class FileStorageRepository : IFileStorageRepository
{
    private readonly IAmazonS3 _s3Client;
    private readonly string _bucketName;

    public FileStorageRepository(IAmazonS3 s3Client, IOptions<AwsOptions> awsOptions)
    {
        _s3Client = s3Client;
        _bucketName = awsOptions.Value.BucketName ?? throw new ArgumentNullException(nameof(awsOptions.Value.BucketName));
    }

    public async Task<string> UploadImageAsync(Stream fileStream, string fileName, string prefix)
    {
        var fileKey = $"images/{prefix}/{fileName}";

        var request = new PutObjectRequest
        {
            BucketName = _bucketName,
            Key = fileKey,
            InputStream = fileStream,
            ContentType = "image/jpeg"
        };

        await _s3Client.PutObjectAsync(request);

        return fileKey;
    }

    public async Task<List<string>> GetFilesByPrefixAsync(string prefix)
    {
        var request = new ListObjectsV2Request
        {
            BucketName = _bucketName,
            Prefix = prefix
        };

        var response = await _s3Client.ListObjectsV2Async(request);

        return response.S3Objects
            .Select(s3Object => $"https://{_bucketName}.s3.amazonaws.com/{s3Object.Key}")
            .ToList();
    }

    
    public async Task DeleteFileAsync(string fileName)
    {
        await _s3Client.DeleteObjectAsync(new DeleteObjectRequest
        {
            BucketName = _bucketName,
            Key = fileName
        });
    }
}