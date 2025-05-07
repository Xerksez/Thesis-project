namespace BuildBuddy.Storage.Abstraction;

public interface IFileStorageRepository
{
    Task<string> UploadImageAsync(Stream fileStream, string fileName, string prefix);
    Task<List<string>> GetFilesByPrefixAsync(string prefix);
    Task DeleteFileAsync(string fileName);
}