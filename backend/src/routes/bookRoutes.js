const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');

router.get('/', bookController.getAllBooks);
router.get('/recommended', bookController.getRecommendedBooks);
router.get('/by-rak', bookController.getBooksByRack);

/// DIGITAL BOOK
router.get('/digital', bookController.getDigitalBooks);
router.get('/read/:id', bookController.readBook);

router.post('/', bookController.createBook);
router.put('/:id', bookController.updateBook);
router.delete('/:id', bookController.deleteBook);

module.exports = router;