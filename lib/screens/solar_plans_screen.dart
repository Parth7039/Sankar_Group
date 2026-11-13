import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/solar_plan_provider.dart';
import '../widgets/solar_plan_card.dart';

class SolarPlansScreen extends ConsumerStatefulWidget {
  const SolarPlansScreen({this.initialCategory, super.key});

  final String? initialCategory;

  @override
  ConsumerState<SolarPlansScreen> createState() => _SolarPlansScreenState();
}

class _SolarPlansScreenState extends ConsumerState<SolarPlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = _normalizeCategory(widget.initialCategory);
  }

  @override
  void didUpdateWidget(covariant SolarPlansScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() {
        _selectedCategory = _normalizeCategory(widget.initialCategory);
      });
    }
  }

  String _normalizeCategory(String? category) {
    final normalized = category?.toLowerCase().trim();
    if (normalized == 'residential' || normalized == 'commercial') {
      return normalized!;
    }
    return 'all';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshPlans() async {
    ref.invalidate(solarPlansProvider);
    await ref.read(solarPlansProvider.future);
  }

  Future<void> _signOut() async {
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
    }
  }

  void _showAccountSheet() {
    final email = AppConfig.isSupabaseConfigured
        ? Supabase.instance.client.auth.currentUser?.email ?? 'Your account'
        : 'Your account';

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
              Text('Account', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              Text(email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
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

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(solarPlansProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Home',
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Solar solutions'),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find the right solar solution',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              Text(
                'Explore rooftop solar options for your home or business.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search solar solutions',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip('All', 'all'),
                    const SizedBox(width: 8),
                    _categoryChip('Residential', 'residential'),
                    const SizedBox(width: 8),
                    _categoryChip('Commercial', 'commercial'),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: plansAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => _PlansErrorState(
                    onRetry: () => ref.invalidate(solarPlansProvider),
                  ),
                  data: (allPlans) {
                    final query = _searchQuery.trim().toLowerCase();
                    final plans = allPlans.where((plan) {
                      final matchesCategory = _selectedCategory == 'all' ||
                          plan.category.toLowerCase() == _selectedCategory;
                      final matchesSearch = query.isEmpty ||
                          plan.name.toLowerCase().contains(query) ||
                          plan.description.toLowerCase().contains(query) ||
                          (plan.capacity?.toLowerCase().contains(query) ?? false);
                      return matchesCategory && matchesSearch;
                    }).toList(growable: false);

                    if (plans.isEmpty) {
                      return _PlansEmptyState(
                        hasSearch: query.isNotEmpty || _selectedCategory != 'all',
                        onClear: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedCategory = 'all';
                          });
                        },
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 650 ? 2 : 1;
                        return RefreshIndicator(
                          onRefresh: _refreshPlans,
                          child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 14),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 13,
                              mainAxisSpacing: 13,
                              mainAxisExtent: 286,
                            ),
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              final plan = plans[index];
                              return SolarPlanCard(
                                plan: plan,
                                onTap: () => context.push('/plans/${plan.id}'),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) context.go('/home');
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

  Widget _categoryChip(String label, String value) {
    final selected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedCategory = value),
      selectedColor: AppColors.greenTint,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected ? AppColors.solarGreen : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.solarGreenDark : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      showCheckmark: false,
    );
  }
}

class _PlansErrorState extends StatelessWidget {
  const _PlansErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load solar solutions',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Check your internet connection and make sure the solar_plans table has been created in Supabase.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlansEmptyState extends StatelessWidget {
  const _PlansEmptyState({required this.hasSearch, required this.onClear});

  final bool hasSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.solar_power_rounded,
              size: 44,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch ? 'No matching solutions' : 'No solar solutions available yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try another search or clear the selected filters.'
                  : 'Solar solutions will appear here once they are added by Mierae Solar.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasSearch) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onClear, child: const Text('Clear filters')),
            ],
          ],
        ),
      ),
    );
  }
}
