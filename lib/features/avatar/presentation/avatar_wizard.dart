import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/widgets/editorial_widgets.dart';
import '../domain/avatar_service.dart';

class AvatarWizard extends StatefulWidget {
  const AvatarWizard({super.key, this.initialStep = 0});
  final int initialStep;
  @override
  State<AvatarWizard> createState() => _AvatarWizardState();
}

class _AvatarWizardState extends State<AvatarWizard> {
  late int step = widget.initialStep;
  bool consent = false;
  bool metric = true;
  bool frontUploaded = false;
  bool sideUploaded = false;
  bool processing = false;
  double progress = 0;
  final measurements = <String, double>{'Height': 170};

  static const labels = [
    'INTRO',
    'PRIVACY',
    'HEIGHT',
    'FRONT PHOTO',
    'SIDE PHOTO',
    'MEASURE',
    'REVIEW',
    'PROCESS',
    'ADJUST',
    'SAVE',
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      children: [
        Container(
          color: AppColors.ink,
          padding: context.pagePadding.copyWith(top: 16, bottom: 16),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: const Text(
                  'st.luvella',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'PRIVATE FIT PROFILE  ${step + 1}/10',
                style: const TextStyle(
                  color: AppColors.border,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 15),
              IconButton(
                onPressed: () => context.go('/profile'),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: (step + 1) / 10,
          minHeight: 3,
          backgroundColor: AppColors.border,
          color: AppColors.accent,
        ),
        Padding(
          padding: context.pagePadding.copyWith(top: 44, bottom: 64),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (context.width >= 1050) ...[
                SizedBox(width: 190, child: _ProgressRail(current: step)),
                const SizedBox(width: 60),
              ],
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Eyebrow('Step ${step + 1} / ${labels[step]}'),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey(step),
                          child: _content(context),
                        ),
                      ),
                      const SizedBox(height: 42),
                      Row(
                        children: [
                          if (step > 0 && !processing)
                            OutlinedButton(
                              onPressed: () => setState(() => step--),
                              child: const Text('BACK'),
                            ),
                          const Spacer(),
                          if (step < 9 && !processing)
                            ElevatedButton(
                              onPressed: _canContinue ? _next : null,
                              child: Text(
                                step == 0
                                    ? 'BEGIN MY FIT PROFILE →'
                                    : step == 6
                                    ? 'CREATE AVATAR →'
                                    : 'CONTINUE →',
                              ),
                            )
                          else if (step == 9)
                            ElevatedButton(
                              onPressed: () => context.go('/virtual-fit'),
                              child: const Text('SAVE & START STYLING →'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  bool get _canContinue => step != 1 || consent;

  Widget _content(BuildContext context) {
    switch (step) {
      case 0:
        return _Intro();
      case 1:
        return _Privacy(
          consent: consent,
          onChanged: (v) => setState(() => consent = v),
        );
      case 2:
        return _Height(
          metric: metric,
          onUnit: (v) => setState(() => metric = v),
          onHeight: (v) => measurements['Height'] = double.tryParse(v) ?? 170,
        );
      case 3:
        return _PhotoUpload(
          side: false,
          uploaded: frontUploaded,
          onUploaded: (v) => setState(() => frontUploaded = v),
        );
      case 4:
        return _PhotoUpload(
          side: true,
          uploaded: sideUploaded,
          onUploaded: (v) => setState(() => sideUploaded = v),
        );
      case 5:
        return _Measurements(metric: metric, values: measurements);
      case 6:
        return _Review(
          consent: consent,
          measurements: measurements,
          hasFront: frontUploaded,
          hasSide: sideUploaded,
        );
      case 7:
        return _Processing(progress: progress);
      case 8:
        return const _AvatarResult();
      default:
        return const _SaveProfile();
    }
  }

  Future<void> _next() async {
    if (step != 6) {
      setState(() => step++);
      return;
    }
    setState(() {
      step = 7;
      processing = true;
      progress = .1;
    });
    final service = MockAvatarProcessingService();
    final job = await service.createJob(
      AvatarSubmission(
        measurements: measurements,
        hasFrontPhoto: frontUploaded,
        hasSidePhoto: sideUploaded,
        consent: consent,
      ),
    );
    await for (final update in service.watchJob(job.id)) {
      if (!mounted) {
        return;
      }
      setState(() => progress = update.progress);
    }
    if (mounted) {
      setState(() {
        processing = false;
        step = 8;
      });
    }
  }
}

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({required this.current});
  final int current;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(
      _AvatarWizardState.labels.length,
      (i) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: i == current ? AppColors.accent : AppColors.border,
              width: i == current ? 3 : 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            '${(i + 1).toString().padLeft(2, '0')}  ${_AvatarWizardState.labels[i]}',
            style: TextStyle(
              color: i <= current ? AppColors.ink : AppColors.muted,
              fontSize: 11,
              fontWeight: i == current ? FontWeight.w900 : FontWeight.w500,
              letterSpacing: .7,
            ),
          ),
        ),
      ),
    ),
  );
}

class _Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'A better sense\nof fit, before it arrives.',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: context.isMobile ? 46 : 70,
          height: .92,
        ),
      ),
      const SizedBox(height: 22),
      const Text(
        'Build a private measurement profile to compare sizes and style 3D-compatible pieces. This prototype prepares a secure processing workflow; final body reconstruction requires an approved specialist service.',
      ),
      const SizedBox(height: 32),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          _InfoChip(Icons.straighten, '10–15 minutes'),
          _InfoChip(Icons.lock_outline, 'Private by default'),
          _InfoChip(Icons.photo_camera_outlined, 'Photos optional'),
        ],
      ),
      const SizedBox(height: 35),
      AspectRatio(
        aspectRatio: 2.3,
        child: Image(
          image: AssetImage('assets/images/avatar_studio.png'),
          fit: BoxFit.cover,
          alignment: Alignment(0, -.2),
        ),
      ),
    ],
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
    ),
  );
}

class _Privacy extends StatelessWidget {
  const _Privacy({required this.consent, required this.onChanged});
  final bool consent;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your body data\nbelongs to you.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 20),
      const Text(
        'Measurements and photos are sensitive data. They are never included in shared outfit links, never used for advertising, and access will be restricted through verified backend functions.',
      ),
      const SizedBox(height: 28),
      ...[
        (
          'Purpose limited',
          'Used only to create and improve your private fit profile.',
        ),
        (
          'Delete anytime',
          'Request deletion of photos, measurements and avatar assets.',
        ),
        (
          'No public measurements',
          'Shared previews contain styling only—never body data.',
        ),
      ].map(
        (item) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
          ),
          title: Text(
            item.$1,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(item.$2),
        ),
      ),
      const SizedBox(height: 18),
      CheckboxListTile(
        value: consent,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.all(12),
        tileColor: AppColors.white,
        title: const Text(
          'I consent to the secure processing of my measurements and optional photos for virtual fitting.',
        ),
      ),
    ],
  );
}

class _Height extends StatelessWidget {
  const _Height({
    required this.metric,
    required this.onUnit,
    required this.onHeight,
  });
  final bool metric;
  final ValueChanged<bool> onUnit;
  final ValueChanged<String> onHeight;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Start with your height.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 12),
      const Text(
        'Stand straight without shoes. Use a wall and a flat object resting on your head.',
      ),
      const SizedBox(height: 30),
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('CM')),
          ButtonSegment(value: false, label: Text('FT / IN')),
        ],
        selected: {metric},
        onSelectionChanged: (v) => onUnit(v.first),
      ),
      const SizedBox(height: 18),
      TextField(
        keyboardType: TextInputType.number,
        onChanged: onHeight,
        decoration: InputDecoration(
          labelText: metric ? 'Height in centimetres' : 'Height in inches',
          suffixText: metric ? 'cm' : 'in',
        ),
      ),
      const SizedBox(height: 28),
      const _GuidanceCard(
        icon: Icons.straighten,
        title: 'For the best result',
        text:
            'Measure twice and enter the average. Keep the tape straight and avoid rounding up.',
      ),
    ],
  );
}

class _PhotoUpload extends StatelessWidget {
  const _PhotoUpload({
    required this.side,
    required this.uploaded,
    required this.onUploaded,
  });
  final bool side;
  final bool uploaded;
  final ValueChanged<bool> onUploaded;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${side ? 'Side' : 'Front'} full-body photo.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 12),
      const Text(
        'Optional, but useful for the future processing service. Wear close-fitting, non-reflective clothing in a well-lit space.',
      ),
      const SizedBox(height: 26),
      Container(
        height: 340,
        color: const Color(0xFFE6E0D6),
        child: uploaded
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/avatar_studio.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -.32),
                    color: Colors.black.withValues(alpha: .12),
                    colorBlendMode: BlendMode.darken,
                  ),
                  const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 52,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 18,
                    child: Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(10),
                      child: const Text('UPLOAD COMPLETE'),
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: () => onUploaded(true),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      side
                          ? Icons.rotate_90_degrees_ccw
                          : Icons.photo_camera_outlined,
                      size: 42,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'UPLOAD ${side ? 'SIDE' : 'FRONT'} PHOTO',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'JPG, PNG · up to 12 MB',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
      ),
      const SizedBox(height: 18),
      if (uploaded)
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () => onUploaded(false),
              icon: const Icon(Icons.refresh),
              label: const Text('RETAKE'),
            ),
            TextButton.icon(
              onPressed: () => onUploaded(false),
              icon: const Icon(Icons.delete_outline),
              label: const Text('DELETE'),
            ),
          ],
        ),
      const SizedBox(height: 22),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          _InfoChip(Icons.wb_sunny_outlined, 'Even front lighting'),
          _InfoChip(Icons.accessibility_new, 'Arms slightly apart'),
          _InfoChip(Icons.crop_free, 'Full body in frame'),
          _InfoChip(Icons.checkroom, 'Close-fitting clothes'),
        ],
      ),
      const SizedBox(height: 20),
      const Text(
        'Your photo remains private and will only be sent to an approved body-processing service after explicit consent.',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
    ],
  );
}

class _Measurements extends StatelessWidget {
  const _Measurements({required this.metric, required this.values});
  final bool metric;
  final Map<String, double> values;
  static const fields = [
    'Neck',
    'Shoulder width',
    'Chest / bust',
    'Underbust',
    'Waist',
    'High hip',
    'Full hip',
    'Arm length',
    'Bicep',
    'Wrist',
    'Torso length',
    'Inseam',
    'Outseam',
    'Thigh',
    'Knee',
    'Calf',
    'Ankle',
  ];
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Tell us your\nproportions.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 12),
      const Text(
        'Keep the tape level and close to the body without pulling tight. Add what you know—you can update this later.',
      ),
      const SizedBox(height: 30),
      const _GuidanceCard(
        icon: Icons.info_outline,
        title: 'How to measure',
        text:
            'Tap any field’s help icon for its landmark. Use a soft tape, light clothing and a mirror.',
      ),
      const SizedBox(height: 22),
      LayoutBuilder(
        builder: (_, box) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (label) => SizedBox(
                  width: context.isMobile
                      ? box.maxWidth
                      : (box.maxWidth - 12) / 2,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) => values[label] = double.tryParse(v) ?? 0,
                    decoration: InputDecoration(
                      labelText: label,
                      suffixText: metric ? 'cm' : 'in',
                      suffixIcon: const Tooltip(
                        message:
                            'Measure around the indicated landmark with the tape level.',
                        child: Icon(Icons.help_outline, size: 18),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(text, style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Review extends StatelessWidget {
  const _Review({
    required this.consent,
    required this.measurements,
    required this.hasFront,
    required this.hasSide,
  });
  final bool consent;
  final Map<String, double> measurements;
  final bool hasFront;
  final bool hasSide;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Review your profile.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 12),
      const Text('Check what will be submitted to the mock processing queue.'),
      const SizedBox(height: 28),
      ...[
        ('Consent', consent ? 'Granted' : 'Missing'),
        ('Height', '${measurements['Height'] ?? 170} cm'),
        ('Front photo', hasFront ? 'Ready' : 'Skipped'),
        ('Side photo', hasSide ? 'Ready' : 'Skipped'),
        ('Measurements', '${measurements.length - 1} added'),
      ].map(
        (row) => Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  row.$1,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              Text(row.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      const _GuidanceCard(
        icon: Icons.cloud_outlined,
        title: 'Mock processing mode',
        text:
            'No photo or body data leaves this application. A service interface is ready for a vetted commercial or proprietary provider.',
      ),
    ],
  );
}

class _Processing extends StatelessWidget {
  const _Processing({required this.progress});
  final double progress;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 480,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            color: AppColors.accent,
            backgroundColor: AppColors.border,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Shaping your private avatar…',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          '${(progress * 100).round()}% · validating proportions and preparing garment rig',
          style: const TextStyle(color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _AvatarResult extends StatelessWidget {
  const _AvatarResult();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your digital fit\nis ready.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 20),
      AspectRatio(
        aspectRatio: context.isMobile ? .74 : 1.5,
        child: Row(
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/avatar_studio.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -.2),
              ),
            ),
            if (!context.isMobile)
              Expanded(
                child: Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow('Fine adjustments'),
                      SizedBox(height: 22),
                      Text(
                        'Shape',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Slider(value: .52, onChanged: null),
                      Text(
                        'Shoulder',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Slider(value: .47, onChanged: null),
                      Text(
                        'Stance',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Slider(value: .5, onChanged: null),
                      Spacer(),
                      Text(
                        'Adjustments preserve your core measurements.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'This is a visual prototype result, not a claim of body-scan accuracy. Final quality depends on the connected processing and garment-simulation services.',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
    ],
  );
}

class _SaveProfile extends StatelessWidget {
  const _SaveProfile();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 480,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          color: AppColors.success,
          size: 58,
        ),
        const SizedBox(height: 22),
        Text(
          'Keep your fit private.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'Name this profile and choose when it can be used.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 26),
        const SizedBox(
          width: 420,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Profile name',
              hintText: 'My everyday fit',
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          width: 420,
          child: CheckboxListTile(
            value: true,
            onChanged: null,
            title: Text('Use this profile for size recommendations'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ],
    ),
  );
}
