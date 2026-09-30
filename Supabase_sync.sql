-- ============================================================
--  ADTurnistica — sincronizzazione dati tra dispositivi
--  Supabase -> SQL Editor -> New query -> incolla -> Run
-- ============================================================

-- Una riga per ogni "pezzo" di dati dell'utente (un mese, le
-- impostazioni di una struttura, i reparti...). Il contenuto
-- resta lo stesso JSON che l'app gia' salva sul telefono.

create table if not exists public.user_data (
  user_id    uuid not null references auth.users(id) on delete cascade,
  key        text not null,
  value      jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

alter table public.user_data enable row level security;

-- Ognuno vede e tocca SOLO i propri dati. Nessun collega,
-- nemmeno dello stesso gruppo, puo' leggere i turni altrui.
drop policy if exists "dati: leggo i miei" on public.user_data;
create policy "dati: leggo i miei"
  on public.user_data for select
  using (auth.uid() = user_id);

drop policy if exists "dati: scrivo i miei" on public.user_data;
create policy "dati: scrivo i miei"
  on public.user_data for insert
  with check (auth.uid() = user_id);

drop policy if exists "dati: aggiorno i miei" on public.user_data;
create policy "dati: aggiorno i miei"
  on public.user_data for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "dati: cancello i miei" on public.user_data;
create policy "dati: cancello i miei"
  on public.user_data for delete
  using (auth.uid() = user_id);
