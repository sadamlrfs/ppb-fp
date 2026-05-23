// TODO [Anggota 1]: Automated UI test — Journal Flow
//
// Test cases:
//   1. Buka tab Journal
//   2. Tap FAB → form jurnal terbuka
//   3. Isi judul + konten + pilih kategori → tap Simpan
//   4. Jurnal baru muncul di list
//   5. Tap jurnal → detail terbuka
//   6. Tap edit → form pre-filled → ubah judul → simpan
//   7. Tap delete → konfirmasi → jurnal hilang dari list
//
// Semantics identifier yang perlu ditambahkan di Flutter:
//   - 'addJournalButton' (FAB)
//   - 'journalTitleField', 'journalContentField', 'saveJournalButton'
//   - 'journalItem_{id}' atau gunakan find by text

const { createDriver } = require('../helpers/driver');

describe('Journal Flow', () => {
  let driver;

  before(async () => { driver = await createDriver(); });
  after(async () => { await driver.deleteSession(); });

  // TODO: implementasi test cases
  it.skip('should create a new journal entry', async () => {
    // implement here
  });
});
