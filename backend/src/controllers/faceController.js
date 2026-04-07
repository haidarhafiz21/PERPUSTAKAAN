const axios = require("axios");
const db = require("../config/db");

exports.verifyFace = async (req, res) => {
  try {
    const { user_id, foto_scan, foto_liveness } = req.body;

    if (!user_id || !foto_scan || !foto_liveness) {
      return res.json({
        match: false,
        message: "Data tidak lengkap"
      });
    }

    const user = await db.query(
      "SELECT face_encoding FROM users WHERE id=$1",
      [user_id]
    );

    if (user.rows.length === 0) {
      return res.json({
        match: false,
        message: "User tidak ditemukan"
      });
    }

    const encoding_db = user.rows[0].face_encoding;

    const response = await axios.post(
      "http://127.0.0.1:5000/verify-face",
      {
        encoding_db: encoding_db,
        foto_scan: foto_scan,
        foto_liveness: foto_liveness
      },
      { timeout: 20000 }
    );

    res.json(response.data);

  } catch (err) {
    console.log("ERROR VERIFY:", err.message);
    res.json({
      match: false,
      message: "Face verification gagal"
    });
  }
};