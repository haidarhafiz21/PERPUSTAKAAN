const db = require("../config/db");

const LAMA_PINJAM = 14;
const DENDA_PER_HARI = 5000;


/// ================= BOOKING =================
exports.borrowBook = async (req, res) => {
  try {
    const { user_id, book_id } = req.body;

    const check = await db.query(
      `SELECT * FROM peminjaman
       WHERE user_id = $1
       AND status IN ('booking','dipinjam','terlambat')`,
      [user_id]
    );

    if (check.rows.length > 0) {
      return res.json({
        success: false,
        message: "Masih ada peminjaman aktif"
      });
    }

    const batasAmbil = new Date(Date.now() + 60 * 60 * 1000);

    await db.query(
      `INSERT INTO peminjaman 
       (user_id, buku_id, status, batas_ambil)
       VALUES ($1,$2,'booking',$3)`,
      [user_id, book_id, batasAmbil]
    );

    res.json({
      success: true,
      batas_ambil: batasAmbil
    });

  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};


/// ================= SCAN AMBIL BUKU =================
exports.scanBorrow = async (req, res) => {
  try {
    const { user_id, book_id } = req.body;

    const booking = await db.query(
      `SELECT * FROM peminjaman
       WHERE user_id = $1
       AND buku_id = $2
       AND LOWER(status) = 'booking'
       LIMIT 1`,
      [user_id, book_id]
    );

    if (booking.rows.length === 0) {
      return res.json({ success: false, message: "Booking tidak ditemukan" });
    }

    const tanggalPinjam = new Date();
    const tanggalKembali = new Date();
    tanggalKembali.setDate(tanggalKembali.getDate() + LAMA_PINJAM);

    await db.query(
      `UPDATE peminjaman
       SET status='dipinjam',
           tanggal_pinjam=$1,
           tanggal_kembali=$2
       WHERE id=$3`,
      [tanggalPinjam, tanggalKembali, booking.rows[0].id]
    );

    await db.query(`UPDATE buku SET stok = stok - 1 WHERE id=$1`, [book_id]);

    res.json({
      success: true,
      tanggal_pinjam: tanggalPinjam,
      tanggal_kembali: tanggalKembali
    });

  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};


/// ================= RETURN =================
exports.returnBook = async (req, res) => {
  try {
    const { book_id } = req.body;

    await db.query(
      `UPDATE peminjaman
       SET status='dikembalikan'
       WHERE buku_id=$1
       AND status IN ('dipinjam','terlambat')`,
      [book_id]
    );

    await db.query(`UPDATE buku SET stok = stok + 1 WHERE id=$1`, [book_id]);

    res.json({ success: true });

  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};


/// ================= CEK TERLAMBAT =================
exports.cekTerlambat = async (req, res) => {
  try {
    await db.query(`
      UPDATE peminjaman
      SET status='terlambat'
      WHERE status='dipinjam'
      AND NOW() > tanggal_kembali
    `);

    await db.query(`
      UPDATE peminjaman
      SET denda = EXTRACT(DAY FROM NOW() - tanggal_kembali) * $1
      WHERE status='terlambat'
      AND status_bayar=false
    `, [DENDA_PER_HARI]);

    res.json({ success: true });

  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};


/// ================= STATUS AKTIF USER =================
exports.getActiveBorrow = async (req, res) => {
  try {
    const { user_id } = req.query;

    const result = await db.query(`
      SELECT p.*, b.judul
      FROM peminjaman p
      JOIN buku b ON p.buku_id = b.id
      WHERE p.user_id = $1
      AND p.status IN ('booking','dipinjam','terlambat')
      ORDER BY p.id DESC
    `, [user_id]);

    res.json(result.rows);

  } catch (err) {
    console.log(err);
    res.json([]);
  }
};


/// ================= RIWAYAT USER =================
exports.getUserBorrows = async (req, res) => {
  try {
    const id = req.params.id;

    const result = await db.query(`
      SELECT p.*, b.judul
      FROM peminjaman p
      JOIN buku b ON p.buku_id = b.id
      WHERE p.user_id=$1
      ORDER BY p.id DESC
    `, [id]);

    res.json(result.rows);

  } catch (err) {
    console.log(err);
    res.json([]);
  }
};


/// ================= ADMIN: SEMUA PEMINJAMAN =================
exports.getAllBorrows = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT p.*, u.nama_lengkap, b.judul
      FROM peminjaman p
      JOIN users u ON p.user_id = u.id
      JOIN buku b ON p.buku_id = b.id
      ORDER BY p.id DESC
    `);

    res.json(result.rows);

  } catch (err) {
    console.log(err);
    res.json([]);
  }
};


/// ================= CANCEL BOOKING OTOMATIS =================
exports.cancelExpiredBooking = async (req, res) => {
  try {
    await db.query(`
      UPDATE peminjaman
      SET status='dibatalkan'
      WHERE status='booking'
      AND NOW() > batas_ambil
    `);

    res.json({ success: true });

  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};


/// ================= ADMIN: BOOKING USER =================
exports.getUserBooking = async (req, res) => {
  try {
    const userId = req.params.user_id;

    const result = await db.query(`
      SELECT 
        p.id,
        p.user_id,
        p.buku_id,
        p.status,
        p.batas_ambil,
        b.judul,
        b.barcode
      FROM peminjaman p
      JOIN buku b ON p.buku_id = b.id
      WHERE p.user_id = $1
      AND LOWER(p.status) = 'booking'
      ORDER BY p.id DESC
      LIMIT 1
    `, [userId]);

    if (result.rows.length === 0) {
      return res.json(null);
    }

    res.json(result.rows[0]);

  } catch (err) {
    console.log(err);
    res.json(null);
  }
};


/// ================= BAYAR DENDA =================
exports.bayarDenda = async (req, res) => {
  try {
    const { peminjaman_id } = req.body;

    await db.query(`
      UPDATE peminjaman
      SET status_bayar = true,
          denda = 0
      WHERE id = $1
    `, [peminjaman_id]);

    res.json({ success: true });

  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};

/// ================= ADMIN DASHBOARD STATS =================
exports.getBorrowStats = async (req, res) => {
  try {
    const aktif = await db.query(`
      SELECT COUNT(*) FROM peminjaman
      WHERE status = 'dipinjam'
    `);

    const terlambat = await db.query(`
      SELECT COUNT(*) FROM peminjaman
      WHERE status = 'terlambat'
    `);

    res.json({
      aktif: parseInt(aktif.rows[0].count),
      terlambat: parseInt(terlambat.rows[0].count)
    });

  } catch (err) {
    console.log(err);
    res.status(500).json({
      aktif: 0,
      terlambat: 0
    });
  }
};

/// ================= ADMIN LIST AKTIF =================
exports.getActiveList = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT p.*, u.nama_lengkap, b.judul
      FROM peminjaman p
      JOIN users u ON p.user_id = u.id
      JOIN buku b ON p.buku_id = b.id
      WHERE p.status = 'dipinjam'
      ORDER BY p.tanggal_pinjam DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.log(err);
    res.json([]);
  }
};


/// ================= ADMIN LIST TERLAMBAT =================
exports.getLateList = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT p.*, u.nama_lengkap, b.judul
      FROM peminjaman p
      JOIN users u ON p.user_id = u.id
      JOIN buku b ON p.buku_id = b.id
      WHERE p.status = 'terlambat'
      ORDER BY p.tanggal_kembali ASC
    `);

    res.json(result.rows);
  } catch (err) {
    console.log(err);
    res.json([]);
  }
};

/// ================= BAYAR DENDA OFFLINE =================
exports.bayarDendaOffline = async (req, res) => {
  try {
    const { peminjaman_id, user_id, jumlah, metode } = req.body;

    await db.query(`
      INSERT INTO pembayaran_denda
      (peminjaman_id, user_id, jumlah, metode, status)
      VALUES ($1,$2,$3,$4,'lunas')
    `, [peminjaman_id, user_id, jumlah, metode]);

    await db.query(`
      UPDATE peminjaman
      SET status_bayar = true,
          denda = 0
      WHERE id = $1
    `, [peminjaman_id]);

    res.json({ success: true });

  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};

/// ================= HISTORY PEMBAYARAN =================
exports.getHistoryPembayaran = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT p.*, u.nama_lengkap, b.judul
      FROM pembayaran_denda p
      JOIN users u ON p.user_id = u.id
      JOIN peminjaman pm ON p.peminjaman_id = pm.id
      JOIN buku b ON pm.buku_id = b.id
      ORDER BY p.tanggal DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.log(err);
    res.json([]);
  }
};

/// ================= LIST DENDA =================
exports.getDendaList = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT p.id, u.nama_lengkap, b.judul, p.denda
      FROM peminjaman p
      JOIN users u ON p.user_id = u.id
      JOIN buku b ON p.buku_id = b.id
      WHERE p.denda > 0 AND p.status = 'terlambat'
      ORDER BY p.tanggal_kembali ASC
    `);

    res.json(result.rows);
  } catch (err) {
    console.log(err);
    res.json([]);
  }
};


/// ================= BAYAR DENDA OFFLINE =================
exports.bayarDendaOffline = async (req, res) => {
  try {
    const { peminjaman_id, jumlah } = req.body;

    await db.query(`
      INSERT INTO pembayaran_denda
      (peminjaman_id, jumlah, metode, status)
      VALUES ($1,$2,'cash','lunas')
    `, [peminjaman_id, jumlah]);

    await db.query(`
      UPDATE peminjaman
      SET denda = 0,
          status = 'dikembalikan'
      WHERE id = $1
    `, [peminjaman_id]);

    res.json({ success: true });
  } catch (err) {
    console.log(err);
    res.json({ success: false });
  }
};