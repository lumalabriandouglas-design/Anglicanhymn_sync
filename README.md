# Anglican Hymn Sync

Luganda + English Anglican hymnal for **web and mobile** from one Flutter codebase.

- Web: https://anglicanhymn-sync.vercel.app
- Repo: https://github.com/lumalabriandouglas-design/Anglicanhymn_sync

## Features
- Search by number, Luganda title, English title, or lyrics
- Dual lyrics (Luganda / English / both)
- Favourites
- Service setlists (add, reorder, liturgical role)
- Auto-scroll lyrics, font size
- Full now-playing deck with lyrics, seek, repeat, shuffle, volume, and a persistent mini player
- Light / dark / system theme

This app is a hymn book only; it has no audio playback.

## Run
```bash
flutter pub get
flutter run -d chrome
flutter run
```

Web build for Vercel is the Flutter web output (`flutter build web`).
