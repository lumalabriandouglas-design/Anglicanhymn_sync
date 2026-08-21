#!/usr/bin/env python3
"""
Permanent cleaner + corrector for Anglican Hymn Sync
Run this on your local hymns-full.json
"""

import json
import re
from pathlib import Path

INPUT_FILE = Path("assets/hymns-full.json")
OUTPUT_FILE = Path("assets/hymns-full-corrected.json")
def clean_lyrics(raw: str) -> str:
    if not raw or not isinstance(raw, str):
        return ""

    text = raw

    # Remove headers and boilerplate
    text = re.sub(r'^AZNIMI-Luganda\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'^—\s*', '', text)
    text = re.sub(r'^by\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Enjatula Luganda Anglican Hymns\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'^OLUYIMBA\s+\d+:\s*.+?\n', '', text, flags=re.IGNORECASE | re.MULTILINE)

    # Remove WordPress footer
    text = re.sub(
        r'Your email address will not be published\..*?Designed with WordPress',
        '',
        text,
        flags=re.IGNORECASE | re.DOTALL
    )
    text = re.sub(r'Comment \*.*?Website', '', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'Save my name, email, and website.*?comment\.', '', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'AZNIMI-Luganda\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Luganda Content Everyday\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Designed with WordPress\s*', '', text, flags=re.IGNORECASE)

    # Remove HTML
    text = re.sub(r'<[^>]+>', '', text)

    # Remove residual leading hyphens on lines
    text = re.sub(r'(?m)^-\s*', '', text)

    # Turn remaining single hyphens between words into spaces
    text = re.sub(r'(\w)-(\w)', r'\1 \2', text)

    # Normalise whitespace
    text = re.sub(r' {2,}', ' ', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r'[ \t]+\n', '\n', text)
    text = re.sub(r'\n[ \t]+', '\n', text)

    return text.strip()


def main():
    if not INPUT_FILE.exists():
        print(f"ERROR: Could not find {INPUT_FILE}")
        print("Make sure hymns-full.json is in the same folder as this script.")
        return

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        hymns = json.load(f)

    print(f"Loaded {len(hymns)} hymns...")

    cleaned_count = 0
    for h in hymns:
        original = h.get('lyrics', '')
        cleaned = clean_lyrics(original)
        if cleaned != original:
            cleaned_count += 1
        h['lyrics'] = cleaned

    # === Manual corrections for known broken hymns ===

       # === Manual corrections for known broken hymns ===

    # Hymn 4 was truncated
    for h in hymns:
        if h.get('n') == 4:
            h['lyrics'] = """1
MUKAMA waffe bulijjo,
Mu linnya lyo tutanule,
Tukole emirimu gyaffe;
Twagala n’okumanya ggwe.

2
Tukolenga by’oyagala,
Tubeerenga mu maaso go,
Tulabe n’omukisa gwo,
Era tukusanyukire.

3
Amaaso go gatulaba:
Mukama otuzibire,
Tukuwe n’emyoyo gyaffe,
Tukole by’otulagira.

4
Era tubeere abaddu bo,
Tutunule, tusabe nnyo,
Tukwatenga amateeka go,
Tuwulire ebigambo byo.

5
Kyonna kyonna kye tulina,
Yesu, kikyo so si kyaffe,
Tubeere naawe bulijjo,
Tutambule mu kkubo lyo."""
            print("→ Fixed Hymn 4 (was truncated)")
            break

    # Hymn 152 – English
    for h in hymns:
        if h.get('n') == 152:
            h['titleEnglish'] = "Praise, my soul, the King of Heaven"
            h['lyricsEnglish'] = """1. Praise, my soul, the King of Heaven;
To His feet thy tribute bring.
Ransomed, healed, restored, forgiven,
Who like thee His praise should sing?
Praise Him! Praise Him!
Praise the everlasting King!

2. Praise Him for His grace and favour
To our fathers in distress;
Praise Him, still the same forever,
Slow to chide and swift to bless.
Praise Him! Praise Him!
Glorious in His faithfulness!

3. Father-like, He tends and spares us;
Well our feeble frame He knows;
In His hands He gently bears us,
Rescues us from all our foes.
Praise Him! Praise Him!
Widely as His mercy flows!

4. Angels, help us to adore Him;
Ye behold Him face to face;
Sun and moon, bow down before Him,
Dwellers all in time and space.
Praise Him! Praise Him!
Praise with us the God of grace!"""
            print("→ Added English for Hymn 152")
            break

    # Hymn 308 – English
    for h in hymns:
        if h.get('n') == 308:
            h['titleEnglish'] = "And Can It Be"
            h['lyricsEnglish'] = """1. And can it be that I should gain
An interest in the Saviour’s blood?
Died He for me, who caused His pain?
For me, who Him to death pursued?
Amazing love! how can it be
That Thou, my God, shouldst die for me?

2. He left His Father’s throne above,
So free, so infinite His grace;
Emptied Himself of all but love,
And bled for Adam’s helpless race:
’Tis mercy all, immense and free;
For, O my God, it found out me.

3. Long my imprisoned spirit lay
Fast bound in sin and nature’s night;
Thine eye diffused a quickening ray,
I woke, the dungeon flamed with light;
My chains fell off, my heart was free;
I rose, went forth, and followed Thee.

4. No condemnation now I dread;
Jesus, and all in Him, is mine!
Alive in Him, my living Head,
And clothed in righteousness divine,
Bold I approach the eternal throne,
And claim the crown, through Christ my own."""
            print("→ Added English for Hymn 308")
            break
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(hymns, f, indent=2, ensure_ascii=False)

    print(f"\nDone!")
    print(f"Hymns cleaned     : {cleaned_count}")
    print(f"Output written to : {OUTPUT_FILE}")
    print("\nNext steps:")
    print("1. Rename hymns-full-corrected.json → hymns-full.json")
    print("2. Put it in your assets/ folder")
    print("3. Run: flutter clean && flutter pub get && flutter run")


if __name__ == "__main__":
    main()