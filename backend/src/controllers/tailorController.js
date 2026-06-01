const Tailor = require("../models/Tailor");
const User = require("../models/User");


// CREATE TAILOR PROFILE
exports.createTailorProfile = async (req, res) => {
  try {
    const {
      userId,
      shopName,
      fullName,
      email,
      phone,
      address,
      bio,
      experience,
      city,
      pricing,
      specialties,
      categoryPrices,
      profileImage,
      categoryTurnaround,
      urgentCategoryEnabled,
      urgentCategoryTurnaround,
      urgentCategoryPrices,
    } = req.body;

    // Check if tailor already exists
    const existingTailor = await Tailor.findOne({ userId });

    if (existingTailor) {
      return res.status(400).json({
        message: "Tailor profile already exists",
      });
    }

    const tailor = new Tailor({
      userId,
      shopName,
      fullName,
      email,
      phone,
      address,
      bio,
      experience,
      city,
      pricing,
      specialties,
      categoryPrices,
      profileImage,
      categoryTurnaround,
      urgentCategoryEnabled,
      urgentCategoryTurnaround,
      urgentCategoryPrices,
    });

    await tailor.save();

    // Update user role to tailor
    await User.findByIdAndUpdate(userId, {
      role: "tailor",
    });

    res.status(201).json({
      message: "Tailor profile created successfully",
      tailor,
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};


// GET ALL TAILORS
exports.getAllTailors = async (req, res) => {
  try {
    const { search, minPrice, maxPrice, minRating, location, category } = req.query;
    const query = {};

    // 1. Search Query (Shop Name or Full Name)
    if (search) {
      query.$or = [
        { shopName: { $regex: new RegExp(search, "i") } },
        { fullName: { $regex: new RegExp(search, "i") } }
      ];
    }

    // 2. Location (City)
    if (location) {
      query.city = { $regex: new RegExp(location, "i") };
    }

    // 3. Minimum Rating
    if (minRating) {
      query.rating = { $gte: Number(minRating) };
    }

    // 4. Category / Specialties
    if (category) {
      // Assuming specialties is an array of strings
      query.specialties = { $regex: new RegExp(category, "i") };
      
      // 5. Price Range (Only apply if a category is selected)
      if (minPrice || maxPrice) {
        const priceQuery = {};
        if (minPrice) priceQuery.$gte = Number(minPrice);
        if (maxPrice) priceQuery.$lte = Number(maxPrice);
        
        // Use MongoDB dynamic key querying syntax using the category name
        query[`categoryPrices.${category}`] = priceQuery;
      }
    }

    const tailors = await Tailor.find(query).populate("userId", "name email");

    res.status(200).json(tailors);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};


// GET SINGLE TAILOR
exports.getTailorById = async (req, res) => {
  try {
    const tailor = await Tailor.findById(
      req.params.id
    ).populate("userId", "name email");

    if (!tailor) {
      return res.status(404).json({
        message: "Tailor not found",
      });
    }
    res.status(200).json(tailor);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

// GET TAILOR BY USER ID
exports.getTailorByUserId = async (req, res) => {
  try {
    const tailor = await Tailor.findOne({ userId: req.params.userId })
      .populate("userId", "name email");

    if (!tailor) {
      return res.status(404).json({
        message: "Tailor profile not found",
      });
    }

    res.status(200).json(tailor);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

// GET TAILOR STATS
exports.getTailorStats = async (req, res) => {
  try {
    const { tailorId } = req.params;
    const Order = require("../models/Order");
    const Payment = require("../models/Payment");

    const tailor = await Tailor.findById(tailorId);
    if (!tailor) return res.status(404).json({ message: "Tailor not found" });

    // Get all completed orders for this tailor
    const completedOrders = await Order.find({ tailorId: tailor._id, status: "completed" }).select('_id');
    const completedOrderIds = completedOrders.map(o => o._id);
    const ordersCompletedTotal = completedOrders.length;

    // Sum up actual paid amounts from Payment model
    const paymentStats = await Payment.aggregate([
      { $match: { orderId: { $in: completedOrderIds }, status: 'paid' } },
      { $group: { _id: null, totalEarnings: { $sum: "$amount" } } }
    ]);

    const totalEarnings = paymentStats.length > 0 ? paymentStats[0].totalEarnings : 0;

    res.status(200).json({
      totalEarnings,
      ordersCompletedThisMonth: ordersCompletedTotal,
      rating: tailor.rating || 5.0
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


// UPDATE TAILOR PROFILE
exports.updateTailorProfile = async (req, res) => {
  try {
    const Tailor = require("../models/Tailor");
    const {
      shopName,
      fullName,
      email,
      phone,
      address,
      bio,
      specialties,
      categoryPrices,
      city,
      categoryTurnaround,
      urgentCategoryEnabled,
      urgentCategoryTurnaround,
      urgentCategoryPrices,
    } = req.body;

    const tailor = await Tailor.findById(req.params.id);
    if (!tailor) {
      return res.status(404).json({ message: "Tailor not found" });
    }

    if (email && email !== tailor.email) {
      const User = require("../models/User");
      const admin = require("../config/firebase");
      const user = await User.findById(tailor.userId);
      if (user) {
        try {
          await admin.auth().updateUser(user.uid, { email: email });
          user.email = email;
          await user.save();
        } catch (err) {
          return res.status(400).json({ message: "Failed to update email in Firebase", error: err.message });
        }
      }
    }

    if (shopName) tailor.shopName = shopName;
    if (fullName) tailor.fullName = fullName;
    if (email) tailor.email = email;
    if (phone) tailor.phone = phone;
    if (address) tailor.address = address;
    if (bio) tailor.bio = bio;
    if (city) tailor.city = city;
    
    if (specialties !== undefined) {
      if (Array.isArray(specialties)) {
        tailor.specialties = specialties;
      } else if (typeof specialties === 'string') {
        tailor.specialties = specialties.split(',').map(s => s.trim()).filter(s => s.length > 0);
      }
    }

    if (categoryPrices !== undefined) {
      tailor.categoryPrices = categoryPrices;
    }
    if (categoryTurnaround !== undefined) {
      tailor.categoryTurnaround = categoryTurnaround;
    }
    if (urgentCategoryEnabled !== undefined) {
      tailor.urgentCategoryEnabled = urgentCategoryEnabled;
    }
    if (urgentCategoryTurnaround !== undefined) {
      tailor.urgentCategoryTurnaround = urgentCategoryTurnaround;
    }
    if (urgentCategoryPrices !== undefined) {
      tailor.urgentCategoryPrices = urgentCategoryPrices;
    }

    await tailor.save();

    res.status(200).json({
      message: "Tailor profile updated successfully",
      tailor,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// UPLOAD TAILOR PROFILE IMAGE
exports.uploadTailorProfileImage = async (req, res) => {
  try {
    const Tailor = require("../models/Tailor");
    if (!req.file) {
      return res.status(400).json({ message: "No image uploaded" });
    }

    const tailor = await Tailor.findById(req.params.id);
    if (!tailor) {
      return res.status(404).json({ message: "Tailor not found" });
    }

    const path = require('path');
    const filename = path.basename(req.file.path);
    tailor.profileImage = `/uploads/${filename}`;
    await tailor.save();

    res.status(200).json({
      message: "Profile image updated successfully",
      profileImage: tailor.profileImage
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
