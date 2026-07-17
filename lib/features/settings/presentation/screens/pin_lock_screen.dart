import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/providers/core_providers.dart';

enum PinLockMode { setup, unlock, change }

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key, required this.mode});

  final PinLockMode mode;

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  String _input = '';
  String? _firstEntry;
  String? _error;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    if (widget.mode == PinLockMode.unlock) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final settings = ref.read(settingsServiceProvider);
    if (!settings.isBiometricEnabled) return;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return;
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'برای ورود به برنامه هویت خود را تایید کنید',
      );
      if (authenticated && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      // در صورت عدم پشتیبانی دستگاه، ورود با پین کد ادامه می یابد
    }
  }

  void _onDigit(String digit) {
    if (_input.length >= 4) return;
    setState(() {
      _input += digit;
      _error = null;
    });
    if (_input.length == 4) {
      _handleComplete();
    }
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _handleComplete() async {
    final settings = ref.read(settingsServiceProvider);

    switch (widget.mode) {
      case PinLockMode.unlock:
        if (_input == settings.pinCode) {
          if (mounted) Navigator.of(context).pop(true);
        } else {
          setState(() {
            _error = 'کد پین اشتباه است';
            _input = '';
          });
        }
        break;
      case PinLockMode.setup:
      case PinLockMode.change:
        if (_firstEntry == null) {
          setState(() {
            _firstEntry = _input;
            _input = '';
          });
        } else if (_firstEntry == _input) {
          await settings.setPinCode(_input);
          await settings.setPinEnabled(true);
          if (mounted) Navigator.of(context).pop(true);
        } else {
          setState(() {
            _error = 'کد پین مطابقت ندارد، دوباره تلاش کنید';
            _firstEntry = null;
            _input = '';
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == PinLockMode.unlock
        ? 'ورود با کد پین'
        : (_firstEntry == null ? 'کد پین جدید را وارد کنید' : 'کد پین را تکرار کنید');

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _input.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    border: Border.all(color: const Color(0xFF2E7D32)),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFE53935))),
            ],
            const SizedBox(height: 32),
            _NumPad(onDigit: _onDigit, onBackspace: _onBackspace),
          ],
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  const _NumPad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 72, height: 60);
            }
            return SizedBox(
              width: 72,
              height: 60,
              child: TextButton(
                onPressed: () {
                  if (key == '⌫') {
                    onBackspace();
                  } else {
                    onDigit(key);
                  }
                },
                child: Text(key, style: const TextStyle(fontSize: 22)),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
