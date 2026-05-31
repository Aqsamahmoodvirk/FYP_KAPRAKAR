const Notification = require("../models/Notification");

const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.mongoId })
      .sort({ createdAt: -1 });
    const unreadCount = await Notification.countDocuments({
      userId: req.user.mongoId,
      isRead: false,
    });
    return res.status(200).json({ notifications, unreadCount });
  } catch (error) {
    return res.status(500).json({ message: "Failed to get notifications", error: error.message });
  }
};

const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    await Notification.findByIdAndUpdate(id, { isRead: true });
    return res.status(200).json({ success: true });
  } catch (error) {
    return res.status(500).json({ message: "Failed to mark notification as read", error: error.message });
  }
};

const markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.user.mongoId, isRead: false },
      { isRead: true }
    );
    return res.status(200).json({ success: true });
  } catch (error) {
    return res.status(500).json({ message: "Failed to mark all notifications as read", error: error.message });
  }
};

const createNotification = async (
  userId,
  title,
  body,
  type,
  relatedOrderId = null,
  relatedChatId = null
) => {
  try {
    const notification = new Notification({
      userId,
      title,
      body,
      type,
      relatedOrderId,
      relatedChatId,
    });
    await notification.save();
    return notification;
  } catch (error) {
    console.error("Silent notification creation failed:", error);
    // silently fail
  }
};

const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    await Notification.findByIdAndDelete(id);
    return res.status(200).json({ success: true });
  } catch (error) {
    return res.status(500).json({ message: "Failed to delete notification", error: error.message });
  }
};

const deleteAllNotifications = async (req, res) => {
  try {
    await Notification.deleteMany({ userId: req.user.mongoId });
    return res.status(200).json({ success: true, message: "All notifications deleted" });
  } catch (error) {
    return res.status(500).json({ message: "Failed to delete all notifications", error: error.message });
  }
};

module.exports = {
  getNotifications,
  markAsRead,
  markAllAsRead,
  createNotification,
  deleteNotification,
  deleteAllNotifications,
};
