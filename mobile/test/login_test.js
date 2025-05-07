const wdio = require("webdriverio");

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
    
        // Funkcja do logowania
        async function login(driver, email, password) {
            console.log(`Próba logowania z email: ${email} i password: ${password}`);
            
            // Wprowadź e-mail
            const emailField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(0)');
            await emailField.click();
            await driver.pause(500); // Krótka pauza
            await emailField.setValue(""); // Ustawienie pustej wartości jako alternatywa dla clear
            await emailField.addValue(email); // Wprowadzenie adresu e-mail
        
            const emailValue = await emailField.getText();
            console.log("Email field value:", emailValue);
        
            // Wprowadź hasło
            const passwordField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(1)');
            await passwordField.click();
            await driver.pause(500); // Krótka pauza
            await passwordField.setValue(""); // Ustawienie pustej wartości jako alternatywa dla clear
            await passwordField.addValue(password); // Wprowadzenie hasła
        
            const passwordValue = await passwordField.getText();
            console.log("Password field value:", passwordValue);
        
            // Kliknij przycisk logowania
            const loginButton = await driver.$('android=new UiSelector().description("Log in")');
            await loginButton.click();
        
            // Poczekaj na potencjalną odpowiedź aplikacji
            await driver.pause(2000); // Poczekaj 2 sekundy na reakcję aplikacji
        }
    
        // Test 1: Niepoprawne dane logowania
        console.log("Test 1: Niepoprawne dane logowania");
        await login(driver, "zly.email@gmail.com", "zlehaslo123");
    
        // Sprawdź, czy wyświetla się powiadomienie o błędnym logowaniu
        const errorMessage = await driver.$('android=new UiSelector().textContains("Invalid")'); // Dostosuj selektor do komunikatu w Twojej aplikacji
        if (await errorMessage.isDisplayed()) {
            console.log("Niepoprawne logowanie: poprawny komunikat o błędzie.");
        } else {
            console.error("Niepoprawne logowanie: brak komunikatu o błędzie!");
        }
    
        // Test 2: Poprawne dane logowania
        console.log("Test 2: Poprawne dane logowania");
        await login(driver, "labuda@gmail.com", "haslo123");
    
        // Sprawdź, czy nastąpiło przekierowanie na ekran główny
        const homeScreenElement = await driver.$('android=new UiSelector().description("Home")'); // Dostosuj selektor do unikalnego elementu na ekranie głównym
        if (await homeScreenElement.isDisplayed()) {
            console.log("Poprawne logowanie: przekierowanie na ekran główny powiodło się.");
        } else {
            console.error("Poprawne logowanie: brak przekierowania na ekran główny!");
        }
    
        console.log("Test logowania zakończony.");
    
    } catch (err) {
        console.error("Błąd podczas testu logowania:", err);
    }

    
})();
