import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:waiting_room_app/models/client.dart';
import 'package:waiting_room_app/queue_provider.dart';
import 'package:waiting_room_app/queue_repository.dart';

class FakeQueueRepository implements QueueRepository {
  FakeQueueRepository({List<Client> initial = const []})
      : _clients = List<Client>.of(initial);

  final List<Client> _clients;
  final StreamController<List<Client>> _updates =
      StreamController<List<Client>>.broadcast();

  int addCalls = 0;
  int removeCalls = 0;
  bool shouldFail = false;

  @override
  Stream<List<Client>> watchClients() async* {
    yield List<Client>.unmodifiable(_clients);
    yield* _updates.stream;
  }

  @override
  Future<void> addClient(String name) async {
    if (shouldFail) throw StateError('network down');
    addCalls++;
    _clients.add(
      Client(
        id: 'fake-$addCalls',
        name: name,
        createdAt: DateTime.utc(2026, 1, 1, 0, addCalls),
      ),
    );
    _emit();
  }

  @override
  Future<void> removeClient(String id) async {
    if (shouldFail) throw StateError('network down');
    removeCalls++;
    _clients.removeWhere((client) => client.id == id);
    _emit();
  }

  void _emit() {
    if (_updates.isClosed) return;
    _updates.add(List<Client>.unmodifiable(_clients));
  }

  Future<void> close() => _updates.close();
}

void main() {
  test('charge la liste initiale', () async {
    final repository = FakeQueueRepository(
      initial: [
        Client(id: '1', name: 'Alice', createdAt: DateTime.utc(2026)),
      ],
    );
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await pumpEventQueue();

    expect(provider.isLoading, isFalse);
    expect(provider.clients.single.name, 'Alice');
  });

  test('ajoute un client via le repository', () async {
    final repository = FakeQueueRepository();
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await pumpEventQueue();
    await provider.addClient('  Alice  ');
    await pumpEventQueue();

    expect(repository.addCalls, 1);
    expect(provider.clients.single.name, 'Alice');
  });

  test('ignore un nom vide', () async {
    final repository = FakeQueueRepository();
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await pumpEventQueue();
    await provider.addClient('   ');

    expect(repository.addCalls, 0);
  });

  test('nextClient retire le premier client', () async {
    final repository = FakeQueueRepository(
      initial: [
        Client(id: '1', name: 'Alice', createdAt: DateTime.utc(2026, 1, 1)),
        Client(id: '2', name: 'Bob', createdAt: DateTime.utc(2026, 1, 2)),
      ],
    );
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await pumpEventQueue();
    await provider.nextClient();
    await pumpEventQueue();

    expect(repository.removeCalls, 1);
    expect(provider.clients.single.name, 'Bob');
  });

  test('expose une erreur quand le repository échoue', () async {
    final repository = FakeQueueRepository()..shouldFail = true;
    final provider = QueueProvider(repository: repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    await pumpEventQueue();
    await provider.addClient('Alice');

    expect(provider.error, isNotNull);
  });
}
