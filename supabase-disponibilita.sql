-- ============================================================
--  ADTurnistica — richieste di disponibilità
--  Supabase -> SQL Editor -> New query -> incolla -> Run
-- ============================================================

-- ---------- 1. RUOLO NEI PROFILI ----------
-- 'member' = lavoratore normale, 'admin' = chi fa i turni (caposala)

alter table public.profiles
  add column if not exists role text not null default 'member';

alter table public.profiles
  drop constraint if exists ruolo_valido;
alter table public.profiles
  add constraint ruolo_valido check (role in ('member','admin'));


-- ---------- 2. FUNZIONE: sono admin? ----------
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(
    (select role = 'admin' from public.profiles where id = auth.uid()),
    false
  )
$$;


-- ---------- 3. RICHIESTE ----------
create table if not exists public.availability_requests (
  id          uuid primary key default gen_random_uuid(),
  group_code  text not null,
  from_uid    uuid not null references auth.users(id) on delete cascade,
  from_name   text,
  date        date not null,
  kind        text not null,          -- 'non_disponibile' | 'preferisco'
  reason      text not null,          -- categoria scelta da un elenco
  note        text default '',         -- dettaglio facoltativo
  status      text not null default 'pending',  -- pending | accepted | declined
  admin_note  text default '',
  created_at  timestamptz default now(),
  constraint tipo_valido  check (kind in ('non_disponibile','preferisco')),
  constraint stato_valido2 check (status in ('pending','accepted','declined'))
);

create index if not exists availability_group_date_idx
  on public.availability_requests (group_code, date);

alter table public.availability_requests enable row level security;


-- ---------- 4. REGOLE ----------

-- Vedo le mie richieste. L'admin vede quelle di tutto il suo gruppo.
drop policy if exists "disp: leggo" on public.availability_requests;
create policy "disp: leggo"
  on public.availability_requests for select
  using (
    from_uid = auth.uid()
    or (public.is_admin() and group_code = public.my_group())
  );

-- Creo richieste solo a nome mio, nel mio gruppo.
drop policy if exists "disp: creo le mie" on public.availability_requests;
create policy "disp: creo le mie"
  on public.availability_requests for insert
  with check (
    from_uid = auth.uid()
    and group_code = public.my_group()
  );

-- Solo l'admin del gruppo valuta (accetta o rifiuta).
drop policy if exists "disp: valuto da admin" on public.availability_requests;
create policy "disp: valuto da admin"
  on public.availability_requests for update
  using (public.is_admin() and group_code = public.my_group())
  with check (public.is_admin() and group_code = public.my_group());

-- Ognuno ritira le proprie.
drop policy if exists "disp: ritiro le mie" on public.availability_requests;
create policy "disp: ritiro le mie"
  on public.availability_requests for delete
  using (from_uid = auth.uid());


-- ---------- 5. TEMPO REALE ----------
alter publication supabase_realtime add table public.availability_requests;


-- ============================================================
--  COME NOMINARE LA CAPOSALA
--
--  Dopo che si e' registrata ed e' entrata nel gruppo, lancia
--  questa riga mettendo la sua email:
--
--    update public.profiles set role = 'admin'
--    where id = (select id from auth.users where email = 'SUA-EMAIL@esempio.it');
--
--  Per toglierle il ruolo, stessa riga con 'member'.
-- ============================================================


-- ============================================================
--  NOTA SULLA PRIVACY
--
--  Il campo "reason" e' una categoria generica scelta da un
--  elenco: non contiene diagnosi ne' dettagli sanitari.
--  Il campo "note" e' facoltativo e lo scrive il lavoratore
--  solo se vuole. Lo vede unicamente l'admin del suo gruppo.
-- ============================================================
