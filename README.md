# StudyNest Admin Dashboard

Private admin portal for the StudyNest student app. Manages users, reports, announcements, quotas, and blocked users via Supabase.

## Features

- **Authentication** – Admin-only login via Supabase Auth (email/password)
- **User Management** – View all users, promote/demote admin, suspend/unsuspend, delete accounts
- **Reports** – View user-submitted reports, mark as reviewed or dismissed
- **Announcements** – Create, edit, and delete platform-wide announcements
- **Quotas & Usage** – Monitor AI request counts, storage, and per-user usage
- **Blocked Users** – View and unblock blocked users
- **Real-time** – Realtime subscriptions for announcements and reports
- **Responsive** – Works on desktop and tablet

## Tech Stack

- HTML5 + Vanilla JavaScript (no build step)
- CSS3 (modern, responsive)
- Supabase (Auth, Database, Realtime)

## Setup

### 1. Supabase

In your Supabase project SQL Editor, run these:

```sql
-- Enable the admin tables (already in StudyNest core schema)
-- blocked_users, reports, user_quotas, user_quota_usage
```

Make sure RLS policies allow the admin role to read/write these tables.

### 2. Environment

Copy `.env.example` to `.env` and fill in your Supabase URL and anon key:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ADMIN_EMAIL=admin@studynest.local
```

> ⚠️ Never commit `.env`. It is gitignored.

### 3. Run locally

```bash
# With Python
python -m http.server 8000

# Or with Node
npx http-server
```

Open `http://localhost:8000` and sign in with an admin account.

### 4. Deploy (Vercel)

Connect this repo to Vercel. Add `SUPABASE_URL` and `SUPABASE_ANON_KEY` as environment variables.

## Security

- Only users with `role = 'admin'` in `public.profiles` can access the admin routes.
- All mutating operations require a valid Supabase auth session.
- RLS on Supabase tables enforces row-level security at the database level.
