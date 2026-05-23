// TODO [Semua]: Automated UI test — Authentication Flow
//
// Test cases:
//   1. Login berhasil dengan email + password valid
//   2. Login gagal dengan password salah (cek error banner muncul)
//   3. Navigasi ke halaman Register dan kembali
//   4. Navigasi ke Forgot Password dan kirim email reset
//
// Semantics identifier yang digunakan:
//   - 'emailField'    → input email
//   - 'passwordField' → input password
//   - 'loginButton'   → tombol masuk
//   - 'homeTitle'     → AppBar title di HomePage (sebagai verifikasi login berhasil)
//
// Tips: tambahkan Semantics(identifier: '...') di widget Flutter,
// lalu locate dengan driver.$('//*[@content-desc="..."]')

const { createDriver } = require('../helpers/driver');
const { expect } = require('chai');

describe('Authentication Flow', () => {
  let driver;

  before(async () => { driver = await createDriver(); });
  after(async () => { await driver.deleteSession(); });

  it('should login successfully with valid credentials', async () => {
    const emailField = await driver.$('//*[@content-desc="emailField"]');
    await emailField.setValue('test@mindease.com');

    const passwordField = await driver.$('//*[@content-desc="passwordField"]');
    await passwordField.setValue('password123');

    const loginBtn = await driver.$('//*[@content-desc="loginButton"]');
    await loginBtn.click();

    const homeTitle = await driver.$('//*[@content-desc="homeTitle"]');
    await homeTitle.waitForDisplayed({ timeout: 10000 });
    expect(await homeTitle.isDisplayed()).to.be.true;
  });

  // TODO: tambahkan test case lain di sini
});
