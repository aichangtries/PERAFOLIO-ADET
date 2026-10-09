import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/profile_card.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/navigation/app_top_bar.dart';

/// Screen 11 — Personal Details (editable, saved to Hive).
class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final _profile = AppScope.read(context).profile;
  late final _name = TextEditingController(text: _profile.fullName);
  late final _email = TextEditingController(text: _profile.email);
  late final _mobile = TextEditingController(text: _profile.mobileNumber);
  late final _address = TextEditingController(text: _profile.homeAddress);
  late DateTime? _birthDate = _profile.dateOfBirth;
  late final _birth = TextEditingController(
    text: _birthDate == null ? '' : formatDate(_birthDate!),
  );
  bool _submitted = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _mobile, _address, _birth]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _nameError => _submitted ? validateName(_name.text) : null;
  String? get _emailError => _submitted ? validateEmail(_email.text) : null;
  String? get _mobileError => _submitted ? validateMobile(_mobile.text) : null;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birth.text = formatDate(picked);
    });
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (_nameError != null || _emailError != null || _mobileError != null) return;
    setState(() => _saving = true);
    await AppScope.read(context).updateProfile(
      fullName: _name.text,
      email: _email.text,
      mobileNumber: _mobile.text,
      homeAddress: _address.text,
      dateOfBirth: _birthDate,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).profile;
    const gap = SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppTopBar(title: 'Personal details', onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            ProfileCard(
              name: profile.fullName,
              email: 'Simulated profile · saved on this device',
              initial: profile.initial,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Full name',
              controller: _name,
              errorText: _nameError,
              onChanged: (_) => setState(() {}),
            ),
            gap,
            AppTextField(
              label: 'Email address',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onChanged: (_) => setState(() {}),
            ),
            gap,
            AppTextField(
              label: 'Mobile number',
              hintText: '0917 123 4567',
              controller: _mobile,
              keyboardType: TextInputType.phone,
              errorText: _mobileError,
              onChanged: (_) => setState(() {}),
            ),
            gap,
            AppTextField(label: 'Home address', controller: _address),
            gap,
            AppTextField(
              label: 'Date of birth',
              hintText: 'Select a date',
              controller: _birth,
              readOnly: true,
              onTap: _pickBirthDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Save changes', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
