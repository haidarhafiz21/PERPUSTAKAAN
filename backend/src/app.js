const express = require('express');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/authRoutes');
const bookRoutes = require('./routes/bookRoutes');
const borrowRoutes = require('./routes/borrowRoutes');
const walletRoutes = require('./routes/walletRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

/// LOGGER
app.use((req, res, next) => {
  console.log("REQUEST MASUK:", req.method, req.url);
  next();
});

/// STATIC FILE
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

/// ROUTES (PAKAI /api)
app.use('/api/auth', authRoutes);
app.use('/api/books', bookRoutes);
app.use('/api/borrows', borrowRoutes);
app.use('/api/users', userRoutes);
app.use('/api/wallet', walletRoutes);

/// TEST API
app.get('/', (req, res) => {
  res.json({ message: "🔥 API Perpustakaan OK" });
});

/// 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "API route tidak ditemukan"
  });
});

module.exports = app;