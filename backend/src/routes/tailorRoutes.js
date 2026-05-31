const express = require("express");

const router = express.Router();

const {
  createTailorProfile,
  getAllTailors,
  getTailorById,
  getTailorByUserId,
  getTailorStats,
} = require("../controllers/tailorController");


// CREATE TAILOR PROFILE
router.post("/create", createTailorProfile);


// GET ALL TAILORS
router.get("/", getAllTailors);


// GET SINGLE TAILOR
router.get("/:id", getTailorById);

// GET TAILOR BY USER ID
router.get("/user/:userId", getTailorByUserId);

// GET TAILOR STATS
router.get("/:tailorId/stats", getTailorStats);

// UPDATE TAILOR PROFILE
router.put("/:id", require("../controllers/tailorController").updateTailorProfile);

// UPLOAD PROFILE IMAGE
const upload = require("../middleware/uploadMiddleware");
router.post("/:id/profile-image", upload.single("image"), require("../controllers/tailorController").uploadTailorProfileImage);

module.exports = router;