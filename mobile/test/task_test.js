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

        // Kliknij przycisk "Log in"
        const loginButton = await driver.$('android=new UiSelector().description("Log in")');
        await loginButton.click();
        console.log("Kliknięto przycisk logowania");
        await driver.pause(2000); // 2 sekundy na załadowanie ekranu głównego

        // Kliknij "Build Pol"
        const buildPolButton = await driver.$('android=new UiSelector().description("Build Pol")');
        await buildPolButton.click();
        console.log("Kliknięto Build Pol");
        await driver.pause(2000); // 2 sekundy na załadowanie ekranu

        // Kliknij "Calendar"
        const calendarButton = await driver.$('android=new UiSelector().description("Calendar")');
        await calendarButton.click();
        console.log("Kliknięto Calendar");
        await driver.pause(2000); // 2 sekundy na załadowanie kalendarza

        // Kliknij dzień "poniedziałek, 20 stycznia 2025"
        const dayElement = await driver.$('android=new UiSelector().description("poniedziałek, 20 stycznia 2025")');
        await dayElement.click();
        console.log("Kliknięto dzień w kalendarzu");
        await driver.pause(2000); // 2 sekundy na załadowanie dnia

        // Kliknij aktywność "malowanie"
        const activityElement = await driver.$('android=new UiSelector().description("malowanie\nhours: 2025-01-09 16:47 - 2025-01-19 16:47")');
        await activityElement.click();
        console.log("Kliknięto aktywność malowanie");
        await driver.pause(2000); // 2 sekundy na załadowanie szczegółów aktywności

        // Kliknij "Add actualization"
        const addActualizationButton = await driver.$('android=new UiSelector().description("Add actualization")');
        await addActualizationButton.click();
        console.log("Kliknięto Add actualization");
        await driver.pause(1000); // 1 sekunda na załadowanie pola tekstowego

        // Wprowadź tekst "skończyłem malować"
        const actualizationField = await driver.$('android=new UiSelector().className("android.widget.EditText")');
        await actualizationField.click();
        await driver.pause(1000); // 1 sekunda
        await actualizationField.setValue("skończyłem malować");
        console.log("Wpisano: skończyłem malować");

        // Zamknij klawiaturę
        await driver.back();
        console.log("Zamknięto klawiaturę");

        // Kliknij "Save"
        const saveButton = await driver.$('android=new UiSelector().description("Save")');
        await saveButton.click();
        console.log("Kliknięto Save");

        console.log("Test zakończony sukcesem!");

    } catch (err) {
        console.error("Błąd podczas testu aplikacji:", err);
    } finally {
        await driver.deleteSession();
    }
})();
