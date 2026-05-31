const mongoose = require("mongoose");

const tailorSchema = new mongoose.Schema(
{
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  shopName: {
    type: String,
    required: true,
  },

  fullName: {
    type: String,
    default: "",
  },

  email: {
    type: String,
    default: "",
  },

  phone: {
    type: String,
    default: "",
  },

  address: {
    type: String,
    default: "",
  },

  bio: {
    type: String,
    default: "",
  },


  city: {
    type: String,
    default: "",
  },

  pricing: {
    type: String,
    default: "",
  },

  specialties: {
    type: [String],
    default: [],
  },

  categoryPrices: {
    type: Map,
    of: Number,
    default: {},
  },

  categoryTurnaround: {
    type: Map,
    of: Number,
    default: {},
  },

  urgentCategoryEnabled: {
    type: Map,
    of: Boolean,
    default: {},
  },

  urgentCategoryTurnaround: {
    type: Map,
    of: Number,
    default: {},
  },

  urgentCategoryPrices: {
    type: Map,
    of: Number,
    default: {},
  },

  rating: {
    type: Number,
    default: 0,
  },

  reviewCount: {
    type: Number,
    default: 0,
  },

  profileImage: {
    type: String,
    default: "",
  },
},
{ timestamps: true }
);

module.exports = mongoose.model("Tailor", tailorSchema);