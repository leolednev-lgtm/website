# XHUSXUW — Personal Life OS

This is the existing XHUSXUW app continued in-place. The original sections and workflows have been retained; the update adds analytics, custom metrics, expanded settings, validated JSON backup/restore, and an optional Supabase connection.

## Files

- `index.html` — complete single-file application (HTML, CSS, JavaScript).
- `supabase_schema.sql` — table and Row Level Security policies for Supabase, plus Realtime publication setup.

## Run locally

The app works without an account and stores data in the current browser's `localStorage`.

1. Put `index.html` in a folder.
2. Open a terminal in that folder.
3. Start a local static server:

   **Windows**
   ```powershell
   py -m http.server 5500
   ```

   **macOS / Linux**
   ```bash
   python3 -m http.server 5500
   ```

4. Open `http://localhost:5500`.

You can also open `index.html` directly, but a local HTTP server is recommended, especially for Supabase authentication and redirect URLs.

## Configure Supabase

Cloud sync is optional. Until configured, XHUSXUW remains usable locally.

1. Create a project in Supabase.
2. In **SQL Editor**, run the full contents of `supabase_schema.sql`.
3. In **Authentication → Providers**, enable Email sign-in. Decide whether email confirmation should be required.
4. In **Authentication → URL Configuration**, set the Site URL to your deployed site. During local development, add `http://localhost:5500/**` to the allowed Redirect URLs.
5. In **Project Settings → API**, copy the Project URL and the public `anon` / publishable key.
6. Open XHUSXUW → **Настройки** → **Облачная синхронизация**. Paste the URL and public key, click **Подключить**, then register or sign in.
7. If email confirmation is enabled, confirm the message before signing in.

Only the public anon/publishable key belongs in the browser. **Never put the `service_role` key in `index.html`, JavaScript, or a public repository.** The SQL policies use `auth.uid()` so authenticated users can read and change only the row whose `user_id` matches their account.

The URL and public key are saved in this browser to make reconnecting easier. Authentication tokens are handled by the Supabase client. Local data remains available if the network or Supabase is unavailable; the UI reports the sync state and retries when the browser comes back online.

## Data and synchronization model

- Local-first: changes are written to `localStorage` immediately.
- When signed in, changes are sent to `public.user_data` after a short debounce.
- The server response must succeed before the UI displays **Синхронизировано с сервером**.
- Realtime UPDATE events refresh another signed-in device when it has no unsent local edits.
- When a cloud account already contains data and this device also has data, the app asks which copy to keep. Choosing the local copy uploads it over the cloud copy; choosing the cloud copy replaces local data.
- The table stores one JSON document per account. Concurrent edits on two devices are not merged field-by-field: if both devices edit the same account at nearly the same time, the later successful save can replace the earlier document. Export a JSON backup before major changes and avoid editing on two devices simultaneously until conflict-aware merging is added.

## Backup and restore

Use **Настройки → Экспорт JSON** to download a backup. Import checks the JSON root and required array fields, rejects files larger than 5 MB, and asks for confirmation before replacing current data. Keep backups somewhere outside the browser profile.

## Publish the site

Because the project is static, it can be hosted on GitHub Pages, Netlify, Cloudflare Pages, or any static web host:

1. Upload `index.html` (and optionally this README and SQL file) to the hosting provider.
2. Set the deployed domain as Supabase's Site URL and add it to the allowed Redirect URLs.
3. Open the deployed site, connect Supabase in Settings, and sign in.

## Important limitations

- The app has no server-side application backend; Supabase Auth and the `user_data` table provide account access and cloud persistence.
- Cloud setup cannot be completed until you provide your own Supabase Project URL and public anon/publishable key and run the SQL script.
- The current cloud model is last-write-wins for the whole JSON document; it does not implement automatic merging of conflicting edits.
- Historical task completion dates did not exist in older app data. The new `completedAt` field is written when a task is checked from this version onward. Earlier completed tasks remain completed, but their exact completion date is unknown and is not fabricated in the trend view.
- This package has been syntax-checked and structurally inspected. A live Supabase login, RLS request, Realtime event, and deployment cannot be certified until connected to a real Supabase project.
