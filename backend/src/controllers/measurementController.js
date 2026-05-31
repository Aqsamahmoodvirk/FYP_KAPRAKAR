const Measurement = require("../models/Measurement");



// SAVE OR UPDATE MEASUREMENTS
const saveMeasurements = async (req, res) => {
  try {
    const existingMeasurement = await Measurement.findOne({
      userId: req.user.uid,
    });

    // UPDATE
    if (existingMeasurement) {
      const updatedMeasurement = await Measurement.findOneAndUpdate(
        { userId: req.user.uid },
        req.body,
        { new: true }
      );

      return res.json({
        message: "Measurements updated successfully",
        measurements: updatedMeasurement,
      });
    }

    // CREATE
    const measurement = new Measurement({
      userId: req.user.uid,
      ...req.body,
    });

    await measurement.save();

    res.json({
      message: "Measurements saved successfully",
      measurements: measurement,
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};



// GET CURRENT USER MEASUREMENTS
const getMyMeasurements = async (req, res) => {
  try {
    const measurement = await Measurement.findOne({
      userId: req.user.uid,
    });

    if (!measurement) {
      return res.status(404).json({
        message: "No measurements found",
      });
    }

    res.json(measurement);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};



module.exports = {
  saveMeasurements,
  getMyMeasurements,
};