# Anglican Hymn Sync

Luganda + English Anglican hymnal for **web and mobile** from one Flutter codebase.

- Web: https://anglicanhymn-sync.vercel.app
- Repo: https://github.com/lumalabriandouglas-design/Anglicanhymn_sync

## Features
- Search by number, Luganda title, English title, or lyrics
- Dual lyrics (Luganda / English / both)
- Favourites
- Service setlists (add, reorder, liturgical role, play available audio)
- Audio from Cloudflare R2, catalogue refreshed on launch
- Light / dark / system theme

## Audio (Cloudflare R2)

Public bucket prefix:

`https://pub-22426af78c4e41d989b240b35aa21225.r2.dev`

The app loads this file on every launch:

`https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/audio-catalogue.json`

Order of lookup:
1. R2 catalogue (latest)
2. Last successful catalogue cached on the device
3. Bundled `assets/audio-catalogue.json`
4. Hardcoded hymn 332 fallback

### Add a recording without rebuilding the app
1. Upload audio:
   - `hymns/332-en.m4a`
   - `hymns/332-lg.m4a`
   - `extras/christmas-01.m4a`
2. Upload an updated `audio-catalogue.json` to the **root** of the same public R2 bucket.
3. Open or refresh the website / app. New tracks appear without a store release.

Keep `assets/audio-catalogue.json` in git in sync when you can, so first-time offline installs still have a baseline.

Current test track is hymn **332** (English: What a Friend We Have in Jesus).

Example catalogue:

```json
{
  "version": 1,
  "tracks": [
    {
      "id": "332-en",
      "hymnNumber": "332",
      "language": "english",
      "title": "What a Friend We Have in Jesus",
      "url": "https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/What%20A%20Friend%20We%20Have%20In%20Jesus%20Lyric%20Video%20Lydia%20Walker%20Acoustic%20Hymns%20with%20Lyrics-128.m4a",
      "type": "hymn"
    }
  ]
}
```

### Web CORS (required)
In the R2 bucket CORS policy allow the Vercel origin or both audio and the catalogue fail in the browser:

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

Also enable **public access** on the audio objects and on `audio-catalogue.json`.

## Run
```bash
flutter pub get
flutter run -d chrome
flutter run
```

Web build for Vercel is the Flutter web output (`flutter build web`).
