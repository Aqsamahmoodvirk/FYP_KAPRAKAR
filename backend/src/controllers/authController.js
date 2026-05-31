// GET USER PROFILE
exports.getUserProfile = async (req, res) => {
  try {
    const User = require("../models/User");
    const Customer = require("../models/Customer");
    const Tailor = require("../models/Tailor");
    
    // req.params.userId is the MongoDB _id
    const user = await User.findById(req.params.userId);
    
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    
    let profileData = null;
    if (user.role === "customer") {
      profileData = await Customer.findOne({ userId: user._id });
    } else if (user.role === "tailor") {
      profileData = await Tailor.findOne({ userId: user._id });
    }
    
    res.status(200).json({
      user,
      profile: profileData
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// UPDATE USER PROFILE
exports.updateUserProfile = async (req, res) => {
  try {
    const User = require("../models/User");
    const Customer = require("../models/Customer");
    const admin = require("../config/firebase");
    const { name, phone, city, email } = req.body;
    
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (email && email !== user.email) {
      try {
        await admin.auth().updateUser(user.uid, { email: email });
        user.email = email;
        await user.save();
      } catch (err) {
        return res.status(400).json({ message: "Failed to update email in Firebase", error: err.message });
      }
    }

    if (user.role === "customer") {
      let customer = await Customer.findOne({ userId: user._id });
      if (customer) {
        if (name) customer.fullName = name;
        if (phone) customer.phone = phone;
        if (city) customer.city = city;
        await customer.save();
        return res.status(200).json({ user, profile: customer });
      }
    }
    
    res.status(200).json({ user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
