-- MiPlata: invitaciones para vincular dos cuentas a un hogar compartido
-- Ejecuta este archivo completo en Supabase > SQL Editor.
-- No modifica ni borra los movimientos personales existentes.

create table if not exists public.household_invites (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  token_hash text not null unique,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '48 hours'),
  used_at timestamptz
);

create index if not exists household_invites_household_id_idx
  on public.household_invites(household_id);

alter table public.household_invites enable row level security;
revoke all on public.household_invites from anon, authenticated;

create or replace function public.create_household_invite()
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_household uuid;
  v_token text;
begin
  if v_user is null then
    raise exception 'Debes iniciar sesión para crear una invitación.';
  end if;

  select hm.household_id into v_household
  from public.household_members hm
  where hm.user_id = v_user
  limit 1;

  if v_household is null then
    raise exception 'Tu cuenta aún no tiene un hogar asociado. Cierra sesión e inicia nuevamente.';
  end if;

  v_token := replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', '');
  insert into public.household_invites(household_id, token_hash, created_by, expires_at)
  values (v_household, md5(v_token), v_user, now() + interval '48 hours');

  return v_token;
end;
$$;

create or replace function public.accept_household_invite(p_token text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_household uuid;
  v_other_household uuid;
begin
  if v_user is null then
    raise exception 'Debes iniciar sesión para aceptar una invitación.';
  end if;
  if coalesce(length(trim(p_token)), 0) < 20 then
    raise exception 'El código de invitación no parece válido.';
  end if;

  select i.household_id into v_household
  from public.household_invites i
  where i.token_hash = md5(trim(p_token))
    and i.used_at is null
    and i.expires_at > now()
  order by i.created_at desc
  limit 1
  for update;

  if v_household is null then
    raise exception 'El código es inválido, ya se usó o venció. Pide una nueva invitación.';
  end if;

  if exists (
    select 1 from public.household_members hm
    where hm.household_id = v_household and hm.user_id = v_user
  ) then
    update public.household_invites set used_at = now()
    where token_hash = md5(trim(p_token));
    return v_household;
  end if;

  -- Permite salir de un hogar personal vacío creado automáticamente al registrarse,
  -- pero no desvincula al usuario de otro hogar que ya tenga más integrantes.
  if exists (
    select 1
    from public.household_members mine
    where mine.user_id = v_user
      and mine.household_id <> v_household
      and exists (
        select 1 from public.household_members other_member
        where other_member.household_id = mine.household_id
          and other_member.user_id <> v_user
      )
  ) then
    raise exception 'Tu cuenta ya pertenece a un hogar con otros integrantes. Contacta al administrador antes de cambiar de hogar.';
  end if;

  delete from public.household_members mine
  where mine.user_id = v_user and mine.household_id <> v_household;

  insert into public.household_members(household_id, user_id, role)
  values (v_household, v_user, 'member')
  on conflict do nothing;

  update public.household_invites
  set used_at = now()
  where token_hash = md5(trim(p_token));

  return v_household;
end;
$$;

revoke all on function public.create_household_invite() from public, anon;
revoke all on function public.accept_household_invite(text) from public, anon;
grant execute on function public.create_household_invite() to authenticated;
grant execute on function public.accept_household_invite(text) to authenticated;
