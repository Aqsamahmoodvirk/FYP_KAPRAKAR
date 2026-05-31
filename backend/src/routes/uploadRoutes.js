const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const verifyToken = require("../middleware/authMiddleware");

// Ensure suggested_images directory exists
const uploadDir = path.join(__dirname, "../../uploads/suggested_images");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Custom Multer Storage for Suggested Images
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const uploadSuggested = multer({ storage: storage });

// POST /api/upload/suggested
// Upload a suggested/reference image
router.post("/suggested", verifyToken, uploadSuggested.single("image"), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "No image file provided" });
    }
    
    // Construct public URL
    const imageUrl = `/uploads/suggested_images/${req.file.filename}`;
    
    res.status(200).json({ 
      message: "Image uploaded successfully",
      imageUrl: imageUrl
    });
  } catch (error) {
    console.error("Error uploading suggested image:", error);
    res.status(500).json({ message: "Server error uploading image" });
  }
});

module.exports = router;
