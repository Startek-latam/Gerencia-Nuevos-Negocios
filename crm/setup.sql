-- CRM Nuevos Negocios · Startek Argentina
-- Correr una sola vez en Supabase: SQL Editor › New query › pegar todo › Run.

-- 1. Equipo habilitado: solo estos mails pueden ver y editar el CRM.
create table if not exists public.equipo (
  email text primary key
);

insert into public.equipo (email) values
  ('MAIL_DE_LUCAS@startek.com'),
  ('MAIL_DEL_EPC@startek.com')
on conflict do nothing;

alter table public.equipo enable row level security;
-- Sin políticas: nadie la lee desde la web. Se edita solo desde el panel de Supabase.

-- 2. Prospectos: cada fila es una tarjeta con sus datos y su hoja de vida.
create table if not exists public.prospectos (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid()
);

alter table public.prospectos enable row level security;

create or replace function public.es_del_equipo() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.equipo where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

drop policy if exists "equipo lee" on public.prospectos;
drop policy if exists "equipo crea" on public.prospectos;
drop policy if exists "equipo edita" on public.prospectos;
drop policy if exists "equipo borra" on public.prospectos;

create policy "equipo lee"   on public.prospectos for select to authenticated using (public.es_del_equipo());
create policy "equipo crea"  on public.prospectos for insert to authenticated with check (public.es_del_equipo());
create policy "equipo edita" on public.prospectos for update to authenticated using (public.es_del_equipo()) with check (public.es_del_equipo());
create policy "equipo borra" on public.prospectos for delete to authenticated using (public.es_del_equipo());

-- 3. Tiempo real: que los cambios de uno se vean al instante en la pantalla del otro.
do $$ begin
  alter publication supabase_realtime add table public.prospectos;
exception when duplicate_object then null; end $$;
