import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_input_field.dart';
import '../../services/journey_service.dart';
import '../../services/auth_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {

        // Firebase Login
        await authService.loginUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Get Firebase Token
        String? token = await authService.getFirebaseToken();

        // Send token to backend
        if (token != null) {
          final userProfile = await authService.syncUser(token);
          
          final dbRole = userProfile['user']['role'];
          final selectedRole = JourneyService().userRole.toLowerCase();

          if (dbRole != selectedRole) {
            await authService.signOut();
            throw Exception('Invalid credentials for this portal.');
          }

          JourneyService().setCurrentUserId(userProfile['user']['_id']);
        }

        if (!mounted) return;

        // Navigate based on role
        final role = JourneyService().userRole;

        if (role == 'Tailor') {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.tailorDashboard,
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.customerHome,
          );
        }

      } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                // Premium Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_person_outlined,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  "Step into Kaprakar",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in as ${JourneyService().userRole}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form Container
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                AppInputField(
                  label: AppLocalizations.of(context)!.email,
                  hint: AppLocalizations.of(context)!.enterYourEmail,
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter email';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                AppInputField(
                  label: AppLocalizations.of(context)!.password,
                  hint: AppLocalizations.of(context)!.enterYourPassword,
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter password';
                    return null;
                  },
                ),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword), 
                    child: Text(AppLocalizations.of(context)!.forgotPassword1, style: AppTextStyles.linkText),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: AppLocalizations.of(context)!.login,
                        onPressed: _handleLogin,
                      ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${AppLocalizations.of(context)!.dontHaveAnAccount} ", style: AppTextStyles.bodyMedium),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                      child: Text(AppLocalizations.of(context)!.createAccount, style: AppTextStyles.linkText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
