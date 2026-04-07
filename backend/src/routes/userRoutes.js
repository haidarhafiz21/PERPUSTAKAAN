const express = require("express");
const router = express.Router();

const userController = require("../controllers/userController");
const faceController = require("../controllers/faceController");

/// GET SEMUA ANGGOTA
router.get("/members", userController.getMembers);

/// SEARCH ANGGOTA
router.get("/search", userController.searchUser);

/// GET PROFILE
router.get("/profile/:id", userController.getProfile);

/// UPDATE FOTO WAJAH
router.post("/update-face", userController.updateFace);

/// VERIFIKASI WAJAH
router.post("/verify-face", faceController.verifyFace);

module.exports = router;