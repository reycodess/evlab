import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _section(context, 'Appearance', Icons.palette_outlined, [
            ValueListenableBuilder<ThemeMode>(
              valueListenable: EVLabSettings.themeMode,
              builder: (context, value, child) => DropdownButtonFormField<ThemeMode>(
                initialValue: value,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System default')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light mode')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark mode')),
                ],
                onChanged: (v) { if (v != null) EVLabSettings.themeMode.value = v; },
              ),
            ),
          ]),
          _section(context, 'Laboratory Experience', Icons.science_outlined, [
            _toggle('Animations', 'Keep reaction and instrument animations active.', EVLabSettings.animationsEnabled),
            _toggle('Scientific guidance', 'Show explanations while you prepare and run experiments.', EVLabSettings.scientificGuidance),
            _toggle('Sound effects', 'Enable optional laboratory sound effects.', EVLabSettings.soundEnabled),
            _toggle('Compact mode', 'Use tighter cards and spacing on smaller screens.', EVLabSettings.compactMode),
          ]),
          _section(context, 'About EV-LAB', Icons.info_outline, [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.school_outlined),
              title: Text('Research learning tool'),
              subtitle: Text('Interactive enzyme activity simulation for educational evaluation.'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: EVLabColors.emeraldDark), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))]),
          const SizedBox(height: 10),
          ...children,
        ]),
      ),
    );
  }

  Widget _toggle(String title, String subtitle, ValueNotifier<bool> notifier) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, child) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        value: value,
        activeThumbColor: EVLabColors.emerald,
        onChanged: (v) => notifier.value = v,
      ),
    );
  }
}
