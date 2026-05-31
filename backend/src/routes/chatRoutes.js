const express = require("express");
const router = express.Router();

const chatController = require("../controllers/chatController");

// create or get chat
router.post("/access", chatController.accessChat);

// send message
router.post("/message", chatController.sendMessage);

// get messages
router.get("/messages/:chatId", chatController.getMessages);

// get user chats
router.get("/user/:userId", chatController.getUserChats);

// DELETE /api/chats/:chatId
router.delete("/:chatId", chatController.deleteChat);

// DELETE /api/chats/message/:messageId
router.delete("/message/:messageId", chatController.deleteMessage);

// PUT /api/chats/:chatId/read
router.put("/:chatId/read", chatController.markAsRead);

module.exports = router;