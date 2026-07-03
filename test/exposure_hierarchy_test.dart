import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/models/models.dart';

void main() {
  group('ExposureHierarchy', () {
    test('toMap/fromMap round-trips', () {
      final now = DateTime.parse('2026-06-29T10:00:00.000');
      final h = ExposureHierarchy(
        id: 7,
        title: 'Door handles',
        theme: 'Contamination',
        archived: true,
        createdAt: now,
        updatedAt: now,
      );
      final restored = ExposureHierarchy.fromMap(h.toMap());
      expect(restored.id, 7);
      expect(restored.title, 'Door handles');
      expect(restored.theme, 'Contamination');
      expect(restored.archived, true);
      expect(restored.createdAt, now);
      expect(restored.updatedAt, now);
    });

    test('toMap omits id when null', () {
      final h = ExposureHierarchy(
        title: 't',
        theme: 'x',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(h.toMap().containsKey('id'), false);
    });
  });

  group('ExposureStep', () {
    test('toMap/fromMap round-trips including status and completedAt', () {
      final completed = DateTime.parse('2026-06-29T11:30:00.000');
      final step = ExposureStep(
        id: 3,
        hierarchyId: 7,
        orderIndex: 2,
        description: 'Touch the handle once',
        difficulty: 4,
        anxietyRating: 8,
        status: ExposureStepStatus.completed,
        completedAt: completed,
      );
      final restored = ExposureStep.fromMap(step.toMap());
      expect(restored.id, 3);
      expect(restored.hierarchyId, 7);
      expect(restored.orderIndex, 2);
      expect(restored.description, 'Touch the handle once');
      expect(restored.difficulty, 4);
      expect(restored.anxietyRating, 8);
      expect(restored.status, ExposureStepStatus.completed);
      expect(restored.completedAt, completed);
    });

    test('fromMap handles null completedAt', () {
      final step = ExposureStep(
        orderIndex: 0,
        description: 'd',
        difficulty: 1,
        anxietyRating: 2,
      );
      final restored = ExposureStep.fromMap(step.toMap());
      expect(restored.completedAt, isNull);
      expect(restored.status, ExposureStepStatus.notStarted);
    });

    test('copyWith clearCompletedAt nulls the timestamp', () {
      final step = ExposureStep(
        orderIndex: 0,
        description: 'd',
        difficulty: 1,
        anxietyRating: 2,
        status: ExposureStepStatus.completed,
        completedAt: DateTime.now(),
      );
      final reset = step.copyWith(
        status: ExposureStepStatus.notStarted,
        clearCompletedAt: true,
      );
      expect(reset.completedAt, isNull);
      expect(reset.status, ExposureStepStatus.notStarted);
      expect(reset.description, 'd');
    });
  });

  group('ExposureMaterial', () {
    test('script round-trips with null file/url', () {
      final now = DateTime.parse('2026-06-30T09:00:00.000');
      final m = ExposureMaterial(
        id: 5,
        type: MaterialType.script,
        title: 'Imaginal script',
        text: 'Maybe the stove is on.',
        linkedStepId: 2,
        createdAt: now,
      );
      final r = ExposureMaterial.fromMap(m.toMap());
      expect(r.type, MaterialType.script);
      expect(r.title, 'Imaginal script');
      expect(r.text, 'Maybe the stove is on.');
      expect(r.url, isNull);
      expect(r.fileName, isNull);
      expect(r.linkedStepId, 2);
      expect(r.createdAt, now);
    });

    test('loop tape round-trips with a file name', () {
      final m = ExposureMaterial(
        type: MaterialType.loopTape,
        title: 'Loop',
        fileName: 'm_42.m4a',
        createdAt: DateTime.now(),
      );
      final r = ExposureMaterial.fromMap(m.toMap());
      expect(r.type, MaterialType.loopTape);
      expect(r.fileName, 'm_42.m4a');
      expect(m.toMap().containsKey('id'), false);
    });
  });
}
