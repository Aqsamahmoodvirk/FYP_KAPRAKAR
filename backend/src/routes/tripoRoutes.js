const express = require("express");
const router = express.Router();
const tripoController = require("../controllers/tripoController");

// POST /api/3d/generate
router.post("/generate", tripoController.generate3DModel);

// GET /api/3d/status/:taskId
router.get("/status/:taskId", tripoController.getTaskStatus);

module.exports = router;
