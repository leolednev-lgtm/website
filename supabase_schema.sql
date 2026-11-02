-- XHUSXUW: one private JSON document per authenticated user.
-- Run this script in Supabase Dashboard -> SQL Editor.

create table if not exists public.user_data (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.user_data enable row level security;

-- Remove previous policies with these names so the script can be re-run.
drop policy if exists "Users can read their own XHUSXUW data" on public.user_data;
drop policy if exists "Users can insert their own XHUSXUW data" on public.user_data;
drop policy if exists "Users can update their own XHUSXUW data" on public.user_data;
drop policy if exists "Users can delete their own XHUSXUW data" on public.user_data;

create policy "Users can read their own XHUSXUW data"
  on public.user_data for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert their own XHUSXUW data"
  on public.user_data for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own XHUSXUW data"
  on public.user_data for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own XHUSXUW data"
  on public.user_data for delete to authenticated
  using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.user_data to authenticated;

-- Enable Realtime UPDATE events for cross-device refresh.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'user_data'
  ) then
    alter publication supabase_realtime add table public.user_data;
  end if;
end $$;
