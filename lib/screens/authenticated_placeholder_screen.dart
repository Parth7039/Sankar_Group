import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_colors.dart';
import '../core/widgets/brand_mark.dart';
import '../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class AuthenticatedPlaceholderScreen extends ConsumerStatefulWidget {
  const AuthenticatedPlaceholderScreen({super.key});

  @override
  ConsumerState<AuthenticatedPlaceholderScreen> createState() =>
      _AuthenticatedPlaceholderScreenState();
}

class _AuthenticatedPlaceholderScreenState
    extends ConsumerState<AuthenticatedPlaceholderScreen> {
  bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) context.go('/login');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadataName = user?.userMetadata?['full_name'] as String?;
    final greetingName = (metadataName?.trim().isNotEmpty ?? false)
        ? metadataName!
        : (user?.email ?? 'Customer');

    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(compact: true),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _isLoading ? null : _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.greenTint,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: AppColors.solarGreen, size: 40),
                ),
                const SizedBox(height: 24),
                Text('You are signed in',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Welcome, $greetingName. Authentication is working. The Mierae Solar home screen will be built in Step 3.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Sign out',
                  onPressed: _signOut,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
