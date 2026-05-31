const Order = require("../models/Order");
const { createNotification } = require("./notificationController");
const upload = require("../middleware/uploadMiddleware");



const Tailor = require("../models/Tailor");

// =======================================
// CREATE ORDER
// =======================================

exports.createOrder = async (req, res) => {
  console.log("\n[DEBUG - STEP 1] createOrder triggered!");
  console.log("[DEBUG - STEP 1] Request Payload:", JSON.stringify(req.body, null, 2));
  try {
    const {
      customerId,
      tailorId,
      dressType,
      notes,
      measurementId,
      isUrgent,
      amount,
      suggestedImageUrl,
    } = req.body;

    const tailor = await Tailor.findById(tailorId);
    if (!tailor) {
      return res.status(404).json({ message: "Tailor not found" });
    }

    // Server-side Pricing
    let basePrice = tailor.categoryPrices.get(dressType);
    if (!basePrice) {
      basePrice = amount || 1500; // fallback
    }

    let urgentFeeApplied = 0;
    let turnaroundDays = tailor.categoryTurnaround?.get(dressType) || 7;

    const offersUrgent = tailor.urgentCategoryEnabled?.get(dressType) || false;

    if (isUrgent && offersUrgent) {
      urgentFeeApplied = tailor.urgentCategoryPrices?.get(dressType) || 500;
      turnaroundDays = tailor.urgentCategoryTurnaround?.get(dressType) || 3;
    }

    const finalAmount = basePrice + urgentFeeApplied;

    // Server-side UTC Delivery Date
    const dueDate = new Date();
    dueDate.setUTCDate(dueDate.getUTCDate() + turnaroundDays);

    // Generate Order Number (e.g. 0001-0526)
    const now = new Date();
    const dateStr = String(now.getMonth() + 1).padStart(2, '0') + String(now.getFullYear()).slice(-2);
    const userOrdersCount = await Order.countDocuments({ customerId });
    const orderNumber = String(userOrdersCount + 1).padStart(4, '0') + '-' + dateStr;

    const order = new Order({
      customerId,
      tailorId,
      dressType,
      notes,
      measurementId,
      amount: finalAmount,
      expectedDeliveryDate: dueDate,
      orderNumber,
      isUrgent: isUrgent || false,
      urgentFeeApplied,
      suggestedImageUrl,
    });

    console.log("[DEBUG - STEP 1] Order Model created before save:", order);

    await order.save();

    console.log("[DEBUG - STEP 1] Order saved successfully to MongoDB! Order ID:", order._id);

    // Notify the tailor about the new order
    if (tailor.userId) {
      await createNotification(
        tailor.userId,
        "New Order Received",
        `You have received a new order for ${dressType}.`,
        "order_update",
        order._id,
        null
      );
    }

    res.status(201).json({
      message: "Order created successfully",
      order,
    });

  } catch (error) {
    console.error("[DEBUG - STEP 1] Error saving order:", error);
    res.status(500).json({
      message: error.message,
    });
  }
};



// =======================================
// GET CUSTOMER ORDERS
// =======================================

exports.getCustomerOrders = async (req, res) => {
  try {

    const orders = await Order.find({
      customerId: req.params.customerId,
    })
      .populate("tailorId")
      .populate("measurementId")
      .sort({ createdAt: -1 });

    res.status(200).json(orders);

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};



// =======================================
// GET TAILOR ORDERS
// =======================================

exports.getTailorOrders = async (req, res) => {
  console.log("\n[DEBUG - STEP 2] getTailorOrders triggered!");
  console.log("[DEBUG - STEP 2] Fetching orders for tailorId:", req.params.tailorId);
  try {
    const Customer = require("../models/Customer");
    const orders = await Order.find({
      tailorId: req.params.tailorId,
    })
      .populate("customerId")
      .populate("measurementId")
      .sort({ createdAt: -1 });

    const formattedOrders = await Promise.all(orders.map(async (order) => {
      let orderObj = order.toObject();
      if (order.customerId) {
        const customerProfile = await Customer.findOne({ userId: order.customerId._id });
        orderObj.customerId.name = customerProfile && customerProfile.fullName ? customerProfile.fullName : "Unknown Customer";
      }
      return orderObj;
    }));

    console.log(`[DEBUG - STEP 2] Found ${orders.length} orders for this tailor.`);

    res.status(200).json(formattedOrders);

  } catch (error) {
    console.error("[DEBUG - STEP 2] Error fetching tailor orders:", error);
    res.status(500).json({
      message: error.message,
    });
  }
};



// =======================================
// UPDATE ORDER STATUS
// =======================================

exports.updateOrderStatus = async (req, res) => {
  try {

    const { status } = req.body;

    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.orderId,
      { status },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    if (status === 'accepted') {
      await createNotification(
        updatedOrder.customerId,
        'Order Accepted',
        'Your tailor has accepted your order and will begin soon.',
        'order_update',
        updatedOrder._id,
        null
      );
    }

    if (status === 'fabric-received') {
      await createNotification(
        updatedOrder.customerId,
        'Fabric Received',
        'Your tailor has received the fabric and will start cutting soon.',
        'order_update',
        updatedOrder._id,
        null
      );
    }

    if (status === 'ready') {
      await createNotification(
        updatedOrder.customerId,
        'Preview Model Ready',
        'Your dress is stitched and ready for preview!',
        'order_update',
        updatedOrder._id,
        null
      );
    }

    if (status === 'completed') {
      await createNotification(
        updatedOrder.customerId,
        'Order Completed',
        'Your order has been completed successfully.',
        'order_complete',
        updatedOrder._id,
        null
      );
    }

    if (status === 'revision-in-progress') {
      await createNotification(
        updatedOrder.customerId,
        'Revision In Progress',
        'Your tailor is working on the requested changes.',
        'order_update',
        updatedOrder._id,
        null
      );
    }

    res.status(200).json({
      message: "Order updated successfully",
      order: updatedOrder,
    });

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};



// =======================================
// GET SINGLE ORDER
// =======================================

exports.getSingleOrder = async (req, res) => {
  try {

    const order = await Order.findById(req.params.orderId)
      .populate("customerId")
      .populate("tailorId");

    if (!order) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    res.status(200).json(order);

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};



// =======================================
// DELETE ORDER
// =======================================

exports.deleteOrder = async (req, res) => {
  try {

    const deletedOrder = await Order.findByIdAndDelete(
      req.params.orderId
    );

    if (!deletedOrder) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    res.status(200).json({
      message: "Order deleted successfully",
    });

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

// =======================================
// UPLOAD FINAL DRESS IMAGE
// =======================================

// Helper for background polling Meshy API
async function pollMeshyTask(taskId, orderId) {
  const axios = require('axios');
  const fs = require('fs');
  const path = require('path');
  const Order = require('../models/Order');
  const { createNotification } = require('./notificationController');

  const MESHY_API_KEY = process.env.MESHY_API_KEY;
  let attempts = 0;
  const maxAttempts = 60; // 10 minutes total (10s intervals)

  const interval = setInterval(async () => {
    try {
      attempts++;
      const response = await axios.get(`https://api.meshy.ai/openapi/v1/image-to-3d/${taskId}`, {
        headers: { 'Authorization': `Bearer ${MESHY_API_KEY}` }
      });
      const task = response.data;

      if (task.status === 'SUCCEEDED') {
        clearInterval(interval);
        const modelUrl = task.model_urls.glb;

        const modelRes = await axios.get(modelUrl, { responseType: 'stream' });
        const fileName = `model_${orderId}.glb`;
        const savePath = path.join(__dirname, '../../uploads', fileName);

        const writer = fs.createWriteStream(savePath);
        modelRes.data.pipe(writer);

        writer.on('finish', async () => {
          const updatedOrder = await Order.findByIdAndUpdate(orderId, {
            finalDressModelUrl: `/uploads/${fileName}`
          }, { new: true });

          await createNotification(
            updatedOrder.customerId,
            "3D Model Ready",
            "The 3D model of your final dress is ready to view!",
            "order_update",
            orderId,
            null
          );
        });
      } else if (task.status === 'FAILED' || task.status === 'EXPIRED') {
        clearInterval(interval);
        console.error("Meshy Task Failed or Expired for order:", orderId);
      }

      if (attempts >= maxAttempts) {
        clearInterval(interval);
        console.error("Meshy Task Polling timeout for order:", orderId);
      }
    } catch (err) {
      console.error("Polling error:", err.message);
    }
  }, 10000);
}

exports.uploadFinalDressImage = async (req, res) => {
  try {
    const { orderId } = req.params;
    const order = await Order.findById(orderId);

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (!req.file) {
      return res.status(400).json({ message: "No image uploaded" });
    }

    const path = require('path');
    const filename = path.basename(req.file.path);
    order.finalDressImageUrl = `/uploads/${filename}`;
    order.status = "pending_customer_review";
    await order.save();

    // Trigger Meshy 3D Model Generation
    const MESHY_API_KEY = process.env.MESHY_API_KEY;
    if (MESHY_API_KEY) {
      try {
        const fs = require("fs");
        const axios = require("axios");

        const imageBuffer = fs.readFileSync(req.file.path);
        const base64Image = imageBuffer.toString("base64");
        const ext = req.file.path.split('.').pop().toLowerCase();
        const mimeType = ext === 'png' ? 'image/png' : 'image/jpeg';
        const dataUri = `data:${mimeType};base64,${base64Image}`;

        const taskRes = await axios.post("https://api.meshy.ai/openapi/v1/image-to-3d", {
          image_url: dataUri,
          enable_pbr: true,
          pose_mode: "a-pose",
          symmetry_mode: "auto"
        }, {
          headers: { "Content-Type": "application/json", "Authorization": `Bearer ${MESHY_API_KEY}` }
        });

        if (taskRes.data.result) {
          order.tripoTaskId = taskRes.data.result;
          await order.save();
          pollMeshyTask(order.tripoTaskId, orderId); // Start background polling
        }
      } catch (err) {
        console.error("Meshy generation trigger failed:", err.response?.data || err.message);
      }
    }

    await createNotification(
      order.customerId,
      "Your dress is ready for review",
      "Your tailor has uploaded the final dress photo.",
      "order_update",
      orderId,
      null
    );

    return res.status(200).json(order);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// =======================================
// SUBMIT REVISION REQUEST
// =======================================
exports.submitRevisionRequest = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { revisionNote, revisionCategory, revisionImageUrl } = req.body;

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    const updatedOrder = await Order.findByIdAndUpdate(
      orderId,
      {
        status: "revision-requested",
        revisionNote: revisionNote,
        revisionCategory: revisionCategory,
        revisionImageUrl: revisionImageUrl || null,
        $inc: { revisionCount: 1 }
      },
      { new: true }
    );

    const Tailor = require('../models/Tailor');
    const tailor = await Tailor.findById(order.tailorId);
    if (tailor) {
      await createNotification(
        tailor.userId,
        "Customer requested changes",
        "A customer has requested revisions on their order.",
        "revision_request",
        orderId,
        null
      );
    }

    return res.status(200).json(updatedOrder);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// =======================================
// UPLOAD REVISION IMAGE
// =======================================
exports.uploadRevisionImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "No image uploaded" });
    }
    return res.status(200).json({ imageUrl: req.file.path });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// =======================================
// SUBMIT ORDER FEEDBACK
// =======================================
exports.submitOrderFeedback = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { rating, comment } = req.body;

    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: "Rating must be between 1 and 5" });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    order.feedbackRating = rating;
    order.feedbackComment = comment;
    await order.save();

    // Recalculate tailor average rating
    const tailorId = order.tailorId;
    const feedbackOrders = await Order.find({
      tailorId: tailorId,
      feedbackRating: { $ne: null }
    });

    if (feedbackOrders.length > 0) {
      const sum = feedbackOrders.reduce((acc, curr) => acc + curr.feedbackRating, 0);
      const averageRating = sum / feedbackOrders.length;

      const Tailor = require('../models/Tailor');
      const tailor = await Tailor.findByIdAndUpdate(tailorId, {
        rating: averageRating,
        reviewCount: feedbackOrders.length
      });

      if (tailor && tailor.userId) {
        await createNotification(
          tailor.userId,
          "New Customer Review",
          `A customer just left a ${rating}-star review on their order.`,
          "order_complete",
          orderId,
          null
        );
      }
    }

    return res.status(200).json({ success: true });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// =======================================
// COMPLETE ORDER (Real Implementation)
// =======================================
exports.completeOrder = async (req, res) => {
  try {
    const { orderId } = req.params;

    if (!req.file) {
      return res.status(400).json({ message: "No image uploaded" });
    }

    // Format file path for URL (replace backslashes from Windows)
    const filePath = req.file.path.replace(/\\/g, "/");

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    // Update order with image URL and new status
    order.dressImageUrl = filePath;
    order.status = "pending_customer_review";

    await order.save();

    // Notify the customer
    await createNotification(
      order.customerId,
      "Order Completed",
      "Your tailor has completed your order. Please review the final result.",
      "order_update",
      orderId,
      null
    );

    return res.status(200).json({
      message: "Order completed successfully",
      order: order
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};