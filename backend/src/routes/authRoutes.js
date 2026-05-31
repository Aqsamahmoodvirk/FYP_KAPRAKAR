const express = require("express");
const router = express.Router();
const admin = require("../config/firebase");
const User = require("../models/User");
const authController = require("../controllers/authController");

// Get user profile
router.get("/user/:userId", authController.getUserProfile);

// Update user profile
router.put("/user/:userId", authController.updateUserProfile);

// Sync user from Firebase to MongoDB
router.post("/syncUser", async (req, res) => {
  try {
    const token = req.headers.authorization?.split("Bearer ")[1];

    if (!token) {
      return res.status(401).json({ message: "No token provided" });
    }

    const { name, phone, city, role } = req.body;

    const decoded = await admin.auth().verifyIdToken(token);
    const { uid, email } = decoded;

    const finalName = name || decoded.name || "";
    const finalPhone = phone || "";
    const finalCity = city || "";
    const finalRole = (role && role.toLowerCase() === "tailor") ? "tailor" : "customer";

    // Check if user exists
    let user = await User.findOne({ uid });

    if (!user) {
      user = await User.create({
        uid,
        email,
        role: finalRole,
      });
    } else {
      // We NEVER overwrite the role of an existing user!
      await user.save();
    }

    if (user.role === "customer") {
      const Customer = require("../models/Customer");
      let customer = await Customer.findOne({ userId: user._id });
      if (!customer) {
        customer = await Customer.create({
          userId: user._id,
          fullName: finalName,
          phone: finalPhone,
          city: finalCity,
        });
      } else {
        // Only update fields if they were explicitly provided in the payload!
        if (name) customer.fullName = name;
        if (phone) customer.phone = phone;
        if (city) customer.city = city;
        await customer.save();
      }
    }

    res.json({
      message: "User synced successfully",
      user,
    });

  } catch (error) {
    res.status(500).json({
      message: "Sync failed",
      error: error.message,
    });
  }
});

module.exports = router;