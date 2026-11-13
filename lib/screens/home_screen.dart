import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_contact.dart';
import '../core/widgets/brand_mark.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSigningOut = false;

  User? get _currentUser => AppConfig.isSupabaseConfigured
      ? Supabase.instance.client.auth.currentUser
      : null;

  String get _customerName {
    final metadataName = _currentUser?.userMetadata?['full_name'];
    if (metadataName is String && metadataName.trim().isNotEmpty) {
      return metadataName.trim().split(RegExp(r'\s+')).first;
    }

    final email = _currentUser?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to sign out: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  void _showAccountSheet() {
    final email = _currentUser?.email ?? 'Your account';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandMark(compact: true),
              const SizedBox(height: 22),
              Text(
                'Hello, $_customerName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSigningOut
                      ? null
                      : () async {
                          Navigator.of(sheetContext).pop();
                          await _signOut();
                        },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openContact(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the contact app.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the contact app.')),
      );
    }
  }

  void _openPlans({String? category}) {
    final suffix = category == null ? '' : '?category=$category';
    context.go('/plans$suffix');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(compact: true),
        actions: [
          IconButton(
            tooltip: 'Account',
            onPressed: _showAccountSheet,
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 700 ? 28.0 : 18.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WelcomeHeading(name: _customerName),
                      const SizedBox(height: 18),
                      _HeroBanner(onExplore: () => _openPlans()),
                      const SizedBox(height: 28),
                      _SolutionsSection(
                        onViewAll: () => _openPlans(),
                        onResidential: () => _openPlans(category: 'residential'),
                        onCommercial: () => _openPlans(category: 'commercial'),
                      ),
                      const SizedBox(height: 28),
                      const _WhyMieraeSection(),
                      const SizedBox(height: 26),
                      const _ServiceAreasSection(),
                      const SizedBox(height: 26),
                      _ContactSection(
                        onCall: () => _openContact(
                          Uri(scheme: 'tel', path: AppContact.phoneNumber),
                        ),
                        onWhatsApp: () => _openContact(
                          Uri.https(
                            'wa.me',
                            '/${AppContact.whatsappNumber}',
                            {
                              'text': 'Hello Mierae Solar, I would like to know more about your rooftop solar solutions.',
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Mierae Solar  •  A Sankar Group company',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) _openPlans();
          if (index == 2) _showAccountSheet();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.solar_power_outlined),
            selectedIcon: Icon(Icons.solar_power_rounded),
            label: 'Solar plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeading extends StatelessWidget {
  const _WelcomeHeading({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME, ${name.toUpperCase()}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.solarGreenDark,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.15,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          'Let’s make your energy smarter.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 226),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.burgundyDark, AppColors.burgundy, Color(0xFF8E273D)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.burgundyDark.withValues(alpha: 0.17),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -54,
              top: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.09), width: 25),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 16,
              child: Opacity(
                opacity: 0.17,
                child: Icon(Icons.solar_power_rounded, size: 142, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.solarGreen.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: const Text(
                      'ROOFTOP SOLAR SOLUTIONS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 19),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 310),
                    child: Text(
                      'Make the switch\nto smarter solar.',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 27,
                            height: 1.13,
                          ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      'Explore reliable rooftop solar solutions for your home or business.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            height: 1.45,
                          ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onExplore,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.burgundy,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('Explore solar solutions'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolutionsSection extends StatelessWidget {
  const _SolutionsSection({
    required this.onViewAll,
    required this.onResidential,
    required this.onCommercial,
  });

  final VoidCallback onViewAll;
  final VoidCallback onResidential;
  final VoidCallback onCommercial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore solutions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Solar options for every kind of property.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 500;
            final residential = _SolutionCard(
              title: 'Residential solar',
              description: 'A smarter energy choice for your home.',
              icon: Icons.house_rounded,
              accent: AppColors.solarGreen,
              onTap: onResidential,
            );
            final commercial = _SolutionCard(
              title: 'Commercial solar',
              description: 'Explore solar for your business.',
              icon: Icons.apartment_rounded,
              accent: AppColors.burgundy,
              onTap: onCommercial,
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: residential),
                  const SizedBox(width: 12),
                  Expanded(child: commercial),
                ],
              );
            }
            return Column(
              children: [
                residential,
                const SizedBox(height: 12),
                commercial,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SolutionCard extends StatelessWidget {
  const _SolutionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(description, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios_rounded, size: 15, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhyMieraeSection extends StatelessWidget {
  const _WhyMieraeSection();

  @override
  Widget build(BuildContext context) {
    const benefits = [
      _BenefitItem(
        icon: Icons.support_agent_rounded,
        title: 'Guidance from start to finish',
        description: 'Support from the initial discussion through installation.',
      ),
      _BenefitItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Financing and subsidy guidance',
        description: 'Understand applicable options for your solar project.',
      ),
      _BenefitItem(
        icon: Icons.handyman_outlined,
        title: 'Installation support',
        description: 'Help with installation, activation and after-sales support.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why Mierae Solar?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < benefits.length; i++) ...[
                _BenefitRow(item: benefits[i]),
                if (i != benefits.length - 1) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitItem {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.item});

  final _BenefitItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.greenTint,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(item.icon, color: AppColors.solarGreenDark, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceAreasSection extends StatelessWidget {
  const _ServiceAreasSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service areas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 5),
        Text(
          'Currently highlighted across Andhra Pradesh and Odisha.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppContact.serviceCities
              .map(
                (city) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.greenTint,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    city,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.solarGreenDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.onCall, required this.onWhatsApp});

  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.burgundyTint,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.burgundy.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Let’s talk solar.', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            'Connect with the Mierae Solar team to learn more about your options.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text('Call us'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.burgundy,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onWhatsApp,
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.solarGreenDark,
                    side: const BorderSide(color: AppColors.solarGreen),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
