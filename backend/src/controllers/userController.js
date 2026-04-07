const db = require('../config/db');

/// =================================
/// AMBIL SEMUA ANGGOTA
/// =================================
exports.getMembers = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        u.id,
        u.nama_lengkap,
        u.email,
        u.foto_wajah,
        p.status,
        p.batas_ambil
      FROM users u
      LEFT JOIN peminjaman p 
        ON u.id = p.user_id
        AND p.status = 'booking'
      WHERE u.role IN ('publik','pegawai')
      ORDER BY 
        CASE 
          WHEN p.status = 'booking' THEN 0
          ELSE 1
        END,
        u.nama_lengkap ASC
    `);

    res.json(result.rows);

  } catch (err) {
    console.error("GET MEMBERS ERROR:", err);
    res.status(500).json({
      message: "Gagal mengambil data anggota"
    });
  }
};


/// =================================
/// SEARCH ANGGOTA
/// =================================
exports.searchUser = async (req, res) => {
  try {
    const q = req.query.q || '';

    const result = await db.query(`
      SELECT 
        id,
        nama_lengkap,
        email,
        foto_wajah
      FROM users
      WHERE role IN ('publik','pegawai')
      AND (
        LOWER(nama_lengkap) LIKE LOWER($1)
        OR LOWER(email) LIKE LOWER($1)
      )
      ORDER BY nama_lengkap ASC
    `, [`%${q}%`]);

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({
      message: "Gagal mencari user"
    });
  }
};


/// =================================
/// GET PROFILE
/// =================================
exports.getProfile = async (req, res) => {
  try {
    const userId = req.params.id;

    const result = await db.query(`
      SELECT id, nama_lengkap, email, alamat, role, saldo
      FROM users
      WHERE id = $1
    `, [userId]);

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({
      message: "Gagal mengambil profil"
    });
  }
};


/// =================================
/// UPDATE FOTO WAJAH
/// =================================
exports.updateFace = async (req, res) => {
  try {
    const { user_id, foto_wajah } = req.body;

    await db.query(`
      UPDATE users
      SET foto_wajah = $1
      WHERE id = $2
    `, [foto_wajah, user_id]);

    res.json({
      message: "Foto wajah berhasil diperbarui"
    });

  } catch (err) {
    res.status(500).json({
      message: "Gagal update foto wajah"
    });
  }
};