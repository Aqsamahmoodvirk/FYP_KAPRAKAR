const express = require("express");
const http = require("http");
const cors = require("cors");
require("dotenv").config();

// NEW IMPORTS FOR BLENDER
const { exec } = require("child_process");
const path = require("path");

const connectDB = require("./config/db");
const verifyToken = require("./middleware/authMiddleware");

const authRoutes = require("./routes/authRoutes");
const tailorRoutes = require("./routes/tailorRoutes");
const measurementRoutes = require("./routes/measurementRoutes");
const orderRoutes = require("./routes/orderRoutes");
const chatRoutes = require("./routes/chatRoutes");
const avatarRoutes = require("./routes/avatarRoutes");
const tripoRoutes = require("./routes/tripoRoutes");
const suggestionRoutes = require("./routes/suggestionRoutes");
const uploadRoutes = require("./routes/uploadRoutes");

const notificationRoutes = require("./routes/notificationRoutes");
// Swagger setup
const swaggerUi = require("swagger-ui-express");
const swaggerSpec = require("./config/swagger");

const app = express();

// Connect Database
connectDB();

// Middleware
app.use(cors());
app.use(express.json());
// Serve uploads statically
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));
// Swagger documentation route
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

const upload = require("./middleware/uploadMiddleware");


// Routes
app.get("/", (req, res) => {
  res.send("KapraKar Backend Running");
});

const paymentRoutes = require("./routes/paymentRoutes");

app.use("/api/auth", authRoutes);
app.use("/api/tailors", tailorRoutes);
app.use("/api/measurements", measurementRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/chats", chatRoutes);
app.use("/api/avatars", avatarRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/3d", tripoRoutes);
app.use("/api/suggestions", suggestionRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/payments", paymentRoutes);
app.get("/protected", verifyToken, (req, res) => {
  res.json({
    message: "You accessed protected route",
    user: req.user,
  });
});

// NEW: BLENDER PREVIEW ROUTE
app.post("/api/preview", upload.single("dressImage"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "No image uploaded" });
  }

  const inputPath = path.resolve(req.file.path);
  const outputFilename = "preview_" + Date.now() + ".png";
  const outputPath = path.join(
    path.dirname(inputPath),
    outputFilename
  );
  const scriptPath = path.join(__dirname, "..", "remove_bg.py");

  const { execFile } = require("child_process");

  execFile(
    "python",
    [scriptPath, inputPath, outputPath],
    (error, stdout, stderr) => {
      if (error) {
        console.error("Background removal failed:", error);
        return res.sendFile(inputPath);
      }
      console.log("Preview ready. Sending to Flutter.");
      res.sendFile(outputPath, (err) => {
        if (err) {
          console.error("Send file error:", err);
          if (!res.headersSent) {
            res.sendFile(inputPath);
          }
        }
      });
    }
  );
});

// Server & Socket Setup Fix
// We create the HTTP server first, attach sockets, then listen to the server
const PORT = process.env.PORT || 5000;
const server = http.createServer(app);

const { Server } = require("socket.io");

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

let onlineUsers = new Map();

io.on("connection", (socket) => {
  console.log("Connected:", socket.id);

  // user registers
  socket.on("setup", (userId) => {
    socket.join(userId);
    onlineUsers.set(userId, socket.id);
  });

  // join specific chat room
  socket.on("join chat", (chatId) => {
    socket.join(chatId);
  });

  // send message
  socket.on("send message", (data) => {
    socket.to(data.chatId).emit("receive message", data);
  });

  // unsend message
  socket.on("unsend message", (data) => {
    socket.to(data.chatId).emit("message deleted", data);
  });

  socket.on("disconnect", () => {
    for (let [userId, socketId] of onlineUsers.entries()) {
      if (socketId === socket.id) {
        onlineUsers.delete(userId);
        break;
      }
    }
  });
});

// Start the actual server
server.listen(PORT, () => {
  console.log(`KapraKar Server and Sockets running on port ${PORT}`);
});