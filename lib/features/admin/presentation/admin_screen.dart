import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';

const adminSections = <(String, String, IconData)>[
  ('overview', 'Overview', Icons.dashboard_outlined),
  ('products', 'Products', Icons.checkroom_outlined),
  ('collections', 'Collections', Icons.grid_view_outlined),
  ('inventory', 'Variants & inventory', Icons.inventory_2_outlined),
  ('orders', 'Orders', Icons.receipt_long_outlined),
  ('returns', 'Returns & refunds', Icons.assignment_return_outlined),
  ('customers', 'Customers', Icons.people_outline),
  ('body-scans', 'Body-scan jobs', Icons.accessibility_new),
  ('3d-assets', 'Garment 3D assets', Icons.view_in_ar_outlined),
  ('styling', 'Styling sessions', Icons.style_outlined),
  ('promotions', 'Promotions', Icons.sell_outlined),
  ('payments', 'Payments', Icons.payments_outlined),
  ('deliveries', 'Deliveries', Icons.local_shipping_outlined),
  ('staff', 'Staff & roles', Icons.admin_panel_settings_outlined),
  ('analytics', 'Analytics', Icons.query_stats_outlined),
  ('privacy', 'Privacy requests', Icons.privacy_tip_outlined),
  ('settings', 'Settings', Icons.settings_outlined),
  ('audit-logs', 'Audit logs', Icons.history_outlined),
];

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key, this.section = 'overview'});
  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desktop = context.width >= 1000;
    final content = _AdminContent(section: section);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1EE),
      drawer: desktop
          ? null
          : Drawer(
              shape: const RoundedRectangleBorder(),
              child: _AdminNav(section: section),
            ),
      body: Row(
        children: [
          if (desktop) SizedBox(width: 255, child: _AdminNav(section: section)),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 68,
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (!desktop)
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(Icons.menu),
                          ),
                        ),
                      Text(
                        _sectionLabel(section),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Badge(
                          smallSize: 8,
                          child: Icon(Icons.notifications_none),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        backgroundColor: AppColors.accent,
                        child: Text(
                          'AO',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(String slug) => adminSections
      .firstWhere((item) => item.$1 == slug, orElse: () => adminSections.first)
      .$2;
}

class _AdminNav extends ConsumerWidget {
  const _AdminNav({required this.section});
  final String section;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    color: AppColors.ink,
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 18, 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'st.luvella\nADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                      height: 1.25,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_outward, color: Colors.white),
                  tooltip: 'View storefront',
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF343432)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
              children: adminSections.map((item) {
                final selected = section == item.$1;
                return ListTile(
                  dense: true,
                  shape: const RoundedRectangleBorder(),
                  selected: selected,
                  selectedTileColor: AppColors.accent,
                  selectedColor: AppColors.ink,
                  leading: Icon(
                    item.$3,
                    size: 19,
                    color: selected ? AppColors.ink : AppColors.border,
                  ),
                  title: Text(
                    item.$2,
                    style: TextStyle(
                      color: selected ? AppColors.ink : AppColors.border,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  onTap: () => context.go(
                    item.$1 == 'overview' ? '/admin' : '/admin/${item.$1}',
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Color(0xFF343432)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AMARA OKAFOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'SUPER ADMINISTRATOR',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut();
                    context.go('/');
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.border,
                    size: 17,
                  ),
                  label: const Text(
                    'SIGN OUT',
                    style: TextStyle(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _AdminContent extends StatelessWidget {
  const _AdminContent({required this.section});
  final String section;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(context.isMobile ? 18 : 28),
    child: section == 'overview'
        ? const _Overview()
        : _DataSection(section: section),
  );
}

class _Overview extends StatelessWidget {
  const _Overview();
  @override
  Widget build(BuildContext context) {
    const metrics = [
      ('Orders requiring action', '18', '+4 today', AppColors.warning),
      ('Low stock', '12', '5 critical', AppColors.error),
      ('Failed payments', '7', '₦486k value', AppColors.error),
      ('Delivery exceptions', '4', '2 overdue', AppColors.warning),
      ('Return requests', '9', '3 new', AppColors.warning),
      ('Body-scan failures', '3', 'Review queue', AppColors.error),
      ('3D asset blockers', '6', '2 high priority', AppColors.warning),
      ('Products without 3D', '24', '68% covered', AppColors.muted),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Amara',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Here’s what needs attention across commerce and virtual fit.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (!context.isMobile)
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('ADD PRODUCT'),
              ),
          ],
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (_, box) {
            final count = box.maxWidth >= 1100
                ? 4
                : box.maxWidth >= 650
                ? 2
                : 1;
            final width = (box.maxWidth - (count - 1) * 14) / count;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: metrics
                  .map(
                    (item) => Container(
                      width: width,
                      height: 145,
                      color: AppColors.white,
                      padding: const EdgeInsets.all(19),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: item.$4,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_outward, size: 17),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            item.$2,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            item.$1,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            item.$3,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 28),
        if (context.width >= 850)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _OrderQueue()),
              SizedBox(width: 16),
              Expanded(flex: 4, child: _ActivityPanel()),
            ],
          )
        else
          const Column(
            children: [_OrderQueue(), SizedBox(height: 16), _ActivityPanel()],
          ),
      ],
    );
  }
}

class _OrderQueue extends StatelessWidget {
  const _OrderQueue();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: const EdgeInsets.all(21),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Orders requiring action',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/admin/orders'),
              child: const Text('VIEW ALL'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ORDER')),
              DataColumn(label: Text('CUSTOMER')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('VALUE')),
              DataColumn(label: Text('ACTION')),
            ],
            rows:
                [
                      ('BN-2048', 'A. Bello', 'PAYMENT REVIEW', '₦218,000'),
                      ('BN-2045', 'N. Eze', 'PACK TODAY', '₦85,000'),
                      ('BN-2041', 'T. Akin', 'ADDRESS ISSUE', '₦162,000'),
                      ('BN-2036', 'I. Musa', 'REFUND DUE', '₦76,000'),
                    ]
                    .map(
                      (row) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              row.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          DataCell(Text(row.$2)),
                          DataCell(_Status(row.$3)),
                          DataCell(Text(row.$4)),
                          const DataCell(Icon(Icons.more_horiz)),
                        ],
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    ),
  );
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: const EdgeInsets.all(21),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
        ...[
          ('ORDER', 'BN-2048 payment verified', '2 min'),
          ('3D ASSET', 'Nuru Blazer moved to QA', '18 min'),
          ('STOCK', 'Ara Blouse / M below threshold', '41 min'),
          ('PRIVACY', 'Deletion request assigned', '1 hr'),
        ].map(
          (item) => Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFFF1F1EE),
                  padding: const EdgeInsets.all(7),
                  child: Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.$2, style: const TextStyle(fontSize: 12)),
                ),
                Text(
                  item.$3,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Status extends StatelessWidget {
  const _Status(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFFFF0DA),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: Text(
      value,
      style: const TextStyle(
        fontSize: 9,
        color: Color(0xFF865500),
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _DataSection extends StatelessWidget {
  const _DataSection({required this.section});
  final String section;
  String get label => adminSections
      .firstWhere(
        (item) => item.$1 == section,
        orElse: () => adminSections.first,
      )
      .$2;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 5),
                Text(
                  'Manage $label, review queues and take audited actions.',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: Text('ADD ${label.toUpperCase().split(' ').first}'),
          ),
        ],
      ),
      const SizedBox(height: 26),
      Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search records',
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune),
              label: const Text('FILTER'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined),
              label: const Text('EXPORT'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('REFERENCE')),
              DataColumn(label: Text('NAME / SUBJECT')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('OWNER')),
              DataColumn(label: Text('UPDATED')),
              DataColumn(label: Text('')),
            ],
            rows: List.generate(
              8,
              (i) => DataRow(
                cells: [
                  DataCell(
                    Text(
                      'REF-${2048 - i}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  DataCell(Text('$label record ${i + 1}')),
                  DataCell(_Status(i % 3 == 0 ? 'REVIEW' : 'ACTIVE')),
                  DataCell(Text(i.isEven ? 'Amara O.' : 'Team queue')),
                  DataCell(Text('${i + 1}h ago')),
                  const DataCell(Icon(Icons.more_horiz)),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      const Align(
        alignment: Alignment.centerRight,
        child: Text(
          '1–8 of 48 records',
          style: TextStyle(color: AppColors.muted),
        ),
      ),
      if (section == 'staff') ...[
        const SizedBox(height: 28),
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(22),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sample role matrix',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('Super administrator')),
                  Chip(label: Text('Catalog manager')),
                  Chip(label: Text('3D asset specialist')),
                  Chip(label: Text('Fulfilment officer')),
                  Chip(label: Text('Stylist')),
                  Chip(label: Text('Customer support')),
                  Chip(label: Text('Finance')),
                  Chip(label: Text('Privacy officer')),
                ],
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
