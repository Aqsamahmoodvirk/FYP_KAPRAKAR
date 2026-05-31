const mongoose = require("mongoose");

const suggestedImageSchema = new mongoose.Schema(
  {
    imageUrl: {
      type: String,
      required: true,
    },
    occasion: {
      type: String,
      required: true,
    },
    season: {
      type: String,
      required: true,
    },
    fabric: {
      type: String,
      required: true,
    },
    color: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      default: "Style Suggestion",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("SuggestedImage", suggestedImageSchema);
