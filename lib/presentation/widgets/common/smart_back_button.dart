// File location: lib/presentation/widgets/common/smart_back_button.dart
// Purpose: Smart back button widget with intelligent navigation behavior
// Author: Pown Kumar - Founder of Korelium
// Date: September 18, 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/navigation_controller.dart';

/// Smart back button that intelligently navigates based on current context
class SmartBackButton extends StatelessWidget {
  final bool showText;
  final bool showIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isCompact;

  const SmartBackButton({
    super.key,
    this.showText = true,
    this.showIcon = true,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!NavigationUtils.shouldShowSmartBackButton(context)) {
      return const SizedBox.shrink();
    }

    final config = NavigationUtils.getSmartBackButtonConfig(context);
    
    if (isCompact) {
      return _buildCompactButton(context, config);
    } else {
      return _buildFullButton(context, config);
    }
  }

  /// Build compact back button (icon only)
  Widget _buildCompactButton(BuildContext context, SmartBackButtonConfig config) {
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        return IconButton(
          onPressed: config.onPressed,
          icon: Icon(
            config.icon,
            color: foregroundColor ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          tooltip: config.text,
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor ?? 
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
          ),
        );
      },
    );
  }

  /// Build full back button (icon + text)
  Widget _buildFullButton(BuildContext context, SmartBackButtonConfig config) {
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        return ElevatedButton.icon(
          onPressed: config.onPressed,
          icon: showIcon ? Icon(config.icon, size: 18) : const SizedBox.shrink(),
          label: showText ? Text(config.text) : const SizedBox.shrink(),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? 
                Theme.of(context).colorScheme.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            elevation: 2,
          ),
        );
      },
    );
  }
}

/// Smart back button for app bar
class SmartAppBarBackButton extends StatelessWidget {
  final bool showText;
  final Color? color;

  const SmartAppBarBackButton({
    super.key,
    this.showText = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!NavigationUtils.shouldShowSmartBackButton(context)) {
      return const SizedBox.shrink();
    }

    final config = NavigationUtils.getSmartBackButtonConfig(context);
    
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        return IconButton(
          onPressed: config.onPressed,
          icon: Icon(
            config.icon,
            color: color ?? Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          tooltip: config.text,
        );
      },
    );
  }
}

/// Smart floating action button that shows back to home when appropriate
class SmartFloatingActionButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SmartFloatingActionButton({
    super.key,
    this.child,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        // If we're not in home overview, show back to home button
        if (navController.currentContext != NavigationContext.homeOverview) {
          final config = NavigationUtils.getSmartBackButtonConfig(context);
          return FloatingActionButton(
            onPressed: config.onPressed,
            tooltip: config.text,
            backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            child: Icon(config.icon),
          );
        }
        
        // Otherwise show the normal FAB
        return FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          child: this.child,
        );
      },
    );
  }
}

/// Smart navigation breadcrumb widget
class SmartNavigationBreadcrumb extends StatelessWidget {
  final bool showHomeIcon;
  final TextStyle? textStyle;
  final Color? iconColor;
  final Color? separatorColor;

  const SmartNavigationBreadcrumb({
    super.key,
    this.showHomeIcon = true,
    this.textStyle,
    this.iconColor,
    this.separatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        final navContext = navController.currentContext;
        final breadcrumbs = _getBreadcrumbs(navContext);
        
        if (breadcrumbs.length <= 1) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: breadcrumbs.asMap().entries.map((entry) {
            final index = entry.key;
            final breadcrumb = entry.value;
            final isLast = index == breadcrumbs.length - 1;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0) ...[
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: separatorColor ?? 
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                ],
                GestureDetector(
                  onTap: isLast ? null : breadcrumb.onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (breadcrumb.icon != null) ...[
                        Icon(
                          breadcrumb.icon,
                          size: 16,
                          color: iconColor ?? 
                              (isLast 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        breadcrumb.text,
                        style: textStyle ?? TextStyle(
                          fontSize: 12,
                          color: isLast 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  List<BreadcrumbItem> _getBreadcrumbs(NavigationContext navContext) {
    final breadcrumbs = <BreadcrumbItem>[];
    
    // Always start with home
    breadcrumbs.add(BreadcrumbItem(
      text: 'Home',
      icon: showHomeIcon ? Icons.home : null,
      onTap: null, // This will be handled by the widget context
    ));
    
    // Add current context
    switch (navContext) {
      case NavigationContext.homeOverview:
        // Already at home, no additional breadcrumb needed
        break;
      case NavigationContext.homeTransactions:
        breadcrumbs.add(BreadcrumbItem(
          text: 'Transactions',
          icon: Icons.receipt_long,
          onTap: null, // Current page
        ));
        break;
      case NavigationContext.homeAnalytics:
        breadcrumbs.add(BreadcrumbItem(
          text: 'Analytics',
          icon: Icons.analytics,
          onTap: null, // Current page
        ));
        break;
      case NavigationContext.accounts:
        breadcrumbs.add(BreadcrumbItem(
          text: 'Accounts',
          icon: Icons.account_balance,
          onTap: null, // Current page
        ));
        break;
      case NavigationContext.creditCards:
        breadcrumbs.add(BreadcrumbItem(
          text: 'Credit Cards',
          icon: Icons.credit_card,
          onTap: null, // Current page
        ));
        break;
      case NavigationContext.loans:
        breadcrumbs.add(BreadcrumbItem(
          text: 'Loans',
          icon: Icons.account_balance_wallet,
          onTap: null, // Current page
        ));
        break;
      case NavigationContext.analytics:
        breadcrumbs.add(BreadcrumbItem(
          text: 'Analytics',
          icon: Icons.analytics,
          onTap: null, // Current page
        ));
        break;
      case NavigationContext.more:
        breadcrumbs.add(BreadcrumbItem(
          text: 'More',
          icon: Icons.more_horiz,
          onTap: null, // Current page
        ));
        break;
    }
    
    return breadcrumbs;
  }
}

/// Breadcrumb item model
class BreadcrumbItem {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;

  BreadcrumbItem({
    required this.text,
    this.icon,
    this.onTap,
  });
}
