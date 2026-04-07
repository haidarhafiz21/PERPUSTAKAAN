const db = require('../utils/db');

exports.addBalance = async (userId, amount) => {
  await db.query(
    'UPDATE wallets SET saldo = saldo + $1 WHERE user_id = $2',
    [amount, userId]
  );

  await db.query(
    'INSERT INTO payments (user_id, jumlah, jenis) VALUES ($1, $2, $3)',
    [userId, amount, 'topup']
  );
};
