const express = require("express");
const multer = require("multer");

const {
  generateAvatarPreview,
} = require("../controllers/avatarController");

const router = express.Router();

const upload = multer({
  dest: "uploads/",
});

router.post(
  "/generate-preview",
  upload.single("dress_image"),
  generateAvatarPreview
);

module.exports = router;