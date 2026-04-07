const db = require('../config/db');

/// =========================
/// GET SEMUA BUKU (UNTUK ADMIN)
/// =========================
exports.getAllBooks = async (role) => {
  const result = await db.query(`
    SELECT 
      b.id,
      b.judul,
      b.penulis,
      b.penerbit,
      b.tahun_terbit,
      b.stok,
      b.cover_buku,
      b.deskripsi,
      b.barcode,
      b.is_digital,
      b.file_pdf,
      r.nama_rak,
      r.tipe_rak
    FROM buku b
    JOIN rak r ON b.rak_id = r.id
    ORDER BY b.id DESC
  `);

  return result.rows;
};


/// =========================
/// REKOMENDASI (FISIK SAJA)
/// =========================
exports.getRecommendedBooks = async (role) => {
  const result = await db.query(`
    SELECT 
      b.id,
      b.judul,
      b.penulis,
      b.cover_buku,
      b.deskripsi,
      b.barcode,
      b.stok
    FROM buku b
    JOIN rak r ON b.rak_id = r.id
    WHERE b.is_digital = false
    AND (
      r.tipe_rak = 'publik'
      OR $1 = 'pegawai'
      OR $1 = 'admin_mobile'
    )
    ORDER BY b.stok DESC
    LIMIT 5
  `, [role]);

  return result.rows;
};


/// =========================
/// BUKU BERDASARKAN RAK (FISIK SAJA)
/// =========================
exports.getBooksByRack = async (rak, role) => {
  const result = await db.query(`
    SELECT 
      b.id,
      b.judul,
      b.penulis,
      b.cover_buku,
      b.deskripsi,
      b.barcode,
      b.stok,
      r.nama_rak
    FROM buku b
    JOIN rak r ON b.rak_id = r.id
    WHERE r.nama_rak ILIKE $1
    AND b.is_digital = false
    AND (
      r.tipe_rak = 'publik'
      OR $2 = 'pegawai'
      OR $2 = 'admin_mobile'
    )
    ORDER BY b.judul ASC
  `, [`%${rak}%`, role]);

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
  barcode,
  deskripsi,
  cover_buku,
  is_digital,
  file_pdf
) => {
  const result = await db.query(`
    INSERT INTO buku 
    (judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode, deskripsi, cover_buku, is_digital, file_pdf)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
    RETURNING *
  `, [judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode, deskripsi, cover_buku, is_digital, file_pdf]);

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
  barcode,
  deskripsi,
  cover_buku,
  is_digital,
  file_pdf
) => {
  await db.query(`
    UPDATE buku
    SET judul=$1,
        penulis=$2,
        penerbit=$3,
        tahun_terbit=$4,
        stok=$5,
        rak_id=$6,
        barcode=$7,
        deskripsi=$8,
        cover_buku=$9,
        is_digital=$10,
        file_pdf=$11
    WHERE id=$12
  `, [judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode, deskripsi, cover_buku, is_digital, file_pdf, id]);
};


/// =========================
/// DELETE
/// =========================
exports.deleteBook = async (id) => {
  await db.query(`DELETE FROM buku WHERE id=$1`, [id]);
};