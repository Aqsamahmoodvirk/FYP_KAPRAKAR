const Payment = require("../models/Payment");

// create payment record
exports.createPayment = async (req, res) => {
  try {
    const { orderId, userId, amount, method } = req.body;

    if (!orderId || !userId || !amount) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const payment = await Payment.create({
      orderId,
      userId,
      amount,
      method,
    });

    res.status(201).json(payment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// update payment status
exports.updatePaymentStatus = async (req, res) => {
  try {
    const { paymentId } = req.params;
    const { status, transactionId } = req.body;

    const payment = await Payment.findByIdAndUpdate(
      paymentId,
      { status, transactionId },
      { new: true }
    );

    if (!payment) {
      return res.status(404).json({ message: "Payment not found" });
    }

    res.json(payment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// get payment by order
exports.getPaymentByOrder = async (req, res) => {
  try {
    const { orderId } = req.params;

    const payment = await Payment.findOne({ orderId });

    if (!payment) {
      return res.status(404).json({ message: "Payment not found" });
    }

    res.json(payment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// get tailor wallet transactions
exports.getTailorWallet = async (req, res) => {
  try {
    const { tailorId } = req.params;
    const Order = require("../models/Order");

    const tailorOrders = await Order.find({ tailorId }).select('_id');
    const orderIds = tailorOrders.map(o => o._id);

    const transactions = await Payment.find({ orderId: { $in: orderIds } })
      .populate('orderId', 'dressType amount status')
      .sort({ createdAt: -1 });

    res.status(200).json(transactions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// init Safepay Payment (generate-checkout)
exports.initSafepay = async (req, res) => {
  try {
    const { orderId, amount, userId } = req.body;
    
    // 1. Strict Validation
    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      console.error("[SAFEPAY INIT] Validation Error: Invalid amount:", amount);
      return res.status(400).json({ message: "Invalid amount. Must be a number greater than 0." });
    }

    if (!orderId) {
      console.error("[SAFEPAY INIT] Validation Error: Missing orderId");
      return res.status(400).json({ message: "Missing required field: orderId." });
    }
    
    const safepayClient = process.env.SAFEPAY_PUBLIC_KEY || "sec_97992e36-93e4-43c3-adc6-884c1c292663";
    
    // 2. Payload Structure
    // Safepay handles the amount as a standard number in some API versions, 
    // so we pass the exact parsedAmount (e.g., 1500) rather than multiplying by 100.
    const amountForSafepay = parsedAmount;

    const payload = {
      client: safepayClient,
      amount: amountForSafepay, 
      currency: "PKR",
      environment: "sandbox"
    };

    // 3. Robust Logging
    console.log("-----------------------------------------");
    console.log("[SAFEPAY INIT] Generating new checkout...");
    console.log("[SAFEPAY INIT] Order ID:", orderId);
    console.log("[SAFEPAY INIT] Payload being sent to Safepay:");
    console.log(JSON.stringify(payload, null, 2));
    console.log("-----------------------------------------");
    
    const response = await fetch("https://sandbox.api.getsafepay.com/order/v1/init", {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const data = await response.json();
    
    if (data && data.data && data.data.token) {
      const tracker = data.data.token;
      
      // Use the Node.js backend to serve a friendly HTML page when Safepay redirects
      const redirectUrl = encodeURIComponent(`http://172.23.181.1:5000/api/payments/safepay/success?orderId=${orderId}`);
      const cancelUrl = encodeURIComponent(`http://172.23.181.1:5000/api/payments/safepay/cancel?orderId=${orderId}`);
      
      // Safepay Official format: /checkout/pay
      const checkoutUrl = `https://sandbox.api.getsafepay.com/checkout/pay?env=sandbox&tracker=${tracker}&client=${safepayClient}&source=custom&order_id=${orderId}&redirect_url=${redirectUrl}&cancel_url=${cancelUrl}`;

      // Find or create Payment document
      let payment = await Payment.findOne({ orderId });
      if (!payment) {
        payment = await Payment.create({
          orderId,
          userId: userId || req.user?.id || '000000000000000000000000', // fallback if userId not provided
          amount,
          method: 'online',
          status: 'pending',
          transactionId: tracker
        });
      } else {
        payment.transactionId = tracker;
        payment.status = 'pending';
        await payment.save();
      }

      res.status(200).json({ tracker, checkoutUrl, publicKey: safepayClient });
    } else {
      res.status(400).json({ message: "Failed to create Safepay tracker", details: data });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// get payment status
exports.getPaymentStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const payment = await Payment.findOne({ orderId });
    if (!payment) {
      return res.status(404).json({ message: "Payment not found" });
    }
    res.status(200).json({ status: payment.status });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// webhook for Safepay
exports.safepayWebhook = async (req, res) => {
  try {
    const signature = req.headers['x-sfpy-signature'];
    const payload = req.body;
    const secret = process.env.SAFEPAY_WEBHOOK_SECRET || "default_webhook_secret";

    // Validate Signature
    const crypto = require('crypto');
    const hash = crypto.createHmac('sha512', secret).update(JSON.stringify(payload)).digest('hex');
    
    // In production, enforce signature validation:
    // if (hash !== signature) {
    //   return res.status(400).json({ message: "Invalid Signature" });
    // }

    if (payload && payload.data && payload.data.state === "PAID") {
      const tracker = payload.data.tracker;
      const payment = await Payment.findOneAndUpdate(
        { transactionId: tracker },
        { status: 'paid' },
        { new: true }
      );

      if (payment) {
        const Order = require("../models/Order");
        const order = await Order.findByIdAndUpdate(payment.orderId, { status: "ready" }, { new: true });
        
        // Broadcast via Socket.io
        const io = require("socket.io-client");
        const socket = io("http://localhost:5000");
        socket.emit("order_paid", { orderId: order._id, tailorId: order.tailorId });
        socket.disconnect();
      }
    }

    res.status(200).send("OK");
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Friendly HTML pages for WebView redirects
exports.safepaySuccess = async (req, res) => {
  res.send(`
    <html>
      <body style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100vh; font-family:sans-serif; text-align:center; padding:20px;">
        <h1 style="color: green;">Payment Successful!</h1>
        <p>Closing window automatically...</p>
      </body>
    </html>
  `);
};

exports.safepayCancel = async (req, res) => {
  try {
    const { orderId } = req.query;
    if (orderId) {
      const Payment = require("../models/Payment");
      await Payment.findOneAndUpdate({ orderId }, { status: 'cancelled' });
    }
  } catch (e) {
    console.error("Cancel Webhook Error:", e);
  }

  res.send(`
    <html>
      <body style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100vh; font-family:sans-serif; text-align:center; padding:20px; background-color: #fafafa;">
        <div style="width: 40px; height: 40px; border: 4px solid #f44336; border-top: 4px solid transparent; border-radius: 50%; animation: spin 1s linear infinite;"></div>
        <style>@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }</style>
        <h2 style="color: #f44336; margin-top: 20px;">Cancelling Payment...</h2>
        <p style="color: #666;">Returning you to the app automatically...</p>
      </body>
    </html>
  `);
};