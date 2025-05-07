namespace BuildBuddy.Storage.Repository;

public class AwsOptions
{
    public string Region { get; set; }    
    public string AccessKey { get; set; }
    public string SecretKey { get; set; }
    public string BucketName { get; set; }
}