abstract interface class AvatarProcessingService {
  Future<AvatarJob> createJob(AvatarSubmission submission);
  Stream<AvatarJob> watchJob(String id);
}

class AvatarSubmission {
  const AvatarSubmission({
    required this.measurements,
    required this.hasFrontPhoto,
    required this.hasSidePhoto,
    required this.consent,
  });
  final Map<String, double> measurements;
  final bool hasFrontPhoto;
  final bool hasSidePhoto;
  final bool consent;
}

class AvatarJob {
  const AvatarJob({
    required this.id,
    required this.progress,
    required this.status,
    this.assetUrl,
  });
  final String id;
  final double progress;
  final String status;
  final String? assetUrl;
}

class MockAvatarProcessingService implements AvatarProcessingService {
  @override
  Future<AvatarJob> createJob(AvatarSubmission submission) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const AvatarJob(
      id: 'mock-avatar-job',
      progress: .15,
      status: 'processing',
    );
  }

  @override
  Stream<AvatarJob> watchJob(String id) async* {
    for (final progress in [.35, .65, .88, 1.0]) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      yield AvatarJob(
        id: id,
        progress: progress,
        status: progress == 1 ? 'ready' : 'processing',
        assetUrl: progress == 1 ? 'mock://avatar.glb' : null,
      );
    }
  }
}
