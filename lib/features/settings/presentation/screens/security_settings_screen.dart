import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/providers/core_providers.dart';
import 'pin_lock_screen.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() => _biometricAvailable = canCheck && isSupported);
      }
    } catch (_) {
      if (mounted) setState(() => _biometricAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('امنیت')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('قفل با کد پین'),
            subtitle: const Text('برای باز کردن برنامه کد پین وارد کنید'),
            value: settings.isPinEnabled,
            onChanged: (value) async {
              if (value) {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) =>
                        const PinLockScreen(mode: PinLockMode.setup),
                  ),
                );
                if (result == true) setState(() {});
              } else {
                await settings.setPinEnabled(false);
                await settings.setPinCode(null);
                await settings.setBiometricEnabled(false);
                setState(() {});
              }
            },
          ),
          if (settings.isPinEnabled) ...[
            ListTile(
              title: const Text('تغییر کد پین'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () async {
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) =>
                        const PinLockScreen(mode: PinLockMode.change),
                  ),
                );
              },
            ),
            if (_biometricAvailable)
              SwitchListTile(
                title: const Text('ورود با اثر انگشت'),
                subtitle: const Text('استفاده از احراز هویت بیومتریک دستگاه'),
                value: settings.isBiometricEnabled,
                onChanged: (value) async {
                  await settings.setBiometricEnabled(value);
                  setState(() {});
                },
              ),
          ],
        ],
      ),
    );
  }
}
