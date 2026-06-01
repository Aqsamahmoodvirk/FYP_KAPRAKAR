import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../services/journey_service.dart';
import '../../repositories/order_repository.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String userId;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.userId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isSuccess = false;
  String _selectedMethod = 'card';

  final _cardNumberController = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryController = TextEditingController(text: '12/26');
  final _cvvController = TextEditingController(text: '123');
  final _nameController = TextEditingController(text: 'Test User');

  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Call backend to mark payment as paid and order as ready
      final service = JourneyService();
      await service.confirmPaymentDirectly(widget.orderId, widget.userId, widget.amount);

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
        });
        _checkController.forward();
        HapticFeedback.heavyImpact();

        // Return to previous screen after 2.5 seconds
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessScreen();
    if (_isProcessing) return _buildProcessingScreen();
    return _buildPaymentForm();
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _checkAnimation,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 10),
            Text(
              'PKR ${widget.amount.toStringAsFixed(0)} paid via Safepay',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Your tailor has been notified.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Processing Payment...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Please wait while we confirm your payment.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 8,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF004D54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Secure Checkout', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Powered by Safepay', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('SSL Secured', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006B74), Color(0xFF004D54)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          'PKR ${widget.amount.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.verified_outlined, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            const Text('Order payment — KapraKar', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Selection
                  const Text('Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMethodTile('card', Icons.credit_card_rounded, 'Credit/Debit Card'),
                      const SizedBox(width: 12),
                      _buildMethodTile('easypaisa', Icons.account_balance_wallet_outlined, 'Easypaisa'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (_selectedMethod == 'card') _buildCardForm()
                  else _buildEasypaisaForm(),

                  const SizedBox(height: 24),

                  // Test Mode Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'TEST MODE — Use the pre-filled test card details.',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _processPayment,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pay PKR ${widget.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Trust indicators
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.security, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('256-bit SSL encryption', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(width: 16),
                        Icon(Icons.shield_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('PCI DSS Compliant', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(String value, IconData icon, String label) {
    final isSelected = _selectedMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade400, size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : Colors.grey.shade600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Card Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildInput('Cardholder Name', Icons.person_outline, _nameController),
        const SizedBox(height: 12),
        _buildInput('Card Number', Icons.credit_card, _cardNumberController),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInput('Expiry (MM/YY)', Icons.calendar_today_outlined, _expiryController)),
            const SizedBox(width: 12),
            Expanded(child: _buildInput('CVV', Icons.lock_outline, _cvvController, obscure: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildEasypaisaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Easypaisa Number', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildInput('03XX-XXXXXXX', Icons.phone_android_outlined, TextEditingController(text: '0300-1234567')),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade700, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'You will receive an OTP on your Easypaisa number to confirm payment.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController controller, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
