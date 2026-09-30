-- ============================================================
--  ADTurnistica — schema del database su Supabase
--  Da incollare in: Supabase -> il tuo progetto -> SQL Editor
--  -> New query -> incolla tutto -> Run
-- ============================================================


-- ---------- 1. PROFILI ----------
-- Una riga per utente. Serve a sapere in che gruppo sta,
-- informazione su cui si basano tutte le regole di sicurezza.

create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  group_code   text,
  updated_at   timestamptz default now()
);

alter table public.profiles enable row level security;

-- Ognuno vede e modifica solo il proprio profilo.
drop policy if exists "profilo: leggo il mio" on public.profiles;
create policy "profilo: leggo il mio"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profilo: creo il mio" on public.profiles;
create policy "profilo: creo il mio"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "profilo: aggiorno il mio" on public.profiles;
create policy "profilo: aggiorno il mio"
  on public.profiles for update
  using (auth.uid() = id);


-- ---------- 2. FUNZIONE DI APPOGGIO ----------
-- Restituisce il gruppo dell'utente collegato.
-- security definer le permette di leggere profiles ignorando RLS,
-- altrimenti le regole si morderebbero la coda.

create or replace function public.my_group()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select group_code from public.profiles where id = auth.uid()
$$;


-- ---------- 3. RICHIESTE DI SCAMBIO ----------

create table if not exists public.swap_requests (
  id            uuid primary key default gen_random_uuid(),
  group_code    text not null,
  from_uid      uuid not null references auth.users(id) on delete cascade,
  from_name     text,
  date          date not null,
  shift_code    text not null,
  note          text default '',
  status        text not null default 'open',
  taken_by      uuid references auth.users(id),
  taken_by_name text,
  created_at    timestamptz default now(),
  constraint stato_valido check (status in ('open','taken'))
);

create index if not exists swap_requests_group_date_idx
  on public.swap_requests (group_code, date);

alter table public.swap_requests enable row level security;

-- Leggo solo le richieste del MIO gruppo.
drop policy if exists "richieste: leggo il mio gruppo" on public.swap_requests;
create policy "richieste: leggo il mio gruppo"
  on public.swap_requests for select
  using (group_code = public.my_group());

-- Creo richieste solo a nome mio e solo nel mio gruppo.
drop policy if exists "richieste: creo le mie" on public.swap_requests;
create policy "richieste: creo le mie"
  on public.swap_requests for insert
  with check (
    from_uid = auth.uid()
    and group_code = public.my_group()
  );

-- Posso aggiornare: le mie richieste, oppure accettare quelle
-- degli altri nel mio gruppo.
drop policy if exists "richieste: accetto o modifico" on public.swap_requests;
create policy "richieste: accetto o modifico"
  on public.swap_requests for update
  using (group_code = public.my_group())
  with check (group_code = public.my_group());

-- Cancella solo chi l'ha creata.
drop policy if exists "richieste: cancello le mie" on public.swap_requests;
create policy "richieste: cancello le mie"
  on public.swap_requests for delete
  using (from_uid = auth.uid());


-- ---------- 4. AGGIORNAMENTI IN TEMPO REALE ----------
-- Fa comparire le richieste dei colleghi senza ricaricare.

alter publication supabase_realtime add table public.swap_requests;


-- ============================================================
--  NOTE
--
--  I dati di turni, guadagni e impostazioni NON stanno qui:
--  restano nel telefono di ciascuno. Online viaggiano solo
--  le richieste di scambio, che contengono giorno, turno e
--  un nome — nessuna informazione su soldi o stipendi.
--
--  Il codice del gruppo e' una parola condivisa tra colleghi:
--  chi lo conosce entra. Per un gruppo ristretto va bene, ma
--  sceglietene uno non banale (evitate "reparto" o "gruppo1").
-- ============================================================
