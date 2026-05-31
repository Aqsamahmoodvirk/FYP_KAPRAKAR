const express = require("express");
const router = express.Router();
const paymentController = require("../controllers/paymentController");
const verifyToken = require("../middleware/authMiddleware");

// create payment
router.post("/", verifyToken, paymentController.createPayment);

// update payment status
router.put("/:paymentId/status", verifyToken, paymentController.updatePaymentStatus);

// get payment by order
router.get("/order/:orderId", verifyToken, paymentController.getPaymentByOrder);

// get tailor wallet
router.get("/wallet/tailor/:tailorId", verifyToken, paymentController.getTailorWallet);

// Safepay integration
router.post("/safepay/generate-checkout", paymentController.initSafepay);
router.post("/safepay/webhook", paymentController.safepayWebhook);
router.get("/safepay/success", paymentController.safepaySuccess);
router.get("/safepay/cancel", paymentController.safepayCancel);
router.get("/:orderId/status", paymentController.getPaymentStatus);

module.exports = router;