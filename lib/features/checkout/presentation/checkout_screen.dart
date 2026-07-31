import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';
import '../../cart/presentation/cart_screen.dart';

enum CheckoutState { form, processing, verifying, success, failure }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  CheckoutState state = CheckoutState.form;
  String delivery = 'Standard';
  String selectedState = 'Lagos';

  @override
  Widget build(BuildContext context) {
    if (state != CheckoutState.form) {
      return _PaymentState(
        state: state,
        onRetry: () => setState(() => state = CheckoutState.form),
        onVerify: () => _verify(),
      );
    }
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: AppColors.ink,
            padding: context.pagePadding.copyWith(top: 24, bottom: 24),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/'),
                  child: const Text(
                    'st.luvella',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'SECURE CHECKOUT',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: context.pagePadding.copyWith(top: 52, bottom: 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checkout',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nigeria-first delivery · NGN payments',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 42),
                if (context.width >= 920)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _form(context, subtotal)),
                      const SizedBox(width: 60),
                      Expanded(
                        flex: 4,
                        child: _summary(context, cart, subtotal),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _form(context, subtotal),
                      const SizedBox(height: 42),
                      _summary(context, cart, subtotal),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(BuildContext context, int subtotal) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _stepTitle(context, '01', 'Contact'),
      const SizedBox(height: 18),
      const TextField(decoration: InputDecoration(labelText: 'Email address')),
      const SizedBox(height: 38),
      _stepTitle(context, '02', 'Delivery address'),
      const SizedBox(height: 18),
      const Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: 'First name'),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: 'Last name'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'Street address')),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: selectedState,
              decoration: const InputDecoration(labelText: 'State'),
              items: [
                'Lagos',
                'Abuja FCT',
                'Oyo',
                'Rivers',
                'Enugu',
                'Kano',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => selectedState = v!),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(decoration: InputDecoration(labelText: 'City')),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const TextField(
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Phone number',
          prefixText: '+234 ',
        ),
      ),
      const SizedBox(height: 38),
      _stepTitle(context, '03', 'Delivery method'),
      const SizedBox(height: 14),
      ...[
        (
          'Standard',
          '2–4 working days',
          subtotal >= 150000 ? 'COMPLIMENTARY' : '₦4,500',
        ),
        ('Express', 'Next working day in Lagos', '₦8,500'),
      ].map(
        (option) => InkWell(
          onTap: () => setState(() => delivery = option.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(
                  delivery == option.$1
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: delivery == option.$1
                      ? AppColors.ink
                      : AppColors.muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        option.$2,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Text(option.$3),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 34),
      _stepTitle(context, '04', 'Payment'),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.ink, width: 2),
          color: AppColors.white,
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_user_outlined),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paystack',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Card, bank transfer or USSD',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: AppColors.success),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Payment is confirmed only after secure backend verification. A browser redirect is never treated as proof of payment.',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
    ],
  );

  Widget _summary(BuildContext context, List<CartLine> cart, int subtotal) {
    final deliveryFee = delivery == 'Express'
        ? 8500
        : (subtotal >= 150000 ? 0 : 4500);
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your order', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 22),
          ...cart.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 62,
                    height: 78,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ProductArtwork(product: line.product),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.ink,
                            foregroundColor: Colors.white,
                            child: Text(
                              '${line.quantity}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(line.product.name)),
                  Text(formatNaira(line.product.price * line.quantity)),
                ],
              ),
            ),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Promotion code',
              suffixIcon: Icon(Icons.arrow_forward),
            ),
          ),
          const SizedBox(height: 22),
          _CheckoutLine('Subtotal', formatNaira(subtotal)),
          const SizedBox(height: 10),
          _CheckoutLine(
            'Delivery',
            deliveryFee == 0 ? 'Complimentary' : formatNaira(deliveryFee),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 18),
          _CheckoutLine(
            'Total',
            formatNaira(subtotal + deliveryFee),
            bold: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: cart.isEmpty ? null : _pay,
            child: Text('PAY ${formatNaira(subtotal + deliveryFee)}'),
          ),
        ],
      ),
    );
  }

  Widget _stepTitle(BuildContext context, String number, String title) => Row(
    children: [
      Text(
        number,
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(width: 14),
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
    ],
  );
  Future<void> _pay() async {
    setState(() => state = CheckoutState.processing);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) setState(() => state = CheckoutState.verifying);
  }

  Future<void> _verify() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) {
      ref.read(cartProvider.notifier).clear();
      setState(() => state = CheckoutState.success);
    }
  }
}

class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w400),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
          fontSize: bold ? 18 : 14,
        ),
      ),
    ],
  );
}

class _PaymentState extends StatelessWidget {
  const _PaymentState({
    required this.state,
    required this.onRetry,
    required this.onVerify,
  });
  final CheckoutState state;
  final VoidCallback onRetry;
  final VoidCallback onVerify;
  @override
  Widget build(BuildContext context) {
    final success = state == CheckoutState.success;
    final failure = state == CheckoutState.failure;
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state == CheckoutState.processing ||
                  state == CheckoutState.verifying)
                const CircularProgressIndicator(color: AppColors.accent)
              else
                Icon(
                  success ? Icons.check_circle_outline : Icons.error_outline,
                  color: success ? AppColors.success : AppColors.error,
                  size: 58,
                ),
              const SizedBox(height: 24),
              Text(
                state == CheckoutState.processing
                    ? 'Opening secure payment…'
                    : state == CheckoutState.verifying
                    ? 'Verify your payment'
                    : success
                    ? 'Order confirmed.'
                    : 'Payment needs attention',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                state == CheckoutState.verifying
                    ? 'The payment window has returned. Confirm with our backend to finish the order.'
                    : success
                    ? 'Thank you. Order BN-2048 is now being prepared.'
                    : state == CheckoutState.processing
                    ? 'Please keep this window open.'
                    : 'No charge was confirmed. You can safely try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 26),
              if (state == CheckoutState.verifying)
                ElevatedButton(
                  onPressed: onVerify,
                  child: const Text('VERIFY PAYMENT'),
                )
              else if (success)
                ElevatedButton(
                  onPressed: () => context.go('/orders/BN-2048'),
                  child: const Text('TRACK ORDER'),
                )
              else if (failure)
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('TRY AGAIN'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
