const express = require("express");
const router = express.Router();
const SuggestedImage = require("../models/SuggestedImage");
const verifyToken = require("../middleware/authMiddleware");

// GET /api/suggestions/images
// Returns matching images based on query params
router.get("/images", verifyToken, async (req, res) => {
  try {
    const { occasion, season, fabric, color } = req.query;

    const query = {};
    if (occasion) query.occasion = { $regex: new RegExp(occasion, "i") };
    if (season) query.season = { $regex: new RegExp(season, "i") };
    if (fabric) query.fabric = { $regex: new RegExp(fabric, "i") };
    if (color) query.color = { $regex: new RegExp(color, "i") };

    // Fetch matching images from DB
    // If no exact match is found, we might want to return some random ones, but let's stick to strict or semi-strict for now
    let images = await SuggestedImage.find(query).limit(20);
    
    // Fallback: If no matches, return general images
    if (images.length === 0) {
        images = await SuggestedImage.find().limit(10);
    }

    res.status(200).json(images);
  } catch (error) {
    console.error("Error fetching suggested images:", error);
    res.status(500).json({ message: "Server error fetching suggestions" });
  }
});

module.exports = router;
