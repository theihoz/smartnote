alter table public.notes
  add column if not exists deleted_at timestamptz,
  add column if not exists is_locked boolean not null default false;

create index if not exists notes_user_deleted_at_idx
  on public.notes (user_id, deleted_at);

create table if not exists public.note_reminders (
  note_id text primary key references public.notes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  scheduled_at timestamptz not null,
  timezone text not null default 'Asia/Ho_Chi_Minh',
  repeat_type text not null default 'none'
    check (repeat_type in ('none', 'daily', 'weekly', 'monthly', 'custom')),
  repeat_interval integer not null default 1
    check (repeat_interval between 1 and 365),
  weekdays smallint[] not null default '{}'
    check (weekdays <@ array[1,2,3,4,5,6,7]::smallint[]),
  ends_at timestamptz,
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or ends_at >= scheduled_at)
);

create index if not exists note_reminders_user_schedule_idx
  on public.note_reminders (user_id, enabled, scheduled_at);

alter table public.note_reminders enable row level security;
grant select, insert, update, delete on public.note_reminders to authenticated;

create policy "Users can view own reminders"
  on public.note_reminders for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Users can insert own reminders"
  on public.note_reminders for insert to authenticated
  with check ((select auth.uid()) = user_id and exists (
    select 1 from public.notes n
    where n.id = note_id and n.user_id = (select auth.uid())
  ));
create policy "Users can update own reminders"
  on public.note_reminders for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id and exists (
    select 1 from public.notes n
    where n.id = note_id and n.user_id = (select auth.uid())
  ));
create policy "Users can delete own reminders"
  on public.note_reminders for delete to authenticated
  using ((select auth.uid()) = user_id);

create table if not exists public.note_versions (
  id uuid primary key default gen_random_uuid(),
  note_id text not null references public.notes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  snapshot jsonb not null,
  created_at timestamptz not null default now()
);

create index if not exists note_versions_note_created_idx
  on public.note_versions (note_id, created_at desc);
create index if not exists note_versions_user_created_idx
  on public.note_versions (user_id, created_at desc);

alter table public.note_versions enable row level security;
grant select, insert, delete on public.note_versions to authenticated;
revoke update on public.note_versions from authenticated;

create policy "Users can view own note versions"
  on public.note_versions for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Users can insert own note versions"
  on public.note_versions for insert to authenticated
  with check ((select auth.uid()) = user_id and exists (
    select 1 from public.notes n
    where n.id = note_id and n.user_id = (select auth.uid())
  ));
create policy "Users can delete own note versions"
  on public.note_versions for delete to authenticated
  using ((select auth.uid()) = user_id);

