import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:waiting_room_app/queue_provider.dart';
import 'package:waiting_room_app/queue_repository.dart';
import 'package:waiting_room_app/screens/queue_screen.dart';

void main() {
  testWidgets('ajoute un client depuis l\'interface', (tester) async {
    final repository = InMemoryQueueRepository();
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<QueueProvider>.value(
        value: provider,
        child: const MaterialApp(home: QueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No one in queue yet...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.tap(find.byKey(const Key('add-client-button')));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Clients in Queue: 1'), findsOneWidget);
  });

  testWidgets('retire un client avec le bouton supprimer', (tester) async {
    final repository = InMemoryQueueRepository();
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<QueueProvider>.value(
        value: provider,
        child: const MaterialApp(home: QueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Bob');
    await tester.tap(find.byKey(const Key('add-client-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Bob'), findsNothing);
    expect(find.text('Clients in Queue: 0'), findsOneWidget);
  });

  testWidgets('Next Client retire le premier de la file', (tester) async {
    final repository = InMemoryQueueRepository();
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<QueueProvider>.value(
        value: provider,
        child: const MaterialApp(home: QueueScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.tap(find.byKey(const Key('add-client-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next Client'));
    await tester.pumpAndSettle();

    expect(find.text('Clients in Queue: 0'), findsOneWidget);
  });
}
