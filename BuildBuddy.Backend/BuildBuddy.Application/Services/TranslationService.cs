using Amazon.Translate;
using Amazon.Translate.Model;
using BuildBuddy.Application.Abstractions;

public class TranslationService : ITranslationService
{
    private readonly AmazonTranslateClient _translateClient;

    public TranslationService(AmazonTranslateClient translateClient)
    {
        _translateClient = translateClient;
    }

    public async Task<string> TranslateText(string text, string sourceLanguage, string targetLanguage)
    {
        var request = new TranslateTextRequest
        {
            Text = text,
            SourceLanguageCode = sourceLanguage,
            TargetLanguageCode = targetLanguage
        };

        var response = await _translateClient.TranslateTextAsync(request);
        return response.TranslatedText;
    }
}