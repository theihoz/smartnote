drop policy if exists "users read their own notes" on public.notes;
create policy "users read their own notes"
  on public.notes for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "users insert their own notes" on public.notes;
create policy "users insert their own notes"
  on public.notes for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "users update their own notes" on public.notes;
create policy "users update their own notes"
  on public.notes for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "users delete their own notes" on public.notes;
create policy "users delete their own notes"
  on public.notes for delete to authenticated
  using ((select auth.uid()) = user_id);

