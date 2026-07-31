import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _EditorialHero(),
          _FeaturedCollection(product: products[0]),
          _ProductRail(
            title: 'Just landed',
            eyebrow: 'New arrivals / 01',
            products: products.take(4).toList(),
          ),
          const _SplitCampaign(),
          const _VirtualFitPromo(),
          const _HowFitWorks(),
          _ProductRail(
            title: 'The pieces in motion',
            eyebrow: 'Trending / 02',
            products: products.skip(4).take(4).toList(),
            dark: true,
          ),
          const _BrandStory(),
          const _Newsletter(),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  const _EditorialHero();

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height - 105).clamp(
      540.0,
      820.0,
    );
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/editorial_hero.png',
            fit: BoxFit.cover,
            alignment: context.isMobile
                ? const Alignment(.48, 0)
                : Alignment.center,
            semanticLabel:
                'Two models wearing sculptural black and ivory tailoring',
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xB8F4F3EF),
                  Color(0x22F4F3EF),
                  Color(0x00000000),
                ],
              ),
            ),
          ),
          Padding(
            padding: context.pagePadding.copyWith(
              top: context.isMobile ? 38 : 62,
              bottom: 36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Eyebrow('Campaign 01 — New form'),
                    const Spacer(),
                    if (context.width >= 900) const Eyebrow('Lagos / 06°27′N'),
                  ],
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isMobile ? 360 : 800,
                  ),
                  child: Text(
                    'FORM\nFOLLOWS\nFEELING',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: context.isMobile
                          ? 61
                          : (context.width * .078).clamp(86, 124),
                      height: .78,
                      letterSpacing: context.isMobile ? -4 : -8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go('/new-arrivals'),
                      child: const Text('EXPLORE THE EDIT →'),
                    ),
                    if (context.width >= 1100) ...[
                      const SizedBox(width: 20),
                      Text(
                        'A study in structure, movement and ease.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!context.isMobile)
            Positioned(
              right: 15,
              bottom: 110,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'BRAND STUDY / VOL. 01',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 2.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCollection extends StatelessWidget {
  const _FeaturedCollection({required this.product});
  final dynamic product;

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.pagePadding.copyWith(
      top: context.isMobile ? 70 : 112,
      bottom: context.isMobile ? 70 : 112,
    ),
    child: context.isMobile
        ? Column(
            children: [
              _collectionCopy(context),
              const SizedBox(height: 30),
              AspectRatio(
                aspectRatio: .8,
                child: ProductArtwork(product: product),
              ),
            ],
          )
        : SizedBox(
            height: 650,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 52,
                  bottom: 0,
                  width: context.width * .38,
                  child: Container(color: AppColors.accent),
                ),
                Positioned(
                  left: context.width * .13,
                  top: 0,
                  bottom: 55,
                  width: context.width * .35,
                  child: ProductArtwork(product: product),
                ),
                Positioned(
                  right: 0,
                  top: 115,
                  width: context.width * .37,
                  child: _collectionCopy(context),
                ),
                Positioned(
                  left: 10,
                  bottom: 18,
                  child: Text(
                    '01',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 130,
                      height: .8,
                      color: AppColors.ink.withValues(alpha: .15),
                    ),
                  ),
                ),
              ],
            ),
          ),
  );

  Widget _collectionCopy(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Eyebrow('Featured collection / 01'),
      const SizedBox(height: 20),
      Text(
        'The art of\nsoft structure.',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: context.isMobile ? 46 : 68,
          height: .95,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Tailoring that holds its shape without asking you to hold yours. A concise edit for changing days.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      UnderlineLink(
        'DISCOVER THE COLLECTION ↗',
        onTap: () => context.go('/collections/soft-structure'),
      ),
    ],
  );
}

class _ProductRail extends StatelessWidget {
  const _ProductRail({
    required this.title,
    required this.eyebrow,
    required this.products,
    this.dark = false,
  });
  final String title;
  final String eyebrow;
  final List<dynamic> products;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final count = context.width >= 1100 ? 4 : (context.width >= 650 ? 2 : 1);
    return Container(
      color: dark ? AppColors.charcoal : null,
      padding: context.pagePadding.copyWith(top: 84, bottom: 100),
      child: Column(
        children: [
          SectionHeading(
            eyebrow: eyebrow,
            title: title,
            dark: dark,
            action: context.isMobile
                ? null
                : UnderlineLink(
                    'VIEW ALL',
                    light: dark,
                    onTap: () => context.go('/shop'),
                  ),
          ),
          const SizedBox(height: 38),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              crossAxisSpacing: 18,
              mainAxisSpacing: 36,
              childAspectRatio: count == 1 ? .77 : .61,
            ),
            itemBuilder: (context, index) => DefaultTextStyle.merge(
              style: TextStyle(color: dark ? Colors.white : AppColors.ink),
              child: ProductCard(product: products[index], compact: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitCampaign extends StatelessWidget {
  const _SplitCampaign();
  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/editorial_hero.png',
      fit: BoxFit.cover,
      alignment: Alignment.centerRight,
      semanticLabel: 'Campaign tailoring in a warm studio',
    );
    final copy = Container(
      color: AppColors.white,
      padding: EdgeInsets.all(context.width < 1200 ? 30 : 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Eyebrow('Campaign / In conversation'),
          const SizedBox(height: 22),
          Text(
            'Made to move\nbetween worlds.',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: context.width < 1200 ? 44 : 62,
              height: .94,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Morning into midnight. Lagos into anywhere. Clothes with enough clarity to meet every version of your day.',
          ),
          const SizedBox(height: 18),
          UnderlineLink(
            'READ THE STORY →',
            onTap: () => context.go('/collections'),
          ),
        ],
      ),
    );
    return SizedBox(
      height: context.width < 1200 ? 960 : 800,
      child: context.width < 1200
          ? Column(
              children: [
                Expanded(child: image),
                Expanded(child: copy),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 6, child: image),
                Expanded(flex: 4, child: copy),
              ],
            ),
    );
  }
}

class _VirtualFitPromo extends StatelessWidget {
  const _VirtualFitPromo();
  @override
  Widget build(BuildContext context) {
    final stage = Image.asset(
      'assets/images/avatar_studio.png',
      fit: BoxFit.cover,
      alignment: const Alignment(0, -.15),
      semanticLabel: 'Semi-realistic digital fitting avatar',
    );
    return Container(
      color: const Color(0xFFE2DDD2),
      padding: context.pagePadding.copyWith(top: 78, bottom: 78),
      child: context.width < 1200
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _copy(context),
                const SizedBox(height: 28),
                AspectRatio(aspectRatio: .76, child: stage),
              ],
            )
          : SizedBox(
              height: 650,
              child: Row(
                children: [
                  Expanded(child: _copy(context)),
                  const SizedBox(width: 70),
                  Expanded(child: stage),
                ],
              ),
            ),
    );
  }

  Widget _copy(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Eyebrow('Digital fitting / Optional'),
      const SizedBox(height: 20),
      Text(
        'Meet your\ndigital fit.',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: context.width < 1200 ? 51 : 76,
          height: .91,
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Create a private measurement-based avatar, explore proportion and layer compatible pieces before you buy. Shopping works beautifully without it, too.',
      ),
      const SizedBox(height: 28),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/avatar/create'),
            child: const Text('CREATE MY AVATAR'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/virtual-fit'),
            child: const Text('EXPLORE FITTING ROOM'),
          ),
        ],
      ),
    ],
  );
}

class _HowFitWorks extends StatelessWidget {
  const _HowFitWorks();
  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '01',
        'Measure once',
        'Add guided measurements and optional front and side photos.',
      ),
      (
        '02',
        'Build your profile',
        'A secure external body service will process your real proportions.',
      ),
      (
        '03',
        'Style with confidence',
        'Compare sizes, fit zones and complete outfits before checkout.',
      ),
    ];
    return Padding(
      padding: context.pagePadding.copyWith(top: 94, bottom: 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'How virtual fit works',
            title: 'Private by design. Useful by default.',
          ),
          const SizedBox(height: 52),
          LayoutBuilder(
            builder: (context, box) => Wrap(
              spacing: 24,
              runSpacing: 28,
              children: steps
                  .map(
                    (step) => Container(
                      width: context.isMobile
                          ? box.maxWidth
                          : (box.maxWidth - 48) / 3,
                      padding: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.ink, width: 2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.$1,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 50),
                          Text(
                            step.$2,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            step.$3,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandStory extends StatelessWidget {
  const _BrandStory();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.accent,
    padding: context.pagePadding.copyWith(top: 88, bottom: 94),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Our point of view'),
        const SizedBox(height: 28),
        Text(
          'We make fewer, better things — with a Lagos pulse and a global point of view.',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: context.isMobile ? 43 : 72,
            height: .98,
            letterSpacing: -3,
          ),
        ),
        const SizedBox(height: 26),
        UnderlineLink('OUR STORY ↗', onTap: () {}),
      ],
    ),
  );
}

class _Newsletter extends StatelessWidget {
  const _Newsletter();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: context.pagePadding.copyWith(top: 72, bottom: 76),
    child: Wrap(
      spacing: 80,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Private list'),
              const SizedBox(height: 12),
              Text(
                'Notes on clothes, culture and what comes next.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 440,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: TextField(
                  key: Key('newsletter-email'),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email address'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () {}, child: const Text('JOIN')),
            ],
          ),
        ),
      ],
    ),
  );
}
