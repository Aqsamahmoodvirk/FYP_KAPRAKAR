
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class ChangeCityScreen extends StatefulWidget {
  // Constructor with key forwarding
  const ChangeCityScreen({super.key});

  @override
  State<ChangeCityScreen> createState() => _ChangeCityScreenState();
}

class _ChangeCityScreenState extends State<ChangeCityScreen> {
  // Read initial city from service
  late String _selectedCity;
  
  final List<String> _cities = [
    "Lahore", "Karachi", "Islamabad", "Rawalpindi", "Faisalabad", "Multan", "Sialkot"
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = JourneyService().userCity;
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.changeCity)),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final bool isSelected = city == _selectedCity;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isSelected ? const BorderSide(color: AppColors.primary, width: 2) : const BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              title: Text(city, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primary : Colors.black87)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              onTap: () async {
                setState(() {
                  _selectedCity = city;
                });
                
                JourneyService().updateUserCity(city);

                await Future.delayed(const Duration(milliseconds: 300));
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
