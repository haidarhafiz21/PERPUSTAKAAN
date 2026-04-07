const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: 'haidar123',
  database: 'perpustakaan_db',
});

module.exports = pool;
