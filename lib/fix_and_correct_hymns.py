#!/usr/bin/env python3
"""
Permanent cleaner + corrector for Anglican Hymn Sync
Run this on your local hymns-full.json
"""

import json
import re
from pathlib import Path

INPUT_FILE = Path("hymns-full.json")          # your current file
OUTPUT_FILE = Path("hymns-full-corrected.json")

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