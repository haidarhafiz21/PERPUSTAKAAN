const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  user: 'postgres',
  password: 'haidar123',
  database: 'perpus_clean', // 🔥 GANTI KE DATABASE BARU
  port: 5432,
});

pool.connect()
  .then(client => {
    return client
      .query('SELECT current_database()')
      .then(res => {
        console.log('🔥 CONNECTED TO DATABASE:', res.rows[0].current_database);
        client.release();
      });
  })
  .catch(err => {
    console.error('❌ DATABASE CONNECTION ERROR:', err);
  });

module.exports = pool;
