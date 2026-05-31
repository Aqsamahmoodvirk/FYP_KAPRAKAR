const admin = require("../config/firebase");

const verifyToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split("Bearer ")[1];

    if (!token) {
      return res.status(401).json({ message: "No token provided" });
    }

    const decoded = await admin.auth().verifyIdToken(token);

    req.user = decoded; // contains uid, email etc.
    const User = require('../models/User');
    const dbUser = await User.findOne({ uid: decoded.uid });
    if (dbUser) {
      req.user.mongoId = dbUser._id;
    }
    next();
  } catch (error) {
    res.status(401).json({ message: "Invalid token", error });
  }
};

module.exports = verifyToken;