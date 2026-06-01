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

    // Validate inputs
    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({ message: "Invalid amount. Must be a number greater than 0." });
    }
    if (!orderId) {
      return res.status(400).json({ message: "Missing required field: orderId." });
    }

    const safepayPublicKey = process.env.SAFEPAY_PUBLIC_KEY || "sec_97992e36-93e4-43c3-adc6-884c1c292663";
    const safepaySecretKey = process.env.SAFEPAY_SECRET_KEY || "sk_test_your_secret_key";
    const backendUrl = process.env.BACKEND_URL || "https://fypkaprakar-production-4896.up.railway.app";

    console.log(`[SAFEPAY] Initiating checkout for orderId=${orderId}, amount=${parsedAmount} PKR`);

    // Safepay /order/v1/init expects amount in WHOLE PKR (not paisas)
    const payload = {
      client: safepayPublicKey,
      amount: parsedAmount,
      currency: "PKR",
      environment: "sandbox"
    };

    const response = await fetch("https://sandbox.api.getsafepay.com/order/v1/init", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const data = await response.json();
    console.log("[SAFEPAY] Init response:", JSON.stringify(data));

    if (!data || !data.data || !data.data.token) {
      console.error("[SAFEPAY] Failed to get tracker:", JSON.stringify(data));
      return res.status(400).json({ message: "Failed to create Safepay tracker", details: data });
    }

    const tracker = data.data.token;

    // Build the success/cancel redirect URLs
    const successUrl = encodeURIComponent(`${backendUrl}/api/payments/safepay/success?orderId=${orderId}`);
    const cancelUrl = encodeURIComponent(`${backendUrl}/api/payments/safepay/cancel?orderId=${orderId}`);

    // Correct Safepay checkout URL format
    const checkoutUrl = `https://sandbox.api.getsafepay.com/checkout/pay?env=sandbox&tracker=${tracker}&client=${safepayPublicKey}&source=checkout&redirect_url=${successUrl}&cancel_url=${cancelUrl}`;

    console.log(`[SAFEPAY] Checkout URL: ${checkoutUrl}`);

    // Save or update payment record in DB
    let payment = await Payment.findOne({ orderId });
    if (!payment) {
      payment = await Payment.create({
        orderId,
        userId: userId || '000000000000000000000000',
        amount: parsedAmount,
        method: 'online',
        status: 'pending',
        transactionId: tracker
      });
    } else {
      payment.transactionId = tracker;
      payment.status = 'pending';
      payment.amount = parsedAmount;
      await payment.save();
    }

    return res.status(200).json({ tracker, checkoutUrl, publicKey: safepayPublicKey });

  } catch (err) {
    console.error("[SAFEPAY] Error:", err.message);
    return res.status(500).json({ message: err.message });
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

// Safepay Webhook - called by Safepay when payment is confirmed
exports.safepayWebhook = async (req, res) => {
  try {
    const payload = req.body;
    console.log("[SAFEPAY WEBHOOK] Received:", JSON.stringify(payload));

    if (payload && payload.data && payload.data.state === "PAID") {
      const tracker = payload.data.tracker;
      const payment = await Payment.findOneAndUpdate(
        { transactionId: tracker },
        { status: 'paid' },
        { new: true }
      );

      if (payment) {
        const Order = require("../models/Order");
        await Order.findByIdAndUpdate(payment.orderId, { status: "ready" });
        console.log(`[SAFEPAY WEBHOOK] Payment confirmed for orderId=${payment.orderId}`);
      }
    }

    res.status(200).send("OK");
  } catch (err) {
    console.error("[SAFEPAY WEBHOOK] Error:", err.message);
    res.status(500).json({ message: err.message });
  }
};

// Called by Safepay after successful payment - updates DB and shows success page
exports.safepaySuccess = async (req, res) => {
  try {
    const { orderId } = req.query;
    if (orderId) {
      const payment = await Payment.findOneAndUpdate(
        { orderId },
        { status: 'paid' },
        { new: true }
      );
      if (payment) {
        const Order = require("../models/Order");
        await Order.findByIdAndUpdate(orderId, { status: "ready" });
        console.log(`[SAFEPAY SUCCESS] Payment confirmed for orderId=${orderId}`);
      }
    }
  } catch (e) {
    console.error("[SAFEPAY SUCCESS] Error:", e.message);
  }

  res.send(`
    <html>
      <head><title>Payment Successful</title></head>
      <body style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100vh; font-family:sans-serif; text-align:center; padding:20px; background:#f0faf0;">
        <div style="font-size:80px;">✅</div>
        <h1 style="color:#2e7d32; margin-top:16px;">Payment Successful!</h1>
        <p style="color:#555;">Your order has been confirmed. You can go back to the app.</p>
        <p style="color:#999; font-size:12px; margin-top:40px;">This window will close automatically...</p>
        <script>setTimeout(() => window.close(), 3000);</script>
      </body>
    </html>
  `);
};

// Called by Safepay when payment is cancelled
exports.safepayCancel = async (req, res) => {
  try {
    const { orderId } = req.query;
    if (orderId) {
      await Payment.findOneAndUpdate({ orderId }, { status: 'cancelled' });
      console.log(`[SAFEPAY CANCEL] Payment cancelled for orderId=${orderId}`);
    }
  } catch (e) {
    console.error("[SAFEPAY CANCEL] Error:", e.message);
  }

  res.send(`
    <html>
      <head><title>Payment Cancelled</title></head>
      <body style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100vh; font-family:sans-serif; text-align:center; padding:20px; background:#fff8f8;">
        <div style="font-size:80px;">❌</div>
        <h1 style="color:#c62828; margin-top:16px;">Payment Cancelled</h1>
        <p style="color:#555;">Your payment was not processed. You can go back to the app and try again.</p>
        <p style="color:#999; font-size:12px; margin-top:40px;">This window will close automatically...</p>
        <script>setTimeout(() => window.close(), 3000);</script>
      </body>
    </html>
  `);
};
