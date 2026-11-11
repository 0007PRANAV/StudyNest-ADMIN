# StudyNest Admin Dashboard

Private admin portal for the StudyNest student app. Manages users, reports, announcements, quotas, blocked users, library books, and moderated video submissions via Supabase.

## Features

- **Authentication** – Admin-only login via Supabase Auth (email/password)
- **User Management** – View all users, promote/demote admin, suspend/unsuspend, delete profiles
- **Video Approvals** – Review student uploads; approve to publish or decline with a reason. Students see “⏳ Waiting for Admin’s Approval” until then, and receive an in-app notification on review.
- **Library** – Add or remove books in the shared StudyNest library catalog
- **Reports** – View user-submitted reports, mark as reviewed or dismissed
- **Announcements** – Create, edit, and delete platform-wide announcements
- **Quotas & Usage** – Monitor AI request counts, storage, and per-user usage
- **Blocked Users** – View and unblock blocked users
- **Responsive** – Works on desktop, tablet, and mobile (hamburger drawer)

## Tech Stack

- HTML5 + Vanilla JavaScript (single self-contained page)
- CSS3 (modern, responsive)
- Supabase (Auth, Database, Storage)

## Setup

### 1. Supabase

In your Supabase project SQL Editor, run **one file**:

1. `RUN_ALL_FIXES.sql` — everything: core admin fixes, suspension, library, moderated videos, streaks, badges, notifications, focus sessions, and the `videos` storage bucket. Safe to run more than once.

If you have not yet run the original core schema, run these first in order:

1. `../StudyNest/supabase/migrations/20261030000000_studynest_core.sql` (core tables)
2. `supabase_complete_schema.sql` (admin tables + first admin)
3. `RUN_ALL_FIXES.sql` (all admin + new-feature tables)

### 2. Email notifications (optional but recommended)

Video approval/decline emails need one API key set in Vercel (main app project):

- `RESEND_API_KEY` and `NOTIFY_FROM`, **or**
- `BREVO_API_KEY` and `NOTIFY_FROM`

Without a key the app still works: students get an in-app notification in the 🔔 inbox.

### 3. Run locally

```bash
npm run dev
```

Open `http://localhost:8000` and sign in with an admin account.

### 4. Deploy (Vercel)

This repo now has a real build:

```bash
npm run build   # copies index.html + manifest.webmanifest into dist/
```

Vercel settings:

- **Build Command:** `npm run build`
- **Output Directory:** `dist`

`vercel.json` already contains those settings and the SPA rewrite.

### 5. Live URL

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
- `RUN_ALL_FIXES.sql` lets admins manage profiles while still blocking normal users from promoting themselves.
- Passwords are bcrypt-hashed by Supabase Auth and are never readable from the dashboard.

