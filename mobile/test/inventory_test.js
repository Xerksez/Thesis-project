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
        console.log("Rozpoczęcie testu aplikacji");

        // Wprowadź e-mail
        const emailField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(0)');
        await emailField.click();
        await driver.pause(1000); // 1 sekunda
        await emailField.setValue("labuda@gmail.com");
        console.log("Email wprowadzony");

        // Wprowadź hasło
        const passwordField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(1)');
        await passwordField.click();
        await driver.pause(1000); // 1 sekunda
        await passwordField.setValue("haslo123");
        console.log("Hasło wprowadzone");

        // Kliknij "Log in"
        const loginButton = await driver.$('android=new UiSelector().description("Log in")');
        await loginButton.click();
        console.log("Kliknięto przycisk Log in");
        await driver.pause(2000); // 2 sekundy na załadowanie ekranu głównego

        // Kliknij "Build Pol"
        const buildPolButton = await driver.$('android=new UiSelector().description("Build Pol")');
        await buildPolButton.click();
        console.log("Kliknięto Build Pol");
        await driver.pause(2000); // 2 sekundy na załadowanie ekranu

        // Kliknij "Inventory"
        const inventoryButton = await driver.$('android=new UiSelector().description("Inventory")');
        await inventoryButton.click();
        console.log("Kliknięto Inventory");
        await driver.pause(2000); // 2 sekundy na załadowanie ekranu Inventory

        // Kliknij pierwszy przycisk
        const firstButton = await driver.$('android=new UiSelector().className("android.widget.Button").instance(0)');
        await firstButton.click();
        console.log("Kliknięto pierwszy przycisk");
        await driver.pause(1000); // 1 sekunda na załadowanie pola tekstowego

        // Kliknij pole tekstowe i wprowadź "15.0"
        const firstEditText = await driver.$('android=new UiSelector().className("android.widget.EditText")');
        await firstEditText.click();
        await driver.pause(1000); // 1 sekunda
        await firstEditText.clearValue(); // Wyczyść pole
        await firstEditText.setValue("13.0");
        console.log("Wprowadzono wartość: 13.0");

        // Kliknij "Save"
        const saveButton = await driver.$('android=new UiSelector().description("Save")');
        await saveButton.click();
        console.log("Kliknięto Save");
        await driver.pause(1000); // 1 sekunda na zapisanie danych

        // Kliknij pole tekstowe i wprowadź "Deski"
        const secondEditText = await driver.$('android=new UiSelector().className("android.widget.EditText")');
        await secondEditText.click();
        await driver.pause(1000); // 1 sekunda
        await secondEditText.setValue("Deski");
        console.log("Wprowadzono wartość: Deski");

        // Dodatkowa pauza na końcu testu
        await driver.pause(2000); // 2 sekundy

        console.log("Test zakończony sukcesem!");

    } catch (err) {
        console.error("Błąd podczas testu aplikacji:", err);
    } finally {
        await driver.deleteSession();
    }
})();
