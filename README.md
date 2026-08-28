# Anglican Hymn Sync

Luganda + English Anglican hymnal for **web and mobile** from one Flutter codebase.

- Web: https://anglicanhymn-sync.vercel.app
- Repo: https://github.com/lumalabriandouglas-design/Anglicanhymn_sync

## Features
- Search by number, Luganda title, English title, or lyrics
- Dual lyrics (Luganda / English / both)
- Favourites
- Service setlists (add, reorder, liturgical role, play available audio)
- Audio from Cloudflare R2
- Light / dark / system theme

## Audio (Cloudflare R2)

Public bucket prefix:

`https://pub-22426af78c4e41d989b240b35aa21225.r2.dev`

### Add a hymn recording
1. Upload with a stable name:
   - `hymns/332-en.m4a`
   - `hymns/332-lg.m4a`
   - `extras/christmas-01.m4a`
2. Add a row to `assets/audio-catalogue.json`.
3. Redeploy web / rebuild the app.

Current test track is hymn **332** (English: What a Friend We Have in Jesus).

### Web CORS (required)
In the R2 bucket CORS policy allow the Vercel origin or playback fails in the browser:

```json
[
  {
    "AllowedOrigins": [
      "https://anglicanhymn-sync.vercel.app",
      "http://localhost:8080",
      "http://localhost:5000"
    ],
    "AllowedMethods": ["GET", "HEAD"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["Content-Length", "Content-Type", "Accept-Ranges", "ETag"],
    "MaxAgeSeconds": 86400
  }
]
```

Also enable **public access** on the audio objects (already working for the test file).

## Run
```bash
flutter pub get
flutter run -d chrome
flutter run
```

Web build for Vercel is the Flutter web output (`flutter build web`).
