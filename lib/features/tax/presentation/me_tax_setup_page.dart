import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/country_config_provider.dart';
import '../services/tax_service.dart';

/// Middle East tax setup: VAT filing details → generates VAT (and optional
/// corporate tax) deadlines into tax_events. KSA can choose monthly/quarterly.
class MeTaxSetupPage extends ConsumerStatefulWidget {
  const MeTaxSetupPage({super.key});

  @override
  ConsumerState<MeTaxSetupPage> createState() => _MeTaxSetupPageState();
}

class _MeTaxSetupPageState extends ConsumerState<MeTaxSetupPage> {
  final _taxService = TaxService();
  final _trnController = TextEditingController();

  bool _vatRegistered = true;
  String _filingFrequency = 'quarterly';
  bool _corporate = false;
  bool _isSaving = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final profile = await _taxService.loadProfile();
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('user_type') ?? '';
    if (!mounted) return;
    setState(() {
      if (profile != null) {
        _vatRegistered = profile['vat_registered'] as bool? ?? true;
        _filingFrequency = profile['filing_frequency'] as String? ?? 'quarterly';
        _trnController.text = profile['vat_registration_number'] as String? ?? '';
      }
      // Default corporate tax on for companies.
      _corporate = userType == 'llc' || userType == 'free_zone';
      _isSaving = false;
    });
  }

  @override
  void dispose() {
    _trnController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.read(countryConfigProvider);
    setState(() => _isSaving = true);

    await _taxService.saveMeProfileAndGenerateEvents(
      l10n: l10n,
      localeName: Localizations.localeOf(context).toString(),
      countryCode: config.countryCode,
      vatRegistered: _vatRegistered,
      filingFrequency: _filingFrequency,
      corporate: _corporate,
      vatNumber: _trnController.text.trim().isEmpty ? null : _trnController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.meTaxSaved)),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.meTaxSetupTitle)),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(
                  l10n.meTaxSetupIntro,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),

                _card(isDark, [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(l10n.meTaxVatRegistered,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.meTaxVatRegisteredSub,
                        style: const TextStyle(fontSize: 12)),
                    value: _vatRegistered,
                    activeColor: const Color(0xFF1E88E5),
                    onChanged: (v) => setState(() => _vatRegistered = v),
                  ),
                ]),

                if (_vatRegistered) ...[
                  const SizedBox(height: 16),
                  _sectionLabel(l10n.meTaxFilingFrequency, isDark),
                  Row(
                    children: [
                      _freqChip(l10n.meTaxQuarterly, 'quarterly'),
                      const SizedBox(width: 10),
                      _freqChip(l10n.meTaxMonthly, 'monthly'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _card(isDark, [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _trnController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: l10n.myBizTaxNumber,
                          hintText: l10n.myBizTaxNumberHint,
                          icon: const Icon(Icons.confirmation_number_outlined),
                        ),
                      ),
                    ),
                  ]),
                ],

                const SizedBox(height: 16),
                _card(isDark, [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(l10n.meTaxCorporate,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.meTaxCorporateSub,
                        style: const TextStyle(fontSize: 12)),
                    value: _corporate,
                    activeColor: const Color(0xFF1E88E5),
                    onChanged: (v) => setState(() => _corporate = v),
                  ),
                ]),

                const SizedBox(height: 32),
                PrimaryButton(
                  label: l10n.save,
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
    );
  }

  Widget _freqChip(String label, String value) {
    final selected = _filingFrequency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filingFrequency = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1E88E5).withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF1E88E5) : Theme.of(context).dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? const Color(0xFF1E88E5) : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.blueGrey,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _card(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
