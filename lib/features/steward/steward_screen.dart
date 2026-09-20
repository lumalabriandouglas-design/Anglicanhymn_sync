import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/billing_service.dart';
import '../../core/utils/open_link.dart';
import '../../core/widgets/app_nav.dart';
import '../../models/billing.dart';
import '../../providers/billing_provider.dart';

Future<void> openStewardWall(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => const _StewardPinDialog(),
  );
  if (ok == true && context.mounted) {
    await AppNav.push(context, const StewardScreen());
  }
}

class _StewardPinDialog extends StatefulWidget {
  const _StewardPinDialog();

  @override
  State<_StewardPinDialog> createState() => _StewardPinDialogState();
}

class _StewardPinDialogState extends State<_StewardPinDialog> {
  final _pin = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardNavy : Colors.white,
      title: const Text('Steward'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'PIN',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(billing),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Close')),
        ElevatedButton(
          onPressed: () => _submit(billing),
          child: const Text('Enter'),
        ),
      ],
    );
  }

  void _submit(BillingProvider billing) {
    if (billing.checkPin(_pin.text)) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = 'Wrong PIN');
    }
  }
}

class StewardScreen extends StatelessWidget {
  const StewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Steward'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pay-in'),
              Tab(text: 'Activate'),
              Tab(text: 'Plans'),
            ],
          ),
        ),
        backgroundColor: isDark ? AppColors.primaryNavy : AppColors.lightBackground,
        body: const TabBarView(
          children: [
            _PayInTab(),
            _ActivateTab(),
            _PlansTab(),
          ],
        ),
      ),
    );
  }
}

class _PayInTab extends StatefulWidget {
  const _PayInTab();

  @override
  State<_PayInTab> createState() => _PayInTabState();
}

class _PayInTabState extends State<_PayInTab> {
  final _mtn = TextEditingController();
  final _airtel = TextEditingController();
  final _whatsapp = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _mtn.dispose();
    _airtel.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  void _sync(BillingConfig config) {
    if (_filled) return;
    _filled = true;
    String mtn = '';
    String airtel = '';
    for (final n in config.numbers) {
      if (n.network.toLowerCase() == 'mtn') mtn = n.number;
      if (n.network.toLowerCase() == 'airtel') airtel = n.number;
    }
    _mtn.text = mtn;
    _airtel.text = airtel;
    _whatsapp.text = config.whatsapp;
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final config = billing.config;
    if (config == null) {
      return const Center(child: CircularProgressIndicator());
    }
    _sync(config);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        const Text(
          'People send Mobile Money to these numbers, then tap I’ve paid. You get the WhatsApp note and activate them. Nobody in the hymn book sees this while everything is free.',
          style: TextStyle(height: 1.4),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _mtn,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'MTN number',
            hintText: '0772 000 000',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _airtel,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Airtel number',
            hintText: '0702 000 000',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _whatsapp,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'WhatsApp for “I’ve paid” notes',
            hintText: '0772 000 000',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await billing.savePayIn(
              numbers: [
                PayNumber(network: 'MTN', number: _mtn.text.trim()),
                PayNumber(network: 'Airtel', number: _airtel.text.trim()),
              ],
              whatsapp: _whatsapp.text.trim(),
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pay-in numbers saved on this device')),
            );
          },
          child: const Text('Save numbers'),
        ),
        const SizedBox(height: 28),
        const Text('How a listener will pay', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        _PaymentPreview(config: config),
      ],
    );
  }
}

class _PaymentPreview extends StatefulWidget {
  final BillingConfig config;
  const _PaymentPreview({required this.config});

  @override
  State<_PaymentPreview> createState() => _PaymentPreviewState();
}

class _PaymentPreviewState extends State<_PaymentPreview> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _tx = TextEditingController();
  String _network = 'MTN';
  late String _planId;

  @override
  void initState() {
    super.initState();
    _planId = widget.config.plans.first.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _tx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final config = widget.config;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    BillingPlan plan = config.plans.first;
    for (final p in config.plans) {
      if (p.id == _planId) plan = p;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardNavy : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Mobile Money, then tell us you paid.'),
          const SizedBox(height: 12),
          for (final n in config.numbers)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.sim_card_rounded, color: AppColors.celestialGold),
              title: Text(n.network, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(n.number.isEmpty ? 'Add the number above' : n.number),
              trailing: n.number.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: n.number));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${n.network} number copied')),
                        );
                      },
                    ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final p in config.plans)
                ChoiceChip(
                  label: Text(
                    '${p.name} · ${BillingService.formatAmount(p.amount, config.currency)}',
                  ),
                  selected: _planId == p.id,
                  onSelected: (_) => setState(() => _planId = p.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Your name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Your phone', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _network,
            decoration: const InputDecoration(labelText: 'I sent with', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'MTN', child: Text('MTN')),
              DropdownMenuItem(value: 'Airtel', child: Text('Airtel')),
            ],
            onChanged: (v) => setState(() => _network = v ?? 'MTN'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tx,
            decoration: const InputDecoration(
              labelText: 'Transaction ID (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            icon: const Icon(Icons.mark_email_read_outlined),
            label: const Text('I’ve paid'),
            onPressed: () async {
              if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and phone are needed')),
                );
                return;
              }
              final claim = await billing.submitPaid(
                name: _name.text,
                phone: _phone.text,
                network: _network,
                plan: plan,
                txId: _tx.text,
              );
              final message = billing.paidMessage(claim);
              await Clipboard.setData(ClipboardData(text: message));
              if (config.whatsapp.trim().isNotEmpty) {
                await openLink(
                  BillingService.whatsappLink(
                    whatsapp: config.whatsapp,
                    text: message,
                  ),
                );
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    config.whatsapp.trim().isEmpty
                        ? 'Note copied. Add a WhatsApp number so it can open automatically.'
                        : 'Note copied and WhatsApp opened. Activate it on the next tab.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivateTab extends StatefulWidget {
  const _ActivateTab();

  @override
  State<_ActivateTab> createState() => _ActivateTabState();
}

class _ActivateTabState extends State<_ActivateTab> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _newPin = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _newPin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final pending = billing.claims;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        const Text(
          'When Mobile Money arrives, tap Activate. Send the 8-digit code back to that person. They redeem it below.',
          style: TextStyle(height: 1.4),
        ),
        const SizedBox(height: 16),
        if (pending.isEmpty)
          const Text('No “I’ve paid” notes on this device yet.')
        else
          for (final claim in pending)
            Card(
              child: ListTile(
                title: Text('${claim.name} · ${claim.phone}'),
                subtitle: Text(
                  '${claim.network} · ${claim.planId} · ${claim.status}'
                  '${claim.code == null ? '' : ' · code ${claim.code}'}',
                ),
                trailing: claim.status == 'paid'
                    ? IconButton(
                        tooltip: 'Copy code',
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: claim.code ?? ''));
                        },
                      )
                    : TextButton(
                        onPressed: () async {
                          final code = await billing.markPaid(claim);
                          if (!context.mounted) return;
                          await Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Activated. Code $code copied')),
                          );
                        },
                        child: const Text('Activate'),
                      ),
              ),
            ),
        const SizedBox(height: 24),
        const Text('Redeem a code on this device', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone that paid', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _code,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '8-digit code', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final ok = await billing.redeem(phone: _phone.text, code: _code.text);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ok ? 'Plus is on for this device' : 'That code does not match')),
            );
          },
          child: const Text('Redeem'),
        ),
        if (billing.plusActive) ...[
          const SizedBox(height: 8),
          Text(
            'This device is Plus until ${billing.plusUntil}',
            style: const TextStyle(color: AppColors.celestialGold),
          ),
        ],
        const SizedBox(height: 28),
        const Text('Change steward PIN', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _newPin,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New PIN', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () async {
            if (_newPin.text.trim().length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Use at least 4 digits')),
              );
              return;
            }
            await billing.changePin(_newPin.text);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN saved on this device')),
            );
          },
          child: const Text('Save PIN'),
        ),
      ],
    );
  }
}

class _PlansTab extends StatelessWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final config = billing.config;
    if (config == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        const Text(
          'Two listening plans, like a free and a paid music app. The public book does not show this split while everything is free.',
          style: TextStyle(height: 1.4),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          title: 'Listener',
          subtitle: 'Free',
          items: config.freeListening,
        ),
        const SizedBox(height: 12),
        _PlanCard(
          title: 'Plus',
          subtitle: config.plans
              .map((p) => '${p.name} ${BillingService.formatAmount(p.amount, config.currency)}')
              .join(' · '),
          items: [...config.freeListening, ...config.plusListening],
          plus: true,
        ),
        const SizedBox(height: 20),
        Text(
          billing.allOpen
              ? 'Right now every listener gets Plus tools: speed, sleep timer, auto-scroll, shuffle, repeat, queue, Luganda/English audio.'
              : 'The wall is on. Plus tools wait for an activated code.',
          style: const TextStyle(height: 1.4),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> items;
  final bool plus;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.items,
    this.plus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardNavy : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: plus ? Border.all(color: AppColors.celestialGold.withOpacity(0.5)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: plus ? AppColors.celestialGold : null)),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 16, color: AppColors.celestialGold),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
