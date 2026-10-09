# Supabase backend for Love My Closet

Everything the app stores lives in one Supabase project: accounts (Auth),
closet / outfits / calendar / profile data (Postgres), and the transparent
clothing PNGs (Storage). Row Level Security makes every row and image private
to the account that created it.

## 1. One-time setup (Supabase Dashboard)

1. **Create a project** at <https://supabase.com/dashboard> (the Free plan is
   enough; it has hard limits rather than overage charges unless you
   upgrade and enable spend).
2. **Run the schema.** SQL Editor → New query → paste all of
   `supabase/migrations/20260929000000_love_my_closet_schema.sql` → Run.
   It is safe to run again. It creates the tables, RLS policies, the
   `save_outfit` function, the private `clothing-images` bucket and its
   Storage policies.
   **Already set up before piece resizing was added?** Also run
   `supabase/migrations/20261001000000_outfit_piece_scale.sql` once. It adds
   `outfit_items.scale` (each piece's size on the Outfit Builder board) and
   updates `save_outfit` to store it. Safe to run again; the CLI's
   `supabase db push` picks it up automatically.
   (CLI alternative: `supabase link --project-ref <ref>` then `supabase db push`.)
3. **Auth → URL Configuration**
   - _Site URL_: where the web app is served, e.g.
     `https://<you>.github.io/<repo>/`
   - _Redirect URLs_: add the same URL **and** your local dev URL, e.g.
     `http://localhost:5000/` (run with `flutter run -d chrome --web-port 5000`
     so the port is stable). Password-reset and confirm-email links only
     work for URLs listed here.
4. **Auth → Providers → Email**: enabled (default). "Confirm email" can stay
   on (recommended); the app tells new users to check their inbox and then
   log in. Turn it off only if you want sign-up to log straight in.
5. **Project Settings → API Keys**: copy the **Project URL** and the
   **publishable** key (`sb_publishable_…`, or the legacy `anon` key).
   **Do not copy the secret / `service_role` key anywhere in this repo.**

Optional: Auth → Email Templates to restyle the emails. Supabase's built-in
email sender is rate-limited (a few emails per hour) and meant for testing;
add your own SMTP under Auth → SMTP Settings before real users sign up.

## 2. Where the two values go

They are public project identifiers (safe in a web build, protected by RLS).
If you set up your own project, put its values in `env.json` (git-ignored)
rather than editing the defaults in `supabase_config.dart`.

| Where               | What                                                                                                                                                                                                                         |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Local runs          | `env.json` in the project root (git-ignored): `{"SUPABASE_URL": "https://xxxx.supabase.co", "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."}` then `flutter run -d chrome --web-port 5000 --dart-define-from-file=env.json` |
| GitHub Pages deploy | Repo → Settings → Secrets and variables → Actions → New repository secret: `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. `.github/workflows/deploy-web.yml` passes them as `--dart-define`.                                 |

No other secrets exist: background removal runs on-device, and there are no
Edge Functions. The app refuses to start if the key it is given looks like a
secret key.

## 3. Data model

```
auth.users ─1:1─ profiles            display name, bio, notifications, hidden-gems threshold
     │
     ├─1:n─ clothing_items           name, category, occasion, color, is_favorite, image_path
     │           └── image_path → storage: clothing-images/<user_id>/<uuid>.png
     ├─1:n─ outfits                  a saved look (name)
     │        ├─1:n─ outfit_items ─n:1─ clothing_items   (board position + stacking order)
     │        └─1:n─ calendar_entries                      (date worn + diary note)
```

Every table has `user_id` + RLS "owner only" policies for select / insert /
update / delete. `outfit_items` and `calendar_entries` use composite foreign
keys `(id, user_id)` so they can only point at the same user's items and
outfits. Deleting an account cascades to everything it owns. Wear stats
(times worn, last worn, days unworn) are computed from `calendar_entries`,
not stored.

## 4. Testing isolation

`supabase/tests/rls_isolation_test.sql` creates two users and checks that
neither can read, change, delete, impersonate, upload into, or link to the
other's data. Run it against a **local** database only:

```bash
supabase start
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" \
  -v ON_ERROR_STOP=1 -f supabase/migrations/20260929000000_love_my_closet_schema.sql
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" \
  -v ON_ERROR_STOP=1 -f supabase/tests/rls_isolation_test.sql
```

Every check prints `PASS`; any failure stops with an error.

## 5. Sign-up email code (no new tab)

The "Check your email" screen lets new users type a 6-digit code instead of
opening the link. In the Supabase dashboard go to **Authentication → Email
Templates → Confirm signup** and make sure the body contains the code:

```html
<h2>Confirm your email</h2>
<p>Your code: <strong>{{ .Token }}</strong></p>
<p>Or <a href="{{ .ConfirmationURL }}">tap this link</a>.</p>
```

Under **Authentication → Providers → Email**, the code length/expiry can be
adjusted (default 6 digits, valid 1 hour).
