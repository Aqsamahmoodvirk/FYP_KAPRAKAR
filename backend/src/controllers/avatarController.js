const path = require("path");

const runBlender = require("../services/blenderService");

const Measurement = require("../models/Measurement");

const generateAvatarPreview = async (req, res) => {

  try {

    const customerId = req.body.customerId;

    const measurement =
      await Measurement.findOne({ customer: customerId });

    if (!measurement) {
      return res.status(404).json({
        message: "Measurements not found",
      });
    }

    const height =
      measurement.height || 1.7;

    const width =
      measurement.shoulder || 0.5;

    const imagePath = req.file.path;

    const outputImage =
      await runBlender(
        height,
        width,
        imagePath
      );

    res.sendFile(outputImage);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      message: "Avatar preview generation failed",
    });
  }
};

module.exports = {
  generateAvatarPreview,
};