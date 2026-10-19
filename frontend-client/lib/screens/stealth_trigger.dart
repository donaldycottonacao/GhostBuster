import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/call_state.dart';
import '../providers/call_provider.dart';
import 'incoming_call_ui.dart';

/// Screen for configuring stealth timer countdown and caller persona triggers.
class StealthTriggerScreen extends StatelessWidget {
  const StealthTriggerScreen({super.key});

  void _armEscape(BuildContext context, CallProvider provider) {
    provider.startCountdown(
      onTriggered: () {
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const IncomingCallScreen(),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, CallProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            l10n.selectLanguage,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.english, style: const TextStyle(color: Colors.white)),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: provider.currentLocale.languageCode,
                  onChanged: (val) {
                    if (val != null) provider.setLocale(Locale(val));
                    Navigator.of(dialogContext).pop();
                  },
                ),
                onTap: () {
                  provider.setLocale(const Locale('en'));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                title: Text(l10n.tagalog, style: const TextStyle(color: Colors.white)),
                leading: Radio<String>(
                  value: 'tl',
                  groupValue: provider.currentLocale.languageCode,
                  onChanged: (val) {
                    if (val != null) provider.setLocale(Locale(val));
                    Navigator.of(dialogContext).pop();
                  },
                ),
                onTap: () {
                  provider.setLocale(const Locale('tl'));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                title: Text(l10n.cebuano, style: const TextStyle(color: Colors.white)),
                leading: Radio<String>(
                  value: 'ceb',
                  groupValue: provider.currentLocale.languageCode,
                  onChanged: (val) {
                    if (val != null) provider.setLocale(Locale(val));
                    Navigator.of(dialogContext).pop();
                  },
                ),
                onTap: () {
                  provider.setLocale(const Locale('ceb'));
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPersonaLocalizedName(CallerPersona persona, AppLocalizations l10n) {
    switch (persona.id) {
      case 'mom':
        return l10n.personaMom;
      case 'landlord':
        return l10n.personaLandlord;
      case 'work_boss':
        return l10n.personaOffice;
      default:
        return persona.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<CallProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.lightBlueAccent),
            tooltip: l10n.language,
            onPressed: () => _showLanguageDialog(context, provider, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tactical Header Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    Icon(
                      provider.isCountdownActive ? Icons.timer : Icons.security,
                      color: provider.isCountdownActive ? Colors.amberAccent : Colors.lightBlueAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.isCountdownActive ? l10n.escapeSequenceArmed : l10n.appSubtitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.isCountdownActive
                                ? l10n.incomingCallTriggersIn(provider.remainingCountdown)
                                : l10n.configureTriggerDesc,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Persona Selector Header
              Text(
                l10n.callerPersona,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Persona list options
              ...CallerPersona.defaultPersonas.map((persona) {
                final isSelected = provider.persona.id == persona.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    tileColor: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.blueAccent : const Color(0xFF334155),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.blueAccent : const Color(0xFF334155),
                      child: Text(
                        persona.name[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      _getPersonaLocalizedName(persona, l10n),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      persona.number,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blueAccent)
                        : null,
                    onTap: provider.isCountdownActive
                        ? null
                        : () => provider.setPersona(persona),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Delay Timer Selector Header
              Text(
                l10n.triggerDelay,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Delay preset chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [5, 15, 30, 60].map((seconds) {
                  final isSelected = provider.delaySeconds == seconds;
                  return ChoiceChip(
                    label: Text('${seconds}s'),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: provider.isCountdownActive
                        ? null
                        : (selected) {
                            if (selected) {
                              provider.setDelaySeconds(seconds);
                            }
                          },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Action Trigger Button
              if (provider.isCountdownActive)
                ElevatedButton.icon(
                  onPressed: () => provider.cancelCountdown(),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.cancelCountdown(provider.remainingCountdown)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _armEscape(context, provider),
                  icon: const Icon(Icons.bolt),
                  label: Text(l10n.armEscapeCall(provider.delaySeconds)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  l10n.simulationDisclaimer,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
