import 'package:flutter/material.dart';
import 'package:waiting_room_app/models/client.dart';

/// Carte d'un client avec son heure d'arrivée et l'action de suppression.
class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.client, this.onDelete});

  final Client client;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final time = client.createdAt.toLocal().toString().split('.').first;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(client.name),
        subtitle: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          tooltip: 'Retirer ${client.name}',
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
