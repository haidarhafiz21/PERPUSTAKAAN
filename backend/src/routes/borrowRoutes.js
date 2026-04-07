const express = require('express');
const router = express.Router();
const borrowController = require('../controllers/borrowController');

/// ================= USER =================
router.post('/booking', borrowController.borrowBook);
router.get('/active', borrowController.getActiveBorrow);
router.get('/user/:id', borrowController.getUserBorrows);

/// ================= ADMIN =================
router.post('/scan', borrowController.scanBorrow);
router.post('/return', borrowController.returnBook);
router.post('/bayar', borrowController.bayarDenda);
router.post('/bayar-offline', borrowController.bayarDendaOffline);
router.get('/all', borrowController.getAllBorrows);
router.get('/user-booking/:user_id', borrowController.getUserBooking);
router.get('/stats', borrowController.getBorrowStats);
router.get('/denda-list', borrowController.getDendaList);
router.get('/history-pembayaran', borrowController.getHistoryPembayaran);

/// TAMBAHAN BARU
router.get('/active-list', borrowController.getActiveList);
router.get('/late-list', borrowController.getLateList);

/// HISTORY PEMBAYARAN
router.post('/bayar-offline', borrowController.bayarDendaOffline);
router.get('/history-pembayaran', borrowController.getHistoryPembayaran);

/// ================= SYSTEM =================
router.get('/cek-terlambat', borrowController.cekTerlambat);
router.get('/cancel-expired', borrowController.cancelExpiredBooking);

module.exports = router;