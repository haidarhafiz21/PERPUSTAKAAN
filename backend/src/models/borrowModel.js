const db = require('../config/db');

/// =========================
/// GET SEMUA BUKU
/// =========================
exports.getAllBooks = async (role) => {
  const result = await db.query(`
    SELECT b.*, r.nama_rak, r.tipe_rak
    FROM buku b
    JOIN rak r ON b.rak_id = r.id
    WHERE r.tipe_rak = 'publik'
       OR $1 = 'pegawai'
       OR $1 = 'admin_mobile'
    ORDER BY b.id DESC
  `, [role]);

  return result.rows;
};


/// =========================
/// REKOMENDASI
/// =========================
exports.getRecommendedBooks = async (role) => {
  const result = await db.query(`
    SELECT b.id, b.judul, b.penulis
    FROM buku b
    JOIN rak r ON b.rak_id = r.id
    WHERE r.tipe_rak = 'publik'
       OR $1 = 'pegawai'
       OR $1 = 'admin_mobile'
    ORDER BY b.id DESC
    LIMIT 5
  `, [role]);

  return result.rows;
};


/// =========================
/// BUKU BERDASARKAN RAK
/// =========================
exports.getBooksByRack = async (rak, role) => {
  const result = await db.query(`
    SELECT b.*
    FROM buku b
    JOIN rak r ON b.rak_id = r.id
    WHERE r.nama_rak = $1
    AND (
      r.tipe_rak = 'publik'
      OR $2 = 'pegawai'
      OR $2 = 'admin_mobile'
    )
    ORDER BY b.judul ASC
  `, [rak, role]);

  return result.rows;
};


/// =========================
/// TAMBAH
/// =========================
exports.createBook = async (
  judul,
  penulis,
  penerbit,
  tahun_terbit,
  stok,
  rak_id,
  barcode
) => {
  const result = await db.query(`
    INSERT INTO buku 
    (judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode)
    VALUES ($1,$2,$3,$4,$5,$6,$7)
    RETURNING *
  `, [judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode]);

  return result.rows[0];
};


/// =========================
/// UPDATE
/// =========================
exports.updateBook = async (
  id,
  judul,
  penulis,
  penerbit,
  tahun_terbit,
  stok,
  rak_id,
  barcode
) => {
  await db.query(`
    UPDATE buku
    SET judul=$1,
        penulis=$2,
        penerbit=$3,
        tahun_terbit=$4,
        stok=$5,
        rak_id=$6,
        barcode=$7
    WHERE id=$8
  `, [judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode, id]);
};


/// =========================
/// DELETE
/// =========================
exports.deleteBook = async (id) => {
  await db.query(`DELETE FROM buku WHERE id=$1`, [id]);
};