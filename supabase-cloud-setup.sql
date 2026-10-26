-- MiPlata cloud state tables (run after the initial schema)
create table if not exists public.personal_app_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.personal_app_state enable row level security;
create policy "users manage own app state"
on public.personal_app_state for all to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));
grant select, insert, update, delete on public.personal_app_state to authenticated;

create table if not exists public.household_app_state (
  household_id uuid primary key references public.households(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.household_app_state enable row level security;
create policy "members manage household app state"
on public.household_app_state for all to authenticated
using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));
grant select, insert, update, delete on public.household_app_state to authenticated;
