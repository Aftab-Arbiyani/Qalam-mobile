import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('enum wire values mirror @qalam/shared', () {
    test('PieceStatus', () {
      expect(PieceStatus.published.wire, 'published');
      expect(PieceStatus.fromWire('archived'), PieceStatus.archived);
    });

    test('fromWire falls back on unknown values (additive tolerance)', () {
      expect(PieceStatus.fromWire('brand_new_status'), PieceStatus.draft);
      expect(
        NotificationType.fromWire('some_future_kind'),
        NotificationType.unknown,
      );
      expect(FeedSort.fromWire(null), FeedSort.latest);
    });

    test('Role ladder ranks and satisfies()', () {
      expect(Role.admin.rank > Role.moderator.rank, isTrue);
      expect(Role.admin.satisfies(Role.moderator), isTrue);
      expect(Role.user.satisfies(Role.admin), isFalse);
      expect(Role.fromWire('super_admin'), Role.superAdmin);
    });

    test('exact wire strings for filter/sort enums', () {
      expect(FeedSort.mostClapped.wire, 'most_clapped');
      expect(SearchSort.mostCommented.wire, 'most_commented');
      expect(TextDirectionKind.rtl.wire, 'rtl');
      expect(ShareChannel.copyLink.wire, 'copy_link');
    });
  });
}
