const mongoose = require("mongoose");

const measurementSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },

    chest: Number,
    waist: Number,
    hips: Number,
    shoulder: Number,
    sleeve: Number,
    armhole: Number,
    length: Number,
    neck: Number,
    trouser: Number,

    notes: {
      type: String,
      default: "",
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Measurement", measurementSchema);