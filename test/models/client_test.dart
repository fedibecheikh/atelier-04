import 'package:flutter_test/flutter_test.dart';
import 'package:waiting_room_app/models/client.dart';

void main() {
  group('Client', () {
    test('fromMap parses a Supabase row', () {
      final client = Client.fromMap({
        'id': 'a2c9c6f1-0000-4000-8000-000000000001',
        'name': 'Alice',
        'created_at': '2026-01-01T10:00:00.000Z',
      });

      expect(client.id, 'a2c9c6f1-0000-4000-8000-000000000001');
      expect(client.name, 'Alice');
      expect(client.createdAt.toUtc(), DateTime.utc(2026, 1, 1, 10));
    });

    test('toMap serializes the business fields', () {
      final client = Client(
        id: '1',
        name: 'Bob',
        createdAt: DateTime.utc(2026, 2, 3, 4, 5, 6),
      );

      final map = client.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Bob');
      expect(map['created_at'], '2026-02-03T04:05:06.000Z');
    });
  });
}
