import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waiting_room_app/models/client.dart';

/// Abstraction de la source de données : facilite les tests et permet
/// un mode démo lorsque Supabase n'est pas configuré.
abstract class QueueRepository {
  /// Émet la liste complète, puis chaque mise à jour temps réel.
  Stream<List<Client>> watchClients();

  Future<void> addClient(String name);

  Future<void> removeClient(String id);
}

/// Implémentation Supabase : le stream `stream()` fournit les données
/// initiales puis les changements Realtime, sans code de serveur.
class SupabaseQueueRepository implements QueueRepository {
  SupabaseQueueRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<Client>> watchClients() {
    return _client
        .from('clients')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map(
          (rows) => rows
              .map(Client.fromMap)
              .toList(growable: false),
        );
  }

  @override
  Future<void> addClient(String name) async {
    await _client.from('clients').insert({'name': name.trim()});
  }

  @override
  Future<void> removeClient(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }
}

/// Mode démo : données en mémoire, aucune configuration requise.
class InMemoryQueueRepository implements QueueRepository {
  final List<Client> _clients = [];
  final StreamController<List<Client>> _updates =
      StreamController<List<Client>>.broadcast();
  int _sequence = 0;

  @override
  Stream<List<Client>> watchClients() async* {
    yield List<Client>.unmodifiable(_clients);
    yield* _updates.stream;
  }

  @override
  Future<void> addClient(String name) async {
    _sequence++;
    _clients.add(
      Client(
        id: 'local-$_sequence',
        name: name.trim(),
        createdAt: DateTime.now(),
      ),
    );
    _emit();
  }

  @override
  Future<void> removeClient(String id) async {
    _clients.removeWhere((client) => client.id == id);
    _emit();
  }

  void _emit() {
    if (_updates.isClosed) return;
    _clients.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _updates.add(List<Client>.unmodifiable(_clients));
  }

  Future<void> close() => _updates.close();
}
