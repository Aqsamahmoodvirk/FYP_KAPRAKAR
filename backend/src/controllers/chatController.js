const Chat = require("../models/Chat");
const Message = require("../models/Message");
const Customer = require("../models/Customer");
const Tailor = require("../models/Tailor");

// Helper to attach names to participants
const populateParticipantNames = async (chat) => {
  const populatedParticipants = await Promise.all(
    chat.participants.map(async (user) => {
      // Fallback to the first part of their email if profile is missing
      let fallbackName = user.email ? user.email.split("@")[0] : "Unknown User";
      let name = fallbackName;
      
      console.log(`Populating name for user: ${user._id} with role: ${user.role}`);
      if (user.role === "customer") {
        const customer = await Customer.findOne({ userId: user._id });
        if (customer && customer.fullName) name = customer.fullName;
        console.log(`Found customer: ${customer ? customer.fullName : 'null'}`);
      } else if (user.role === "tailor") {
        const tailor = await Tailor.findOne({ userId: user._id });
        if (tailor && tailor.shopName) name = tailor.shopName;
        else if (tailor && tailor.fullName) name = tailor.fullName;
        console.log(`Found tailor: ${tailor ? tailor.shopName || tailor.fullName : 'null'}`);
      }
      
      // If name is still an empty string (e.g. they didn't fill out their profile), use fallback
      if (!name || name.trim() === "") {
        name = fallbackName;
      }

      return {
        _id: user._id,
        email: user.email,
        role: user.role,
        name: name,
      };
    })
  );
  return { ...chat.toObject(), participants: populatedParticipants };
};

// 1. create or get chat
exports.accessChat = async (req, res) => {
  try {
    const { userId1, userId2 } = req.body;

    if (!userId1 || !userId2) {
      return res.status(400).json({ message: "Both user IDs required" });
    }

    let chat = await Chat.findOne({
      participants: { $all: [userId1, userId2] },
      $expr: { $eq: [{ $size: "$participants" }, 2] }
    }).populate("participants", "email role");

    if (chat) {
      const fullChat = await populateParticipantNames(chat);
      return res.json(fullChat);
    }

    const newChat = await Chat.create({
      participants: [userId1, userId2],
    });

    const populatedChat = await Chat.findById(newChat._id).populate(
      "participants",
      "email role"
    );
    const fullChat = await populateParticipantNames(populatedChat);

    res.status(201).json(fullChat);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 2. send message
exports.sendMessage = async (req, res) => {
  try {
    const { chatId, senderId, text } = req.body;

    if (!chatId || !senderId || !text) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const message = await Message.create({
      chatId,
      senderId,
      text,
    });

    await Chat.findByIdAndUpdate(chatId, {
      lastMessage: text,
    });

    res.status(201).json(message);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 3. get messages
exports.getMessages = async (req, res) => {
  try {
    const { chatId } = req.params;

    const messages = await Message.find({ chatId })
      .populate("senderId", "email role")
      .sort({ createdAt: 1 });

    res.json(messages);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 4. get user chats
exports.getUserChats = async (req, res) => {
  try {
    const { userId } = req.params;

    const chats = await Chat.find({
      participants: userId,
    })
      .populate("participants", "email role")
      .sort({ updatedAt: -1 });

    const fullChats = await Promise.all(
      chats.map(async (chat) => {
        const populatedChat = await populateParticipantNames(chat);
        
        // Calculate unread count (messages sent by someone else that are not read)
        const unreadCount = await Message.countDocuments({
          chatId: chat._id,
          senderId: { $ne: userId },
          isRead: false
        });

        return {
          ...populatedChat,
          unreadCount
        };
      })
    );

    res.json(fullChats);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 5. delete chat
exports.deleteChat = async (req, res) => {
  try {
    const { chatId } = req.params;
    
    // Delete all messages associated with the chat
    await Message.deleteMany({ chatId });
    
    // Delete the chat itself
    await Chat.findByIdAndDelete(chatId);
    
    res.json({ message: "Chat deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 6. delete individual message
exports.deleteMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    
    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({ message: "Message not found" });
    }
    
    const chatId = message.chatId;
    
    // Delete the message
    await Message.findByIdAndDelete(messageId);
    
    // Check if this was the last message to update the chat document
    const lastMessage = await Message.findOne({ chatId }).sort({ createdAt: -1 });
    await Chat.findByIdAndUpdate(chatId, {
      lastMessage: lastMessage ? lastMessage.text : ""
    });
    
    res.json({ message: "Message deleted successfully", chatId: chatId });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 7. mark messages as read
exports.markAsRead = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { userId } = req.body; // The user who is reading the messages

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    // Update all messages in this chat where sender is NOT the current user
    await Message.updateMany(
      { chatId, senderId: { $ne: userId }, isRead: false },
      { $set: { isRead: true } }
    );

    res.json({ message: "Messages marked as read" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};