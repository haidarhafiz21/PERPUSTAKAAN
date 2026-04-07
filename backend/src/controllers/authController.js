const db = require("../config/db");
const axios = require("axios");
const bcrypt = require("bcrypt");

// =============================
// REGISTER
// =============================
exports.register = async (req, res) => {
  try {
    const { nama, alamat, email, password, foto } = req.body;

    if (!foto) {
      return res.json({
        success: false,
        message: "Foto wajah wajib dari kamera"
      });
    }

    // CEK EMAIL
    const check = await db.query(
      "SELECT id FROM users WHERE email=$1",
      [email]
    );

    if (check.rows.length > 0) {
      return res.json({
        success: false,
        message: "Email sudah terdaftar"
      });
    }

    let encoding = null;

    try {
      const face = await axios.post(
        "http://127.0.0.1:5000/encode-face",
        { foto: foto },
        { timeout: 15000 } // 15 detik saja
      );

      if (face.data.success === true) {
        encoding = JSON.stringify(face.data.encoding);
      } else {
        return res.json({
          success: false,
          message: "Wajah tidak terdeteksi, ulangi foto"
        });
      }

    } catch (e) {
      return res.json({
        success: false,
        message: "Face API tidak terhubung"
      });
    }

    // HASH PASSWORD
    const hash = await bcrypt.hash(password, 10);

    // INSERT USER
    const result = await db.query(
      `INSERT INTO users
      (nama_lengkap, alamat, email, password, foto_wajah, face_encoding, role)
      VALUES ($1,$2,$3,$4,$5,$6,'publik')
      RETURNING id, nama_lengkap, email, role`,
      [nama, alamat, email, hash, foto, encoding]
    );

    res.json({
      success: true,
      user: result.rows[0]
    });

  } catch (err) {
    console.log("REGISTER ERROR:", err);
    res.json({
      success: false,
      message: "Register gagal"
    });
  }
};


// =============================
// LOGIN
// =============================
exports.login = async (req, res) => {
  try {
    let { email, password } = req.body;

    email = email.trim();

    const result = await db.query(
      "SELECT * FROM users WHERE email=$1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.json({
        success: false,
        message: "Email tidak ditemukan"
      });
    }

    const user = result.rows[0];

    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.json({
        success: false,
        message: "Password salah"
      });
    }

    res.json({
      success: true,
      user: {
        id: user.id,
        nama: user.nama_lengkap,
        email: user.email,
        role: user.role,
        foto_wajah: user.foto_wajah,
        face_encoding: user.face_encoding
      }
    });

  } catch (err) {
    console.log("LOGIN ERROR:", err);
    res.json({
      success: false,
      message: "Login gagal"
    });
  }
};