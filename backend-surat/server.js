const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const cors = require("cors");

const app = express();
const PORT = 3000;

// Middleware
app.use(cors({
  origin: "*", // izinkan semua origin
  methods: ["GET","POST","PUT","DELETE"],
  allowedHeaders: ["Content-Type"]
}));
app.use(express.json());

// Buat database SQLite
const db = new sqlite3.Database("./surat.db", (err) => {
  if (err) {
    console.error("Gagal konek DB:", err.message);
  } else {
    console.log("Berhasil konek ke database SQLite.");
  }
});

// Buat tabel surat kalau belum ada
db.run(`CREATE TABLE IF NOT EXISTS surat (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    jenis TEXT,
    nomor TEXT,
    perihal TEXT,
    tanggal TEXT,
    pengirim TEXT,
    penerima TEXT,
    isi TEXT
)`);

// ➡️ Simpan surat baru
app.post("/surat", (req, res) => {
  const { jenis, nomor, perihal, tanggal, pengirim, penerima, isi } = req.body;

  db.run(
    `INSERT INTO surat (jenis, nomor, perihal, tanggal, pengirim, penerima, isi) 
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [jenis, nomor, perihal, tanggal, pengirim, penerima, isi],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ message: "Surat berhasil disimpan", id: this.lastID });
    }
  );
});

// ➡️ Ambil semua surat (dengan filter opsional)
app.get("/surat", (req, res) => {
  const { jenis } = req.query;
  let query = "SELECT * FROM surat";
  let params = [];

  if (jenis) {
    query += " WHERE jenis = ?";
    params.push(jenis);
  }

  db.all(query, params, (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// ➡️ Ambil surat berdasarkan ID
app.get("/surat/:id", (req, res) => {
  const { id } = req.params;
  db.get("SELECT * FROM surat WHERE id = ?", [id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: "Surat tidak ditemukan" });
    res.json(row);
  });
});

// ➡️ Update surat
app.put("/surat/:id", (req, res) => {
  const { id } = req.params;
  const { jenis, nomor, perihal, tanggal, pengirim, penerima, isi } = req.body;

  db.run(
    `UPDATE surat 
     SET jenis = ?, nomor = ?, perihal = ?, tanggal = ?, pengirim = ?, penerima = ?, isi = ?
     WHERE id = ?`,
    [jenis, nomor, perihal, tanggal, pengirim, penerima, isi, id],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      if (this.changes === 0) {
        return res.status(404).json({ error: "Surat tidak ditemukan" });
      }
      res.json({ message: "Surat berhasil diperbarui" });
    }
  );
});

// ➡️ Hapus surat
app.delete("/surat/:id", (req, res) => {
  const { id } = req.params;
  db.run("DELETE FROM surat WHERE id = ?", [id], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    if (this.changes === 0) {
      return res.status(404).json({ error: "Surat tidak ditemukan" });
    }
    res.json({ message: "Surat berhasil dihapus" });
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server jalan di http://localhost:${PORT}`);
});
