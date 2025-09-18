import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;

  const ThemeToggle({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (isCompact) {
          return IconButton(
            icon: Icon(themeProvider.themeIcon),
            onPressed: () async {
              await themeProvider.toggleTheme();
            },
            tooltip: 'Toggle theme (${themeProvider.themeModeName})',
          );
        }

        return PopupMenuButton<ThemeMode>(
          icon: Icon(themeProvider.themeIcon),
          tooltip: 'Theme settings',
          onSelected: (ThemeMode mode) => themeProvider.setThemeMode(mode),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text('Light'),
                  if (themeProvider.themeMode == ThemeMode.light)
                    const Spacer(),
                  if (themeProvider.themeMode == ThemeMode.light)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text('Dark'),
                  if (themeProvider.themeMode == ThemeMode.dark)
                    const Spacer(),
                  if (themeProvider.themeMode == ThemeMode.dark)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_auto,
                    color: themeProvider.themeMode == ThemeMode.system
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text('System'),
                  if (themeProvider.themeMode == ThemeMode.system)
                    const Spacer(),
                  if (themeProvider.themeMode == ThemeMode.system)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ElevatedButton.icon(
          onPressed: () => themeProvider.toggleTheme(),
          icon: Icon(themeProvider.themeIcon),
          label: Text('${themeProvider.themeModeName} Theme'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }
}
