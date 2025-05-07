namespace BuildBuddy.Application.Abstractions;

public interface ITranslationService
{
    Task<string> TranslateText(string text, string sourceLanguage, string targetLanguage);
}
