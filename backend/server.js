const express = require('express');
const axios = require('axios');
const app = require('./src/app');

const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';

/// STATIC FILE PDF & COVER
app.use('/uploads', express.static('uploads'));

/// START SERVER
app.listen(PORT, HOST, () => {
  console.log(`
========================================
🚀 Backend running successfully

➜ Local   : http://localhost:${PORT}
➜ Network : http://172.20.10.3:${PORT}

========================================
  `);
});

/// AUTO CEK TERLAMBAT & BATAL BOOKING
setInterval(async () => {
  try {
    await axios.get(`http://localhost:${PORT}/api/borrows/cek-terlambat`);
    await axios.get(`http://localhost:${PORT}/api/borrows/cancel-expired`);
    console.log("⏱ Auto update terlambat & booking expired");
  } catch (e) {
    console.log("Cron job error:", e.message);
  }
}, 60000);