const db = require('../config/db');

/**
 * =========================
 * FIND BY EMAIL
 * =========================
 */
exports.findByEmail = async (email) => {
  const res = await db.query(
    'SELECT * FROM users WHERE email = $1',
    [email]
  );
  return res.rows[0];
};


/**
 * =========================
 * CREATE USER
 * =========================
 */
exports.createUser = async ({
  nama,
  alamat,
  email,
  password,
  role,
  foto
}) => {

  const res = await db.query(
    `INSERT INTO users (nama, alamat, email, password, role, foto)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, nama, email, role`,
    [nama, alamat, email, password, role, foto]
  );

  return res.rows[0];
};
