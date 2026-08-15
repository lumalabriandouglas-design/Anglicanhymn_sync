#!/usr/bin/env python3
import json
import re
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
POSSIBLE_PATHS = [
    SCRIPT_DIR / "hymns-full.json",
    SCRIPT_DIR.parent / "hymns-full.json",
    Path("hymns-full.json"),
]
OUTPUT_FILE = SCRIPT_DIR / "hymns-full-corrected.json"

def clean_lyrics(raw: str) -> str:
    if not raw or not isinstance(raw, str):
        return ""

    text = raw

    # Remove all the common junk
    text = re.sub(r'^AZNIMI-Luganda\s*', '', text, flags=re.I)
    text = re.sub(r'^—\s*', '', text)
    text = re.sub(r'^by\s*', '', text, flags=re.I)
    text = re.sub(r'Enjatula Luganda Anglican Hymns\s*', '', text, flags=re.I)
    text = re.sub(r'^OLUYIMBA\s+\d+:\s*.+?\n', '', text, flags=re.I | re.M)
    text = re.sub(r'Your email address will not be published\..*?Designed with WordPress', '', text, flags=re.I | re.S)
    text = re.sub(r'Comment \*.*?Website', '', text, flags=re.I | re.S)
    text = re.sub(r'Save my name, email, and website.*?comment\.', '', text, flags=re.I | re.S)
    text = re.sub(r'AZNIMI-Luganda\s*', '', text, flags=re.I)
    text = re.sub(r'Luganda Content Everyday\s*', '', text, flags=re.I)
    text = re.sub(r'Designed with WordPress\s*', '', text, flags=re.I)
    text = re.sub(r'<[^>]+>', '', text)

    # Remove leading hyphens on lines
    text = re.sub(r'(?m)^-\s*', '', text)
    text = re.sub(r'(\w)-(\w)', r'\1 \2', text)

    # Fix lonely stanza numbers → "1. First line..."
    text = re.sub(r'^(\d+)\s*\n+', r'\1. ', text)
    text = re.sub(r'\n+(\d+)\s*\n+', r'\n\n\1. ', text)

    # Clean whitespace
    text = re.sub(r' {2,}', ' ', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r'[ \t]+\n', '\n', text)
    text = re.sub(r'\n[ \t]+', '\n', text)

    return text.strip()

def main():
    input_file = next((p for p in POSSIBLE_PATHS if p.exists()), None)
    if not input_file:
        print("ERROR: Could not find hymns-full.json")
        return

    print(f"Found: {input_file}")
    with open(input_file, 'r', encoding='utf-8') as f:
        hymns = json.load(f)

    print(f"Loaded {len(hymns)} hymns...")

    for h in hymns:
        h['lyrics'] = clean_lyrics(h.get('lyrics', ''))

    # Manual fixes
    for h in hymns:
        if h.get('n') == 4:
            h['lyrics'] = """1. MUKAMA waffe bulijjo,
Mu linnya lyo tutanule,
Tukole emirimu gyaffe;
Twagala n’okumanya ggwe.

2. Tukolenga by’oyagala,
Tubeerenga mu maaso go,
Tulabe n’omukisa gwo,
Era tukusanyukire.

3. Amaaso go gatulaba:
Mukama otuzibire,
Tukuwe n’emyoyo gyaffe,
Tukole by’otulagira.

4. Era tubeere abaddu bo,
Tutunule, tusabe nnyo,
Tukwatenga amateeka go,
Tuwulire ebigambo byo.

5. Kyonna kyonna kye tulina,
Yesu, kikyo so si kyaffe,
Tubeere naawe bulijjo,
Tutambule mu kkubo lyo."""
            print("→ Fixed Hymn 4")

        if h.get('n') == 7:
            h['lyrics'] = """1. ZUUKUKA ggwe omwoyo gwange,
Busaasaanye,
Era bukeeredde ddala;
Zuukuka ove mu tulo,
Waayo gy’ali
By’osobolera ddala.

2. Sanyukira enjuba ye eyo;
Evuddeyo,
Yambala amaanyi go;
Obudde bw’ekiro bukedde:
Ye akubedde,
Akuggye mu kabi ako.

3. N’obulamu bwo enkeera,
Busanye.
Okuyita mu kabi ako,
Olw’olubeerwa okuva gy’ali,
N’ojja eri ye;
Okusinza n’amaanyi go."""
            print("→ Fixed Hymn 7")

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(hymns, f, indent=2, ensure_ascii=False)

    print(f"\nDone! Output → {OUTPUT_FILE}")
    print("1. Delete old hymns-full.json")
    print("2. Rename hymns-full-corrected.json → hymns-full.json")
    print("3. Put it in assets/")
    print("4. flutter clean && flutter pub get && flutter run")
    print("5. git add . && git commit -m \"Cleaned lyrics 1-150 + fixed 4 & 7\" && git push")

if __name__ == "__main__":
    main()