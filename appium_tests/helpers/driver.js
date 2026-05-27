const { remote } = require('webdriverio');

// Ganti path APK sesuai lokasi build debug kamu
const APK_PATH = 'android/app/build/outputs/flutter-apk/app-debug.apk';

const capabilities = {
  platformName: 'Android',
  'appium:deviceName': 'emulator-5554',
  'appium:automationName': 'UiAutomator2',
  'appium:app': APK_PATH,
  'appium:autoGrantPermissions': true,
  'appium:newCommandTimeout': 300,
};

async function createDriver() {
  return await remote({
    hostname: 'localhost',
    port: 4723,
    capabilities,
  });
}

module.exports = { createDriver };
