const express = require("express");
const router = express.Router();

const verifyToken = require("../middleware/authMiddleware");

const {
  saveMeasurements,
  getMyMeasurements,
} = require("../controllers/measurementController");



// SAVE / UPDATE
router.post("/", verifyToken, saveMeasurements);



// GET MY MEASUREMENTS
router.get("/me", verifyToken, getMyMeasurements);



module.exports = router;