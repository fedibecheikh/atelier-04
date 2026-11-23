import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:waiting_room_app/models/client.dart';
import 'package:waiting_room_app/queue_repository.dart';

/// État de la file d'attente pour l'interface.
class QueueProvider extends ChangeNotifier {
  QueueProvider({required QueueRepository repository, this.isDemo = false})
      : _repository = repository {
    _subscribe();
  }

  final QueueRepository _repository;
  final bool isDemo;

  StreamSubscription<List<Client>>? _subscription;
  List<Client> _clients = const [];
  bool _isLoading = true;
  String? _error;

  List<Client> get clients => List<Client>.unmodifiable(_clients);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _subscribe() {
    _subscription = _repository.watchClients().listen(
      (clients) {
        _clients = clients;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _error = 'Impossible de charger la file d\'attente : $error';
        notifyListeners();
      },
    );
  }

  Future<void> addClient(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    try {
      await _repository.addClient(trimmed);
    } catch (error) {
      _error = 'Impossible d\'ajouter le client : $error';
      notifyListeners();
    }
  }

  Future<void> removeClient(String id) async {
    try {
      await _repository.removeClient(id);
    } catch (error) {
      _error = 'Impossible de retirer le client : $error';
      notifyListeners();
    }
  }

  Future<void> nextClient() async {
    if (_clients.isEmpty) return;
    await removeClient(_clients.first.id);
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
