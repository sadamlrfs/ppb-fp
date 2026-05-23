// TODO [Anggota 3]: Automated UI test — AI Chat Flow
//
// Test cases:
//   1. Buka tab Meditasi → sub-tab AI Companion
//   2. Tap FAB "Chat Baru" → masuk ke ChatRoomPage
//   3. Ketik pesan → tap kirim → tunggu respons AI muncul
//   4. Kembali ke list → percakapan muncul
//   5. Rename percakapan
//   6. Hapus percakapan → konfirmasi → hilang dari list
//
// Semantics identifier yang perlu ditambahkan di Flutter:
//   - 'newChatButton' (FAB)
//   - 'chatInputField', 'sendMessageButton'
//   - 'chatBubble_{index}' (opsional, untuk verifikasi respons muncul)

const { createDriver } = require('../helpers/driver');

describe('AI Chat Flow', () => {
  let driver;

  before(async () => { driver = await createDriver(); });
  after(async () => { await driver.deleteSession(); });

  // TODO: implementasi test cases
  it.skip('should send a message and receive AI response', async () => {
    // implement here
  });
});
