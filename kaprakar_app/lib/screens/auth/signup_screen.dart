import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_input_field.dart';
import '../../services/journey_service.dart';
import '../../services/auth_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  String _selectedCity = "Lahore";

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final name = _nameController.text.trim();
        final phone = _phoneController.text.trim();
        final role = JourneyService().userRole;

        // Firebase Register
        await authService.registerUser(email, password);

        // Get Firebase Token
        String? token = await authService.getFirebaseToken();

        // Send token and payload to backend
        if (token != null) {
          final userProfile = await authService.syncUser(token, body: {
            "name": name,
            "phone": phone,
            "role": role,
            "city": _selectedCity,
          });
          
          final dbRole = userProfile['user']['role'];
          final selectedRole = role.toLowerCase();

          if (dbRole != selectedRole) {
            await authService.signOut();
            throw Exception('Account already exists in a different portal. Please login to the correct portal.');
          }

          JourneyService().setCurrentUserId(userProfile['user']['_id']);
        }

        if (!mounted) return;

        // Navigate based on role
        if (role == 'Tailor') {
          Navigator.pushReplacementNamed(context, AppRoutes.tailorSetup);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.createAccount),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.joinKaprakar,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  AppLocalizations.of(context)!.startYourCustomFashionJourney,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppInputField(
                  label: AppLocalizations.of(context)!.email,
                  hint: AppLocalizations.of(context)!.enterYourEmail,
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                AppInputField(
                  label: AppLocalizations.of(context)!.password,
                  hint: AppLocalizations.of(context)!.createAPassword,
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                if (JourneyService().userRole == 'Customer') ...[
                  AppInputField(
                    label: AppLocalizations.of(context)!.fullName,
                    hint: AppLocalizations.of(context)!.enterYourName,
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    label: AppLocalizations.of(context)!.phoneNumber,
                    hint: AppLocalizations.of(context)!.enterYourPhone,
                    controller: _phoneController,
                    prefixIcon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                if (JourneyService().userRole == 'Customer') ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.city, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCity,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ["Lahore", "Karachi", "Islamabad", "Rawalpindi", "Faisalabad", "Multan", "Sialkot"]
                            .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCity = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                const SizedBox(height: AppSpacing.xxl),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: AppLocalizations.of(context)!.signUp,
                        onPressed: _handleSignup,
                      ),

                const SizedBox(height: AppSpacing.lg),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${AppLocalizations.of(context)!.alreadyHaveAnAccount} ", style: AppTextStyles.bodyMedium),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.login, style: AppTextStyles.linkText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
