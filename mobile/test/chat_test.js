const wdio = require("webdriverio");
const AppiumBy = require("appium").AppiumBy;
const opts = {
    path: "/",
    port: 4723,
    capabilities: {
        platformName: "Android",
        "appium:deviceName": "emulator-5554",
        "appium:app": "C:/Users/Xerks/OneDrive/Pulpit/BuildBuddy/mobile/build/app/outputs/flutter-apk/app-debug.apk",
        "appium:automationName": "UiAutomator2",
    },
};

(async () => {
    const driver = await wdio.remote(opts);

    try {
        console.log("Rozpoczęcie testu logowania");
        // Wprowadź e-mail
        const emailField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(0)');
        await emailField.click();
        await driver.pause(1000);
        await emailField.setValue("labuda@gmail.com");
        console.log("Email wprowadzony");

        // Wprowadź hasło
        const passwordField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(1)');
        await passwordField.click();
        await driver.pause(1000);
        await passwordField.setValue("haslo123");
        console.log("Hasło wprowadzone");

        // Kliknij przycisk logowania
        const loginButton = await driver.$('android=new UiSelector().description("Log in")');
        await loginButton.click();
        console.log("Kliknięto przycisk logowania");

        // Odczekaj na załadowanie HomeScreen
        await driver.pause(2000);

        // Kliknij przycisk "Chat"
        const chatButton = await driver.$('android=new UiSelector().description("Chat")');
        await chatButton.click();
        console.log("Kliknięto przycisk Chat");

        // Odczekaj sekundę, aby lista czatów się załadowała
        await driver.pause(1000);

        // Kliknij w opis "Group chat Kuba Wensierski, Maciej Tracz"
        const groupChat = await driver.$('android=new UiSelector().description("Group chat\nKuba Wensierski, Maciej Tracz")');
        await groupChat.click();
        console.log("Kliknięto Group chat");

        // Odczekaj sekundę, aby pole wiadomości się załadowało
        await driver.pause(1000);

        // Znajdź pole tekstowe do wpisania wiadomości
        const messageField = await driver.$('android=new UiSelector().className("android.widget.EditText")');
        await messageField.click();
        await driver.pause(1000); // Odczekaj sekundę
        await messageField.setValue("Testowa wiadomość");
        console.log("Wpisano wiadomość: Testowa wiadomość");

        // Znajdź przycisk wysyłania wiadomości i kliknij go
        const sendButton = await driver.$('android=new UiSelector().className("android.widget.Button").instance(1)');
        await sendButton.click();
        await driver.pause(2000);
        console.log("Kliknięto przycisk wysyłania wiadomości");

        console.log("Test czatu zakończony sukcesem!");

    } catch (err) {
        console.error("Błąd podczas testu logowania lub czatu:", err);
    } finally {
        await driver.deleteSession();
    }
})();
