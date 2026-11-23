-- Atelier 4 — Waiting room temps réel avec Supabase
-- À exécuter dans le SQL Editor du projet Supabase.

create extension if not exists pgcrypto;

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) > 0),
  created_at timestamptz not null default now()
);

-- Row Level Security : indispensable en production.
alter table public.clients enable row level security;

drop policy if exists "clients are readable" on public.clients;
create policy "clients are readable"
  on public.clients for select
  to anon, authenticated
  using (true);

drop policy if exists "anyone can join the queue" on public.clients;
create policy "anyone can join the queue"
  on public.clients for insert
  to anon, authenticated
  with check (true);

drop policy if exists "anyone can leave the queue" on public.clients;
create policy "anyone can leave the queue"
  on public.clients for delete
  to anon, authenticated
  using (true);

-- Realtime : diffuse les INSERT / DELETE aux clients connectés.
do $$
begin
  alter publication supabase_realtime add table public.clients;
exception
  when duplicate_object then null;
end $$;
