const Book = require('../models/bookModel');
const db = require("../config/db");

exports.getAllBooks = async (req, res) => {
  try {
    const role = req.query.role || 'publik';
    const books = await Book.getAllBooks(role);
    res.json(books);
  } catch (err) {
    res.status(500).json({ message: "Gagal mengambil buku" });
  }
};

exports.getRecommendedBooks = async (req, res) => {
  try {
    const role = req.query.role || 'publik';
    const books = await Book.getRecommendedBooks(role);
    res.json(books);
  } catch (err) {
    res.status(500).json({ message: "Gagal mengambil rekomendasi" });
  }
};

exports.getBooksByRack = async (req, res) => {
  try {
    const { rak, role } = req.query;

    if (!rak) {
      return res.status(400).json({ message: "Rak tidak boleh kosong" });
    }

    const books = await Book.getBooksByRack(rak, role || 'publik');
    res.json(books);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Gagal mengambil buku rak" });
  }
};

exports.createBook = async (req, res) => {
  try {
    const { judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode } = req.body;

    const book = await Book.createBook(
      judul,
      penulis,
      penerbit,
      tahun_terbit,
      stok,
      rak_id,
      barcode
    );

    res.json({ success: true, book });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};

exports.updateBook = async (req, res) => {
  try {
    const { id } = req.params;
    const { judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode } = req.body;

    await Book.updateBook(id, judul, penulis, penerbit, tahun_terbit, stok, rak_id, barcode);

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};

exports.deleteBook = async (req, res) => {
  try {
    const { id } = req.params;
    await Book.deleteBook(id);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};

/// GET DIGITAL BOOKS
exports.getDigitalBooks = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT * FROM buku
      WHERE is_digital = true
      ORDER BY id DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.log(err);
    res.json([]);
  }
};

/// READ PDF
exports.readBook = async (req, res) => {
  try {
    const id = req.params.id;

    const result = await db.query(
      `SELECT file_pdf FROM buku WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).send("File tidak ditemukan");
    }

    const filePath = result.rows[0].file_pdf;
    res.sendFile(filePath, { root: '.' });

  } catch (err) {
    console.log(err);
    res.status(500).send("Error membuka file");
  }
};