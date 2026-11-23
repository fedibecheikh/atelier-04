# Atelier 4 — Waiting Room temps réel avec Supabase

## Réalisation

Transformation de l'application locale en système distribué temps réel :

- `lib/models/client.dart` : modèle typé (`id`, `name`, `createdAt`) + sérialisation.
- `lib/queue_repository.dart` : abstraction `QueueRepository`, implémentation
  Supabase (`stream()` pour le temps réel) et implémentation en mémoire pour le mode démo.
- `lib/queue_provider.dart` : `ChangeNotifier` qui expose la file, le chargement et les erreurs.
- `lib/screens/queue_screen.dart` : ajout, suppression, « Next Client », compteur et états vides.
- `lib/widgets/client_card.dart` : carte client réutilisable.
- `lib/config/env.dart` + `lib/config/supabase_bootstrap.dart` : configuration via `--dart-define`,
  initialisation résiliente (mode démo si Supabase n'est pas configuré).

Le provider utilise `SupabaseQueueRepository.watchClients()`, qui s'appuie sur
`supabase.from('clients').stream(primaryKey: ['id'])` : les données initiales **et**
les événements Realtime arrivent par le même stream.

## Base de données

Exécuter [`supabase/schema.sql`](./supabase/schema.sql) dans le SQL Editor :

- table `clients` (`id uuid`, `name text`, `created_at timestamptz`) ;
- RLS activée avec politiques `select` / `insert` / `delete` pour `anon` ;
- ajout de la table à la publication `supabase_realtime`.

## Configuration et lancement

```bash
flutter pub get
flutter create . --project-name waiting_room_app --platforms=android,ios,web
flutter run \
  --dart-define=SUPABASE_URL=https://votre-projet.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=votre-cle-anon
```

Sans `--dart-define`, l'application démarre en **mode démo** (stockage en mémoire).

## Démonstration temps réel

1. Lancer l'application sur deux émulateurs (ou deux onglets Chrome).
2. Ajouter « John » sur l'appareil A.
3. « John » apparaît immédiatement sur l'appareil B.
4. Appuyer sur « Next Client » sur B : « John » disparaît des deux appareils.

## Tests

```bash
flutter test
```

- `test/models/client_test.dart` : parsing / sérialisation.
- `test/queue_provider_test.dart` : chargement, ajout, suppression, erreurs.
- `test/widgets/queue_screen_test.dart` : interactions UI complètes.

## Livrables

- [x] Projet Supabase + table `clients` + RLS.
- [x] `supabase_flutter` intégré et initialisé proprement.
- [x] Synchronisation temps réel multi-appareils.
- [x] CRUD (ajout, suppression, client suivant).
- [x] Tests unitaires et de widgets.
