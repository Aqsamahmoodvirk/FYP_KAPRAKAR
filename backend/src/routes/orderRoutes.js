const express = require("express");

const router = express.Router();
const verifyToken = require("../middleware/authMiddleware");
const upload = require("../middleware/uploadMiddleware");
const orderController = require("../controllers/orderController");

const {
  createOrder,
  getCustomerOrders,
  getTailorOrders,
  updateOrderStatus,
  getSingleOrder,
  deleteOrder,
} = require("../controllers/orderController");



// =======================================
// CREATE ORDER
// =======================================

router.post("/create", createOrder);



// =======================================
// GET CUSTOMER ORDERS
// =======================================

router.get("/customer/:customerId", getCustomerOrders);



// =======================================
// GET TAILOR ORDERS
// =======================================

router.get("/tailor/:tailorId", getTailorOrders);



// =======================================
// UPDATE ORDER STATUS
// =======================================

router.put("/:orderId/status", updateOrderStatus);

// =======================================
// DELETE ORDER
// =======================================

router.delete("/:orderId", deleteOrder);

// =======================================
// GET SINGLE ORDER
// =======================================

router.get("/:orderId", getSingleOrder);

// =======================================
// NEW ORDER ROUTING FOR IMAGES, REVISIONS & FEEDBACK
// =======================================

router.post(
  '/:orderId/final-image',
  verifyToken,
  upload.single('dressImage'),
  orderController.uploadFinalDressImage
);

router.put(
  '/:orderId/revision',
  verifyToken,
  orderController.submitRevisionRequest
);

router.post(
  '/:orderId/revision-image',
  verifyToken,
  upload.single('revisionImage'),
  orderController.uploadRevisionImage
);

router.post(
  '/:orderId/feedback',
  verifyToken,
  orderController.submitOrderFeedback
);

router.post(
  '/:orderId/complete',
  upload.single('dressImage'),
  orderController.completeOrder
);

module.exports = router;