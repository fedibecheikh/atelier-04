import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waiting_room_app/config/supabase_bootstrap.dart';
import 'package:waiting_room_app/queue_provider.dart';
import 'package:waiting_room_app/queue_repository.dart';
import 'package:waiting_room_app/screens/queue_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseReady = await SupabaseBootstrap.initialize();

  final QueueRepository repository = supabaseReady
      ? SupabaseQueueRepository(Supabase.instance.client)
      : InMemoryQueueRepository();

  runApp(
    ChangeNotifierProvider(
      create: (_) => QueueProvider(
        repository: repository,
        isDemo: !supabaseReady,
      ),
      child: const WaitingRoomApp(),
    ),
  );
}

class WaitingRoomApp extends StatelessWidget {
  const WaitingRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waiting Room',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const QueueScreen(),
    );
  }
}
