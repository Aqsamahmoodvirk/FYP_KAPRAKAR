const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema(
  {
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    tailorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Tailor",
      required: true,
    },

    dressType: {
      type: String,
      required: true,
    },

    notes: {
      type: String,
      default: "",
    },

    measurementId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Measurement",
    },

    amount: {
      type: Number,
      default: 0,
    },

    status: {
      type: String,
      enum: [
        'pending',
        'accepted',
        'fabric-received',
        'in-progress',
        'ready',
        'revision-requested',
        'revision-in-progress',
        'completed',
        'rejected',
        'pending_customer_review'
      ],
      default: "pending",
    },

    expectedDeliveryDate: {
      type: Date,
    },

    orderNumber: {
      type: String,
      unique: true,
      sparse: true,
    },

    isUrgent: {
      type: Boolean,
      default: false,
    },

    urgentFeeApplied: {
      type: Number,
      default: 0,
    },

    finalDressImageUrl: { type: String, default: null },
    finalDressModelUrl: { type: String, default: null },
    tripoTaskId: { type: String, default: null },
    dressImageUrl: { type: String, default: null },
    suggestedImageUrl: { type: String, default: null },
    revisionNote: { type: String, default: null },
    revisionCategory: {
      type: String,
      enum: [
        'Fitting Issue',
        'Length Issue', 
        'Embroidery Issue',
        'Style Change',
        'Other',
        null
      ],
      default: null
    },
    revisionImageUrl: { type: String, default: null },
    revisionCount: { type: Number, default: 0 },
    selectedAiStyle: { type: String, default: null },
    feedbackRating: { type: Number, min: 1, max: 5, default: null },
    feedbackComment: { type: String, default: null },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Order", orderSchema);