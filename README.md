# StudyNest Admin Dashboard

Private admin portal for the StudyNest student app. Manages users, reports, announcements, quotas, and blocked users via Supabase.

## Features

- **Authentication** – Admin-only login via Supabase Auth (email/password)
- **User Management** – View all users, promote/demote admin, suspend/unsuspend, delete profiles
- **Reports** – View user-submitted reports, mark as reviewed or dismissed
- **Announcements** – Create, edit, and delete platform-wide announcements
- **Quotas & Usage** – Monitor AI request counts, storage, and per-user usage
- **Blocked Users** – View and unblock blocked users
- **Responsive** – Works on desktop and tablet

## Tech Stack

- HTML5 + Vanilla JavaScript (single self-contained page)
- CSS3 (modern, responsive)
- Supabase (Auth, Database)

## Setup

### 1. Supabase

In your Supabase project SQL Editor, run:

1. `../StudyNest/supabase/migrations/20261030000000_studynest_core.sql` (core tables)
2. `supabase_complete_schema.sql` (admin tables + first admin)
3. `admin_fix.sql` (enables suspension and admin role/delete actions)

`admin_fix.sql` is safe to run more than once.

### 2. Run locally

```bash
npm run dev
```

Open `http://localhost:8000` and sign in with an admin account.

### 3. Deploy (Vercel)

This repo now has a real build:

```bash
npm run build   # copies index.html + manifest.webmanifest into dist/
```

Vercel settings:

- **Build Command:** `npm run build`
- **Output Directory:** `dist`

`vercel.json` already contains those settings and the SPA rewrite.

### 4. Live URL

This is the **only** admin dashboard:

```
https://studynest-admin.vercel.app/
```

The main app links to it directly from the profile page. `https://study-nest-ashen.vercel.app/admin`
is now just a redirect to that URL, so old bookmarks keep working.

> Do **not** use `https://study-nest-admin.vercel.app` (with a hyphen). That domain belongs to an
> unrelated project, not StudyNest.

## Security

- Only users with `role = 'admin'` in `public.profiles` can use the dashboard.
- All mutating operations require a valid Supabase auth session.
- RLS on Supabase tables enforces row-level security at the database level.
- `admin_fix.sql` lets admins manage profiles while still blocking normal users from promoting themselves.
